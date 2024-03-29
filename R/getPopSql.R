#' Query local SQL database
#' @description Returns population estimates from a WOPR SQL database based on cell ids provided.
#' @param cells A numeric vector of cell ids (see ?cellids)
#' @param db An SQLite database connection
#' @param agesex_table The age sex table
#' @param verbose Logical indicating to print status updates while processing
#' @param max_area Maximum area (sq km) of polygons allowed to query the SQL database
#' @param timeout Timeout period (seconds)
#' @param agesex_select Character vector of age-sex groups (e.g. c(m0,m1,m5,m10,m15,f0,f1) includes boys 0-19 and girls under 5)
#' @param get_agesexid Logical indicating to return the agesex region ID.
#' @return Estimated population total summed across all cell ids. Result is returned as a numeric vector containing samples from the predicted posterior distribution.
#' @export

getPopSql <- function(cells, db, agesex_table=NA, get_agesexid=F, verbose=T, max_area=1e3, timeout=60,
                      agesex_select=c(paste0('f',c(0,1,seq(5,80,5))),paste0('m',c(0,1,seq(5,80,5))))){
  
  t0 <- Sys.time()
  
  if(verbose) {
    cat(paste('Querying 1 feature from local database:\n'))
    cat(paste(' ',db@dbname,'\n'))
  }
  
  query_area <- length(cells) * 93.97^2 * 1e-6
  if(query_area > max_area){
    
    warning('Polygon area (',round(query_area),' sq km) exceeds maximum area allowed (',max_area,' sq km).', call.=F)
    pop <- id <- NA
    
  } else {
    
    pop <- 0
    id <- c()
    
    # query database
    block_size <- 5e3
    for(i in seq(1,length(cells),by=block_size)){
      
      if(difftime(Sys.time(), t0, units='secs') > timeout){
        warning('Operation timed out after ',timeout,' seconds', call.=F)
        timeout <- TRUE
        break
      } 
        
      # cell ids
      cells_sub <- cells[i:min(i+block_size-1, length(cells))]
      
      # SQL query
      dbRes <- DBI::dbGetQuery(db, paste0('SELECT Pop,agesexid FROM Nhat WHERE cell IN (',paste(cells_sub,collapse=','),')'))
      
      # parse results
      if(length(dbRes$Pop) > 0){
        
        # split population vector (method 1)
        pop_block <- t(stringi::stri_split_fixed(dbRes$Pop,',',simplify=T))
        class(pop_block) <- 'numeric'
        
        # # split population vector (method 2)
        # pop_block <- apply(matrix(dbRes$Pop), 1, function(x) as.numeric(stringi::stri_split_fixed(x, ',',simplify=T)))
        
        # agesex adjustment
        if(length(agesex_select) < ncol(agesex_table)){
          if(!'data.frame' %in% class(agesex_table)){
            
            warning('No agesex_table available.', call.=F)
            
          } else if(sum(is.na(dbRes$agesexid))>0){
            
            warning('No agesex_id returned from database.', call.=F)
            
          } else {
            
            pop_block <- pop_block * apply(agesex_table[dbRes$agesexid, agesex_select], 1, sum)
          }
        }

        # bind with previous blocks
        if('matrix' %in% class(pop)) {
          pop <- cbind(pop, pop_block)
        } else {
          pop <- pop_block
        }
        id <- c(id, dbRes$agesexid)
      }
      suppressWarnings(rm(cells_sub, dbRes, pop_block)); gc()
    }

    if('matrix' %in% class(pop)) { 
      pop <- apply(pop, 1, sum)
    }
  }
  
  if(timeout==TRUE){
    pop <- id <- NA
  }
  
  if(length(id)==0){
    id <- NA
  }
  
  if(get_agesexid){
    
    # get modal id
    uniq <- unique(id)
    agesexid <- uniq[which.max(tabulate(match(id, uniq)))]
    
    result <- list(N = pop, 
                   agesexid = agesexid)
  } else {
    result <- pop
  }
  
  if(verbose) {
    print(difftime(Sys.time(), t0))
    cat('\n')
  }
  
  gc()
  
  # return vector
  return(result)
}

