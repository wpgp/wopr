#' Retrieve results from a task id or task ids that previously timed out
#' @param taskid A character vector of task IDs
#' @param production Logical indicating whether to use the test server or production server
#' @return A list with a result for each task id which will be a vector of samples from posterior distribution of the population total if that task has completed.
#' @export

checkTask <- function(taskid, production=F){
  
  result <- list()
  
  if(production) { queue <- 'https://api.worldpop.org/v1/tasks'
  } else { queue <- 'http://10.19.100.66/v1/tasks'}
  
  for(i in taskid){
    result_i <- content( GET(file.path(queue, taskid)), as='parsed')
    if(result_i$status=='finished'){
      result[[i]] <- unlist(result_i$data$total)
    } else {
      result[[i]] <- result_i
    }
  }
  return(result)
}