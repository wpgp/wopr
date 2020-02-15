#' Get population estimate for a single point or polygon
#' @description Query WOPR using an sf point or polygon to get population estimates as a vector of samples from the Bayesian posterior prediction for that location.
#' @param feature An object of class sf with a point or polygon to calculate population total. If more than one feature are included, only the first feature will be processed.
#' @param country The ISO3 country code
#' @param ver Version number of the population estimate
#' @param agesex Character vector of age-sex groups
#' @param timeout Seconds until timeout
#' @param key Key to increase daily quota for REST API requests
#' @return A vector of samples from posterior distribution of the population total. If the task times out the function will return the task ID.
#' @export

getPop <- function(feature, country, ver=NA, 
                   agesex=c("m0","m1","m5","m10","m15","m20","m25","m30","m35","m40","m45","m50","m55","m60","m65","m70","m75","m80",
                            "f0","f1","f5","f10","f15","f20","f25","f30","f35","f40","f45","f50","f55","f60","f65","f70","f75","f80"),
                   timeout=5*60, key='key.txt', verbose=T){
  
  t0 <- Sys.time()
  
  feature <- feature[1,]
  
  if(file.exists(key)) key <- dget(key)
  
  wopr_url <- endpoint(features=feature, agesex=length(agesex)<36)
  
  # submit tasks to endpoint
  tasks <- submitTasks(features=feature, 
                       country=country, 
                       ver=ver, 
                       agesex=agesex, 
                       url=wopr_url$endpoint,
                       key=key,
                       verbose=verbose)
  
  # print task ids
  if(verbose){
    cat('Task ID(s):\n')
    for(i in 1:nrow(tasks)){
      cat(paste0('  ',tasks[i,'task_id'],'\n'))
    }
  }
  
  # retrieve results
  output <- retrieveResults(tasks, 
                            url=wopr_url$queue, 
                            summarize=F, 
                            timeout=timeout, 
                            verbose=verbose)
  
  if('pop1' %in% names(output)) {
    output <- as.numeric(output[,which(names(output)=='pop1'):ncol(output)])
  } else {
    output <- NA
  }
  
  print(difftime(Sys.time(), t0))
  cat('\n')
  
  return(output)
}    

  
