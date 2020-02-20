#' Query local SQL database
#' @description Returns population estimates from a WOPR SQL database based on cell ids provided.
#' @param cells A numeric vector of cell ids (see ?cellids)
#' @param db An SQLite database connection
#' @param verbose Logical indicating to print status updates while processing
#' @param agesexSelect Character vector of age-sex groups (e.g. c(m0,m1,m5,m10,m15,f0,f1) includes boys 0-19 and girls under 5)
#' @param getAgesexId Logical indicating to return the agesex region ID.
#' @return Estimated population total summed across all cell ids. Result is returned as a numeric vector containing samples from the predicted posterior distribution.
#' @export

getPopSql <- function(cells, db, agesexTable, getAgesexId=F, verbose=T,
                      agesexSelect=c(paste0('m',c(0,1,seq(5,80,5))),paste0('f',c(0,1,seq(5,80,5))))){
  
  t0 <- Sys.time()
  
  if(verbose) {
    cat(paste('Querying 1 feature from local database:\n'))
    cat(paste(' ',db@dbname,'\n'))
  }
  
  # query database
  maxquery <- 1e3
  for(i in seq(1,length(cells),by=maxquery)){
    cells_sub <- cells[i:min(i+maxquery-1, length(cells))]
    if(i==1){
      dbRes <- DBI::dbGetQuery(db, paste0('SELECT Pop,agesexid FROM Nhat WHERE cell IN (',paste(cells_sub,collapse=','),')'))
    } else {
      dbRes <- rbind(dbRes, DBI::dbGetQuery(db, paste0('SELECT Pop,agesexid FROM Nhat WHERE cell IN (',paste(cells_sub,collapse=','),')')))
    }
  }

  # find most common agesexid
  id <- getmode(dbRes$agesexid)
  
  if(nrow(dbRes) > 0){
    
    # population matrix
    pop <- apply(data.frame(Pop=dbRes$Pop), 1, function(x) as.numeric(unlist(strsplit(x, ','))))
    
    # agesex adjustment
    if(length(agesexSelect) < 36){
      
      # agesex matrix
      agesexProp <- apply(agesexTable[dbRes$agesexid, agesexSelect], 1, sum)
      
      # adjust population
      pop <- pop * agesexProp
    }
    
    # apply sum
    tot <- apply(pop, 1, sum)
    
  } else {
    tot <- 0
  }
  
  if(getAgesexId){
    result <- list(N=tot, agesexid=id)
  } else {
    result <- tot
  }
  
  print(difftime(Sys.time(), t0))
  cat('\n')
  
  # return vector
  return(result)
}

