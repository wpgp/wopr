#' Get population estimate from GRID3 server via API request
#' @param feature An object of class sf with a point or polygon to calculate population total. If more than one feature are included, only the first feature will be processed.
#' @param country The ISO3 country code
#' @param ver Version number of the population estimate
#' @param agesex Character vector of age-sex groups
#' @param timeout Seconds until timeout
#' @param key Key to increase daily quota for REST API requests
#' @param production Logical indicating whether to use the test server or production server
#' @return A vector of samples from posterior distribution of the population total. If the task times out the function will return the task ID.
#' @export

getPop <- function(feature, country, ver, 
                   agesex=c("m0","m1","m5","m10","m15","m20","m25","m30","m35","m40","m45","m50","m55","m60","m65","m70","m75","m80",
                            "f0","f1","f5","f10","f15","f20","f25","f30","f35","f40","f45","f50","f55","f60","f65","f70","f75","f80"),
                   timeout=60, production=F, key=NULL){
  
  t0 <- Sys.time()
  
  feature <- feature[1,]
  
  worldpop_url <- wpEndpoint(geometry_class=class(feature$geometry)[1],
                             agesex=length(agesex)<36,
                             production=production)
  
  # submit tasks to endpoint
  tasks <- submitTasks(features=feature, 
                       country=country, 
                       ver=ver, 
                       agesex=agesex, 
                       url=worldpop_url$endpoint, 
                       key=key,
                       verbose=F)

  # retrieve results
  output <- retrieveResults(tasks, 
                            summarize=F, 
                            timeout=timeout, 
                            url=worldpop_url$queue, 
                            verbose=F)
  
  if('pop1' %in% names(output)) output <- as.numeric(output[,which(names(output)=='pop1'):ncol(output)])
  
  print(difftime(Sys.time(), t0))
  
  # return result as vector
  return(output)
}