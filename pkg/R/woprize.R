#' WOPRize a shapefile
#' @description Query WOPR to get population totals and confidence intervals for sf polygon or point features.
#' @param features An object of class sf with points or polygons to calculate population totals
#' @param country ISO-3 code for the country requested
#' @param ver Version number of population estimates
#' @param agesex Character vector of age-sex groups
#' @param confidence The confidence level for the confidence intervals (e.g. 0.95 = 95 percent confidence intervals)
#' @param tails The number of tails for the confidence intervals
#' @param abovethresh The function will return the probability that the population size exceeds _abovethresh_
#' @param belowthresh The function will return the probability that the population size is less than _belowthresh_
#' @param spatialJoin Logical indicating to join results to sf spatial data or to return a data frame
#' @param summarize Logical indicating to summarize results or return all posterior samples
#' @param timeout Seconds until the operation for a single polygon times out
#' @param key API key
#' @return A data frame or sf spatial data object with summaries of posterior distribtuions for estimates of total population within each polygon
#' @export

woprize <- function(features, country, ver=NA, confidence=0.95, tails=2, abovethresh=NA, belowthresh=NA, spatialjoin=T, summarize=T, timeout=30*60, 
                    agesex=c("m0","m1","m5","m10","m15","m20","m25","m30","m35","m40","m45","m50","m55","m60","m65","m70","m75","m80",
                             "f0","f1","f5","f10","f15","f20","f25","f30","f35","f40","f45","f50","f55","f60","f65","f70","f75","f80"),
                    key='key.txt'){
  
  t0 <- Sys.time()
  
  if(file.exists(key)) key <- dget(key)
  
  # API end point
  wopr_url <- endpoint(features=features, agesex=length(agesex)<36)
  
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
                              abovethresh=abovethresh,
                              belowthresh=belowthresh,
                              url=wopr_url$queue,
                              summarize=summarize,
                              timeout=timeout)
    
    # spatial output
    if(spatialjoin & class(output)=='data.frame') {
      output <- merge(features, output, 'feature_id')
    }
  }
  
  output <- output[,!names(output)=='feature_id']
  
  print(difftime(Sys.time(),t0,units='mins'))
  
  return(output)
}