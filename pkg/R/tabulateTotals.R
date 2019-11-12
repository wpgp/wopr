#' Tabulate population totals for multiple polygons.
#' Note: The operation may take a number of seconds per polygon.
#' 
#' @param polygons SpatialPolygonsDataFrame with polygons to calculate population totals
#' @param country ISO-3 code for the country requested
#' @param ver Version number of population estimates
#' @param alpha The type 1 error rate for the confidence intervals
#' @param tails The number of tails for the confidence intervals
#' @param parallel Logical indicating whether to process polygons in parallel to improve computation time
#' @param timeout Seconds until the operation for a single polygon times out
#' @param verbose Logical to print status indicator as polygons are processed (not available for parallel processing)
#' 
#' @return The SpatialPolygonsDataFrame with population totals added into columns: meanPop, medianPop, lowerPop, upperPop
#' 
#' @export

tabulateTotals <- function(polygons, country, ver, alpha=0.05, tails=2, parallel=F, timeout=30, verbose=F){
  
  # setup cluster
  if(parallel){
    ncores <- min(detectCores(), nrow(polygons))
    cl <- makeCluster(ncores)
    registerDoParallel(cl)
  } else {
    ncores <- 1
  }
  
  # polygon ids
  polygons@data$gfid <- 1:nrow(polygons)
  npoly <- nrow(polygons)
  
  # randomize
  polygons <- polygons[sample(x=1:nrow(polygons), size=nrow(polygons)),]
  
  # split polygons into list for parallel processing
  dat <- list()
  groups <- rep(1:ncores, length.out=nrow(polygons))
  for(i in 1:ncores){
    dat[[i]] <- polygons[groups==i,]
  }
  
  # function for parallel processing
  tabulateParallel <- function(polygons){
    
    result <- data.frame(matrix(NA,nrow=nrow(polygons),ncol=5))
    
    for(i in 1:nrow(polygons)){
      if(verbose) print(paste0(polygons@data[i,'gfid'],'/',npoly,' (',round(i/npoly*100,1),'%)'))
      
      # disaggregate MultiPolygons into separate Polygons
      polygons_sub <- disaggregate(polygons[i,])
      
      # sum populations among seperate parts (j) of a MultiPolygon (i)
      N <- 0
      for(j in 1:nrow(polygons_sub)){
        N <- N + getPop(gj = geojson_json(polygons_sub[j,]), 
                        country = country, 
                        ver = ver,
                        timeout=timeout)
      }
      
      # summarize results and add to output data frame
      result[i,] <- cbind(data.frame(id=polygons@data[i,'gfid']), summaryPop(N, alpha=alpha, tails=tails))
    }
    names(result) <- c('gfid','mean','median','lower','upper')
    return(result)
  }
  
  # process polygons
  if(parallel){
    result <- foreach(i=dat, 
                      .combine=rbind, 
                      .export=c('getPop','summaryPop'), 
                      .packages=c('httr','geojsonio','sp')) %dopar% tabulateParallel(i)
  } else {
    result <- foreach(i=dat, .combine=rbind) %do% tabulateParallel(i)
  }
  
  # stop cluster
  if(parallel) stopCluster(cl)
  
  # sort by id
  result <- result[order(result$gfid),]
  row.names(result) <- result$gfid
  
  # drop id column
  result <- result[,-1]
  
  return(result)
}
