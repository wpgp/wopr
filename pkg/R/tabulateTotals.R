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
                           key=NULL,
                           production=F){
  
  t0 <- Sys.time()
  
  # API end point
  worldpop_url <- wpEndpoint(geometry_class=class(features$geometry)[1], 
                             agesex=length(agesex)<36,
                             production=production)
  
  if(is.na(worldpop_url$endpoint)) {
    output <- 'No API end point.'
  } else {
    # feature ids
    features$feature_id <- 1:nrow(features)
    
    # submit tasks to endpoint
    tasks <- submitTasks(features=features, 
                         country=country, 
                         ver=ver, 
                         agesex=agesex, 
                         url=worldpop_url$endpoint, 
                         key=key)
    
    # retrieve results from queue
    output <- retrieveResults(tasks=tasks, 
                              alpha=alpha,
                              tails=tails,
                              popthresh=popthresh,
                              url=worldpop_url$queue,
                              timeout=timeout)
    
    # spatial output
    if(spatialjoin) {
      output <- merge(features, output, 'feature_id')
    }
  }
  print(difftime(Sys.time(),t0,units='mins'))
  return(output)
}