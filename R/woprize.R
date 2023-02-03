#' WOPRize a shapefile
#' @description Query WOPR to get population totals and confidence intervals for sf polygon or point features.
#' @param features sf. An object of class sf with points or polygons to calculate population totals.
#' @param country character. ISO-3 code for the country requested.
#' @param version character or numeric. Version number of population estimates.
#' @param agesex_select charcter vector. Age-sex groups (e.g. "m0", "m1", "m5").
#' @param confidence numeric. The confidence level for the confidence intervals (e.g. 0.95 = 95 percent confidence intervals).
#' @param tails numeric. The number of tails for the confidence intervals.
#' @param abovethresh numeric. The function will return the probability that the population size exceeds _abovethresh_.
#' @param belowthresh numeric. The function will return the probability that the population size is less than _belowthresh_.
#' @param summarize logical. If TRUE, results will be summarized. If FALSE, all posterior samples will be returned.
#' @param key character. API key.
#' @param url character. Server url (optional).
#' @return sf. An sf spatial data object with summaries of posterior distributions for estimates of total population within each polygon.
#' @export

woprize <- function(features, country, version=NA, confidence=0.95, tails=2, abovethresh=NA, belowthresh=NA, summarize=T, 
                    agesex_select=c(paste0('m',c(0,1,seq(5,80,5))),paste0('f',c(0,1,seq(5,80,5)))),
                    key='key.txt', url='https://api.worldpop.org/v1'){
  
  t0 <- Sys.time()
  
  if(file.exists(key)) key <- dget(key)
  
  # API end point
  agesex_full <- ncol(getAgeSexTable(country=country, version=version, locator=url))-1
  wopr_url <- endpoint(features=features, agesex=length(agesex_select)<agesex_full, url=url)
  
  if(length(agesex_select)==agesex_full){
    agesex_select = 'full'
  }
  
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
                              url_queue=wopr_url$queue,
                              summarize=summarize)
    
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