#' Tabulate population totals for multiple features (points or polygons) in an sf object.
#' Note: The operation may take a number of seconds per feature.
#' 
#' @param features An object of class sf with points or polygons to calculate population totals
#' @param country ISO-3 code for the country requested
#' @param ver Version number of population estimates
#' @param alpha The type 1 error rate for the confidence intervals
#' @param tails The number of tails for the confidence intervals
#' @param timeout Seconds until the operation for a single polygon times out
#' @param key Key to increase daily quota for REST API requests
#' 
#' @return A data frame with summaries of posterior distribtuions for estimates of total population within each polygon
#' 
#' @export

tabulateTotals <- function(features, country, ver, alpha=0.05, tails=2, popthresh=NA, spatialjoin=T, timeout=10*60, 
                           agesex=c("m0","m1","m5","m10","m15","m20","m25","m30","m35","m40","m45","m50","m55","m60","m65","m70","m75","m80",
                                    "f0","f1","f5","f10","f15","f20","f25","f30","f35","f40","f45","f50","f55","f60","f65","f70","f75","f80"),
                           key=NULL){
  
  t0 <- Sys.time()
  
  # use production endpoint? (TRUE=production; FALSE=test)
  production <- F
  if(production) { 
    endpoint <- 'https://api.worldpop.org/v1/grid3/stats'
    queue <- 'https://api.worldpop.org/v1/tasks'
  } else { 
      endpoint <- 'http://10.19.100.66/v1/grid3' # '/stats' 
    queue <- 'http://10.19.100.66/v1/tasks'
  }
  
  if(class(features$geometry)[1] %in% c('sfc_POLYGON','sfc_MULTIPOLYGON')){
    endpoint <- file.path(endpoint, 'popag')
  } else if(class(features$geometry)[1] %in% c('sfc_POINT','sfc_MULTIPOINT')){
    endpoint <- file.path(endpoint, 'sample')
  } else {
    print('Input must be of class sf and include points or polygons')
    break
  }
  
  # feature ids
  features$feature_id <- 1:nrow(features)
  
  # submit tasks to endpoint
  tasks <- submitTasks(features=features, 
                       country=country, 
                       ver=ver, 
                       agesex=agesex, 
                       url=endpoint, 
                       key=key)
  
  # retrieve results from queue
  output <- retrieveResults(tasks=tasks, 
                            alpha=alpha,
                            tails=tails,
                            popthresh=popthresh,
                            url=queue,
                            timeout=timeout)
  
  # spatial output
  if(spatialjoin) {
    output <- merge(features, output, 'feature_id')
  } 
  
  print(difftime(Sys.time(),t0,units='mins'))
  
  return(output)
}