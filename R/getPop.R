#' Get population estimate for a single point or polygon
#' @description Query WOPR using an sf point or polygon to get population estimates as a vector of samples from the Bayesian posterior prediction for that location.
#' @param feature An object of class sf with a point or polygon to calculate population total. If more than one feature are included, only the first feature will be processed.
#' @param country The ISO3 country code
#' @param version Version number of the population estimate
#' @param agesex_select Character vector of age-sex groups
#' @param key Key to increase daily quota for REST API requests
#' @param verbose Logical. Toggles on status updates while processing
#' @param get_agesexid Logical. Toggle return of numeric age sex id (for woprVision)
#' @param url Server url (optional)
#' @return A vector of samples from posterior distribution of the population total. If the task times out the function will return the task ID.
#' @export

getPop <- function(feature, country, version=NA, 
                   key='key.txt', verbose=T, get_agesexid=F, url='https://api.worldpop.org/v1',
                   agesex_select=c(paste0('m',c(0,1,seq(5,80,5))),paste0('f',c(0,1,seq(5,80,5))))
                   ){

  t0 <- Sys.time()

  feature <- feature[1,]

  if(file.exists(key)) key <- dget(key)

  wopr_url <- endpoint(features=feature, agesex=length(agesex_select)<36, url=url)

  # submit tasks to endpoint
  tasks <- submitTasks(features=feature,
                       country=country,
                       version=version,
                       agesex_select=agesex_select,
                       url_endpoint=wopr_url$endpoint,
                       key=key,
                       verbose=verbose)

  if(nrow(tasks) > 0){
    # print task ids
    if(verbose){
      cat('Task ID(s):\n')
      for(i in 1:nrow(tasks)){
        cat(paste0('  ',tasks[i,'task_id'],'\n'))
      }
    }
    
    # retrieve results
    output <- retrieveResults(tasks,
                              url_queue=wopr_url$queue,
                              summarize=F,
                              verbose=verbose,
                              save_messages=T)
    
    if(!is.na(output$message)){
      if(output$message=='General WP Error. No settled grid cells'){
        message('No settled grid cells in this feature.')
      } else {
        warning(output$message, call.=F)
      }
    }
    
    if('pop1' %in% names(output)) {
      N <- as.numeric(output[,which(names(output)=='pop1'):ncol(output)])
    } else {
      N <- NA
    }
    
    if(get_agesexid) {
      return(list(N=N, agesexid=output$agesexid))
    } else {
      return(N)
    }
  }
  print(difftime(Sys.time(), t0))
  cat('\n')
}


