#' Query local SQL database
#' @description Returns population estimates from a WOPR SQL database based on cell ids provided.
#' @param cells A numeric vector of cell ids (see ?cellids)
#' @param db An SQLite database connection
#' @param verbose Logical indicating to print status updates while processing
#' @param agesexSelect Character vector of age-sex groups (e.g. c(m0,m1,m5,m10,m15,f0,f1) includes boys 0-19 and girls under 5)
#' @param getAgesexId Logical indicating to return the agesex region ID.
#' @return Estimated population total summed across all cell ids. Result is returned as a numeric vector containing samples from the predicted posterior distribution.
#' @export

getPopSql <- function(cells, db, agesexTable, getAgesexId=F, verbose=T, block_size=999,
                      agesexSelect=c(paste0('m',c(0,1,seq(5,80,5))),paste0('f',c(0,1,seq(5,80,5))))){
  
  t0 <- Sys.time()
  
  if(verbose) {
    cat(paste('Querying 1 feature from local database:\n'))
    cat(paste(' ',db@dbname,'\n'))
  }
  
  # query database
  pop <- 0
  id <- c()
  for(i in seq(1,length(cells),by=block_size)){
    
    # cell ids
    cells_sub <- cells[i:min(i+block_size-1, length(cells))]
    
    # SQL query
    dbRes <- DBI::dbGetQuery(db, paste0('SELECT Pop,agesexid FROM Nhat WHERE cell IN (',paste(cells_sub,collapse=','),')'))
    
    # parse results
    if(length(dbRes$Pop) > 0){
      
      # unlist population vector
      pop_block <- apply(matrix(dbRes$Pop), 1, function(x) as.numeric(unlist(strsplit(x, ','))))

      # agesex adjustment
      if(length(agesexSelect) < 36){
        pop_block <- pop_block * apply(agesexTable[dbRes$agesexid, agesexSelect], 1, sum)
      }
      
      # bind with previous blocks
      if(class(pop)=='matrix') {
        pop <- cbind(pop, pop_block)
      }
      id <- c(id, dbRes$agesexid)
    }
  }

  if(class(pop)=='matrix') { 
    pop <- apply(pop, 1, sum)
  }
  
  if(getAgesexId){
    result <- list(N=pop, agesexid=getmode(id))
  } else {
    result <- pop
  }
  
  if(verbose) {
    print(difftime(Sys.time(), t0))
    cat('\n')
  }
  
  # return vector
  return(result)
}

