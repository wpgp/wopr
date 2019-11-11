#' Retrieve results from a task that timed out
#' 
#' @param taskid The task ID returned from requestPop()
#' @param test Logical indicating whether to use the test server or production server
#' 
#' @return A vector of samples from posterior distribution of the population total. If the task times out the function will return the task ID.
#' 
#' @export

checkTask <- function(taskid, test=F){
  
  if(!test) { queue <- 'https://api.worldpop.org/v1/tasks'
  } else { queue <- 'http://10.19.100.66/v1/tasks'}
  
  result <- content( GET(file.path(queue, taskid)), as='parsed')
  
  if(!result$status=='finished'){
    print('Task not complete')
    return(taskid)
  } else {
    return(unlist(result$data$total))
  }
}