#' Query local SQL database
#' @description Returns population estimates from a WOPR SQL database based on cell ids provided.
#' @param cells A numeric vector of cell ids (see ?cellids)
#' @param db An SQLite database connection
#' @return Estimated population total summed across all cell ids. Result is returned as a numeric vector containing samples from the predicted posterior distribution.
#' @export

getPopSql <- function(cells, db){
  
  # query database
  dbRes <- dbGetQuery(db, paste0('SELECT Pop FROM Nhat WHERE cell IN (',paste(cells,collapse=','),')'))
  
  # expand result to matrix
  mat <- apply(dbRes, 1, function(x) as.numeric(unlist(strsplit(x, ','))))
  
  # apply sum
  tot <- apply(mat, 1, sum)
  
  # return vector
  return(tot)
}

