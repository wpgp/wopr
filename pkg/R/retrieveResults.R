#' Retrieve results from WorldPop API
#' @param tasks A data frame with information about tasks (see ?submitTasks)
#' @param url The url of the WorldPop queue to check for results
#' @param alpha The type 1 error rate for the confidence intervals
#' @param tails The number of tails for the confidence intervals
#' @param popthresh Threshold population size to calculate the probability that population exceeds
#' @param summarize Logical indicating to summarize results or return all posterior samples
#' @param timeout Seconds until function times out
#' @param verbose Logical indicating to print progress updates
#' @return A data frame with outputs
#' @export

retrieveResults <- function(tasks, url, alpha=0.05, tails=2, popthresh=NA, summarize=T, timeout=30*60, verbose=T){
  t0 <- Sys.time()
  
  if(verbose) print(paste('Checking status of',nrow(tasks),'tasks...'))
  
  output_cols <- c('feature_id','mean','median','lower','upper','abovethresh','uncertainty','message')
  output <- matrix(NA, nrow=length(unique(tasks$feature_id)), ncol=length(output_cols))
  colnames(output) <- output_cols
  row.names(output) <- output[,'feature_id'] <- 1:nrow(output)
  
  # tasks with submission errors
  for(i in which(!tasks[,'status']=='created')){
    feature_id <- tasks[i,'feature_id']
    task_id <- tasks[i,'task_id']
    
    output[feature_id,'message'] <- tasks[i,'message']
  }
  
  # tasks that are processing
  tasks_remaining <- sum(tasks[,'status'] == 'created')
  
  myprogress <- function(tasks_remaining, total_tasks=nrow(tasks), print_progress=verbose){
    progress <- round(100*(1-(tasks_remaining / total_tasks)), 1)
    if(print_progress){
      print(paste0('  ',progress,'% complete (',round(difftime(Sys.time(), t0, units='mins'),1),' minutes elapsed)'))
    }
    return(progress)
  }
  
  progress_indicator <- old_progress_indicator <- myprogress(tasks_remaining)
  
  while(tasks_remaining > 0){
    
    # timeout
    if(difftime(Sys.time(), t0, units='secs')  > timeout){
      print( paste0('Task timed out after ',timeout,' seconds.') )
      print( 'Use checkTask(taskid) to retrieve results.' )
      
      result <- list()
      for(i in 1:nrow(tasks)) result[[tasks$task_id[i]]] <- tasks$status[i]
      
      return( result )
      break
    }
    
    for(i in which(tasks[,'status'] %in% c('created','started'))){
      
      task_id <- tasks[i,'task_id']
      feature_id <- tasks[i,'feature_id']
      
      tasks_this_feature <- tasks[tasks[,'feature_id']==feature_id, 'task_id']
      tasks_this_feature <- unique(c(task_id, tasks_this_feature))
      
      ##-- Single Feature --##
      if(length(tasks_this_feature)==1){
        
        # get result
        result <- content( GET(file.path(url, tasks_this_feature)), as='parsed')
        
        if(result$status=='finished'){
          
          # population posterior
          N <- unlist(result$data$total)
          
          # summarize results and add to output data frame
          summaryN <- summaryPop(N, alpha=alpha, tails=tails, popthresh=popthresh)
          output[feature_id, names(summaryN)] <- as.matrix(summaryN)
          output[feature_id, 'message'] <-  paste0(result$executionTime,'s')
          if(!summarize){
            if(!'pop1' %in% names(output)){
              output_bind <- matrix(NA, nrow=nrow(output), ncol=length(N))
              colnames(output_bind) <- paste0('pop',1:length(N))
              output <- cbind(output, output_bind)
              rm(output_bind)
            }
            output[feature_id, paste0('pop',1:length(N))] <- N
          } 
        }
        if(result$error){
          output[feature_id,'message'] <-  result$error_message
        }
        # update task id status
        tasks[i,'status'] <- result$status
      }
      
      ##-- MultiPolygon --##
      if(length(tasks_this_feature) > 1) {
        
        results <- list()
        all_finished <- T
        all_abort <- F
        for(j in 1:length(tasks_this_feature)){
          
          results[[j]] <- content( GET(file.path(url, tasks_this_feature[j])), as='parsed')
          
          if(!results[[j]]$status=='finished'){
            all_finished <- F
            break
          }
          
          if(!results[[j]]$status %in% c('created','started','finished')){
            output[feature_id,'message'] <- result$error_message
            tasks[tasks[,'task_id'] %in% tasks_this_feature,'status'] <- results[[j]]$status
            all_abort <- T
            break
          }
        }
        
        if(!all_finished & !all_abort){
          tasks[i,'status'] <- results[[1]]$status
        } 
        
        if(all_finished & !all_abort){
          # sum population posteriors across sub-polygons
          N <- 0
          for(j in 1:length(tasks_this_feature)){
            pop_sub <- unlist(results[[j]]$data$total)
            
            if(is.numeric(pop_sub)){
              N <- N + pop_sub
            } else {
              N <- NA
            }
          }
          # summarize results and add to output data frame
          summaryN <- summaryPop(N, alpha=alpha, tails=tails, popthresh=popthresh)
          output[feature_id, names(summaryN)] <- as.matrix(summaryN)
          output[feature_id, 'message'] <- paste0('MultiFeature-',length(tasks_this_feature))
          if(!summarize) {
            if(!'pop1' %in% names(output)){
              output_bind <- matrix(NA, nrow=nrow(output), ncol=length(N))
              colnames(output_bind) <- paste0('pop',1:length(N))
              output <- cbind(output, output_bind)
              rm(output_bind)
            }
            output[ feature_id , paste0('pop',1:length(N)) ] <- N
          }
          
          # update task id status
          tasks[tasks[,'task_id'] %in% tasks_this_feature,'status'] <- 'finished'
        }
      }
      
      # cleanup
      suppressWarnings(rm(N, task_id, feature_id, tasks_this_feature))
    }
    tasks_remaining <- sum(tasks[,'status'] %in% c('created','started'))
    
    # progress indicator
    progress_indicator <- myprogress(tasks_remaining, print_progress=F)
    if(progress_indicator > (old_progress_indicator+10)){
      old_progress_indicator <- myprogress(tasks_remaining)
    }
    
    if(tasks_remaining > 0) Sys.sleep(1/tasks_remaining)
  }
  
  # format output
  cols <- colnames(output)
  output <- data.frame(matrix(output[order(as.numeric(output[,'feature_id'])),], nrow=nrow(output)))
  names(output) <- cols
  if(!summarize & 'pop1' %in% cols){
    output[,which(cols=='pop1'):length(cols)] <- lapply(output[which(cols=='pop1'):length(cols)], function(x) as.numeric(as.character(x)))  
  }
  
  return(output)
}