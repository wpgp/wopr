#' Tabulate population totals for polygons
#' 
#' @param shapes SpatialPolygonsDataFrame with polygons to calculate population totals
#' @param alpha The type 1 error rate for the confidence intervals
#' @param tails The number of tails for the confidence intervals
#' @param test Logical indicating whether to use the test server or production server
#' 
#' @return The SpatialPolygonsDataFrame with population totals added into columns: meanPop, medianPop, lowerPop, upperPop
#' 
#' @export

tabulateTotals <- function(shapes, alpha=0.05, tails=2, parallel=F, test=F){
  
  # function for parallel processing
  tabulateParallel <- function(shapes, alpha=0.05, tails=2){
    result <- data.frame(matrix(NA,nrow=nrow(shapes),ncol=5))
    for(i in 1:nrow(shapes)){
      N <- requestPop(geojson = geojsonio::geojson_json(shapes[i,]), 
                      iso3 = 'NGA', 
                      ver = '1.2',
                      test = test)
      result[i,] <- cbind(data.frame(id=shapes@data[i,'id']), summaryPop(N, alpha=alpha, tails=tails))
    }
    names(result) <- c('id','mean','median','lower','upper')
    return(result)
  }
  
  # setup cluster
  ncores <- min(detectCores()-1, nrow(shapes))
  cl <- makeCluster(ncores)
  registerDoParallel(cl)
  
  # shape ids
  shapes@data$id <- 1:nrow(shapes)
  
  # chunk shapes into list for parallel processing
  dat <- list()
  groups <- rep(1:ncores, length.out=nrow(shapes))
  for(i in 1:ncores){
    dat[[i]] <- shapes[groups==i,]
  }
  
  # process jags data in parallel
  if(parallel){
    result <- foreach(i=dat, .combine=rbind, .export=c('requestPop','summaryPop'), .packages=c('httr')) %dopar% tabulateParallel(i)
  } else {
    result <- foreach(i=dat, .combine=rbind, .export=c('requestPop','summaryPop'), .packages=c('httr')) %do% tabulateParallel(i)
  }
  
  # stop cluster
  stopCluster(cl)
  
  # sort by id
  result <- result[order(result$id),]
  row.names(result) <- result$id
  
  result <- result[,-1]
  
  return(result)
}
