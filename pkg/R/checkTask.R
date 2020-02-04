#' Check WOPR task
#' @description Retrieve results from a task id or task ids that previously timed out
#' @param taskid A character vector of task IDs
#' @return A list with a result for each task id which will be a vector of samples from posterior distribution of the population total if that task has completed.
#' @export

checkTask <- function(taskid){
  
  result <- list()
  
  queue <- endpoint()$queue
  
  for(i in 1:length(taskid)){
    result_i <- content( GET(file.path(queue, taskid[i])), as='parsed')
    if(result_i$status=='finished' & result_i$error==FALSE){
      result[[i]] <- unlist(result_i$data$total)
    } else {
      result[[i]] <- result_i
    }
  }
  return(result)
}