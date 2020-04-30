#' WOPRize a shapefile
#' @description Query WOPR to get population totals and confidence intervals for sf polygon or point features.
#' @param features An object of class sf with points or polygons to calculate population totals
#' @param country ISO-3 code for the country requested
#' @param version Version number of population estimates
#' @param agesex_select Character vector of age-sex groups
#' @param confidence The confidence level for the confidence intervals (e.g. 0.95 = 95 percent confidence intervals)
#' @param tails The number of tails for the confidence intervals
#' @param abovethresh The function will return the probability that the population size exceeds _abovethresh_
#' @param belowthresh The function will return the probability that the population size is less than _belowthresh_
#' @param summarize Logical indicating to summarize results or return all posterior samples
#' @param key API key
#' @param save_messages Save messages from WOPR including task ids that can be used to retrieve results later using checkTask()
#' @param url Server url (optional)
#' @return A data frame or sf spatial data object with summaries of posterior distribtuions for estimates of total population within each polygon
#' @export

woprize <- function(features, country, version=NA, confidence=0.95, tails=2, abovethresh=NA, belowthresh=NA, summarize=T, 
                    agesex_select=c(paste0('m',c(0,1,seq(5,80,5))),paste0('f',c(0,1,seq(5,80,5)))),
                    key='key.txt', save_messages=F, url='https://api.worldpop.org/v1'){
  
  t0 <- Sys.time()
  
  if(file.exists(key)) key <- dget(key)
  
  # API end point
  wopr_url <- endpoint(features=features, agesex=length(agesex_select)<36, url=url)
  
  # feature ids
  features$feature_id <- 1:nrow(features)
  
  # submit tasks to endpoint
  tasks <- submitTasks(features=features, 
                       country=country, 
                       version=version, 
                       agesex_select=agesex_select, 
                       url_endpoint=wopr_url$endpoint, 
                       key=key)
  
  
  if(nrow(tasks)>0){
    
    # retrieve results from queue
    output <- retrieveResults(tasks=tasks, 
                              confidence=confidence,
                              tails=tails,
                              abovethresh=abovethresh,
                              belowthresh=belowthresh,
                              url_tasks=wopr_url$queue,
                              summarize=summarize,
                              save_messages=save_messages)
    
    # join results to sf features
    if(class(output)=='data.frame') {
      output <- merge(features, output, 'feature_id')
    }
    
    output <- output[,!names(output)=='feature_id']
    
    return(output)    
  }
  print(difftime(Sys.time(),t0,units='mins'))
  cat('\n')
}