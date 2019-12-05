#' Query WOPR to get population totals and confidence intervals for polygon features.
#' Note: The operation may take a number of seconds per feature.
#' @param features An object of class sf with points or polygons to calculate population totals
#' @param country ISO-3 code for the country requested
#' @param ver Version number of population estimates
#' @param agesex Character vector of age-sex groups
#' @param confidence The confidence level for the confidence intervals (e.g. 0.95 = 95% confidence intervals)
#' @param tails The number of tails for the confidence intervals
#' @param popthresh Threshold population size to calculate the probability that population exceeds
#' @param spatialJoin Logical indicating to join results to sf spatial data or to return a data frame
#' @param summarize Logical indicating to summarize results or return all posterior samples
#' @param timeout Seconds until the operation for a single polygon times out
#' @param key Key to increase daily quota for REST API requests
#' @param production Logical indicating whether to use the test server or production server
#' @return A data frame or sf spatial data object with summaries of posterior distribtuions for estimates of total population within each polygon
#' @export

tabulateTotals <- function(features, country, ver, confidence=0.95, tails=2, popthresh=NA, spatialjoin=T, summarize=T, timeout=10*60, 
                           agesex=c("m0","m1","m5","m10","m15","m20","m25","m30","m35","m40","m45","m50","m55","m60","m65","m70","m75","m80",
                                    "f0","f1","f5","f10","f15","f20","f25","f30","f35","f40","f45","f50","f55","f60","f65","f70","f75","f80"),
                           key=NULL,
                           production=F){
  
  t0 <- Sys.time()
  
  # API end point
  wopr_url <- endpoint(features=features, agesex=length(agesex)<36, production=production)
  
  if(is.na(wopr_url$endpoint)) {
    output <- 'No API end point.'
  } else {
    # feature ids
    features$feature_id <- 1:nrow(features)
    
    # submit tasks to endpoint
    tasks <- submitTasks(features=features, 
                         country=country, 
                         ver=ver, 
                         agesex=agesex, 
                         url=wopr_url$endpoint, 
                         key=key)
    
    # retrieve results from queue
    output <- retrieveResults(tasks=tasks, 
                              confidence=confidence,
                              tails=tails,
                              popthresh=popthresh,
                              url=wopr_url$queue,
                              summarize=summarize,
                              timeout=timeout)
    
    # spatial output
    if(spatialjoin & class(output)=='data.frame') {
      output <- merge(features, output, 'feature_id')
    }
  }
  print(difftime(Sys.time(),t0,units='mins'))
  return(output)
}