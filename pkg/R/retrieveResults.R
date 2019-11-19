#' Retrieve results from WorldPop API
#' @param tasks A data frame with information about tasks (see ?submitTasks)
#' @param url The url of the WorldPop queue to check for results
#' @return A data frame with outputs
#' @export

retrieveResults <- function(tasks, alpha, tails, popthresh, url, timeout=30*60){
  t0 <- Sys.time()
  
  print(paste('Checking status of',nrow(tasks),'tasks...'))
  
  output_cols <- c('feature_id','mean','median','lower','upper','aboveThresh','message')
  output <- matrix(NA, nrow=nrow(features), ncol=length(output_cols))
  colnames(output) <- output_cols
  rownames(output) <- output[,'feature_id'] <- 1:nrow(features)
  
  # tasks with submission errors
  for(i in which(!tasks[,'status']=='created')){
    task_id <- tasks[i,'task_id']
    feature_id <- tasks[i,'feature_id']
    
    output[feature_id,'message'] <- tasks[i,'message']
  }
  
  # tasks that are processing
  tasks_remaining <- sum(tasks[,'status'] == 'created')
  
  myprogress <- function(tasks_remaining, total_tasks=nrow(tasks), print_progress=T){
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
      break
    }
    
    for(i in which(tasks[,'status'] %in% c('created','started'))){
      
      task_id <- tasks[i,'task_id']
      feature_id <- tasks[i,'feature_id']
      
      tasks_this_feature <- tasks[tasks[,'feature_id']==feature_id, 'task_id']
      tasks_this_feature <- unique(c(task_id, tasks_this_feature))
      
      ##-- Single Polygon --##
      if(length(tasks_this_feature)==1){
        
        # get result
        result <- content( GET(file.path(url, tasks_this_feature)), as='parsed')
        
        if(result$status=='finished'){
          
          # population posterior
          N <- unlist(result$data$total)
          
          # summarize results and add to output data frame
          output[feature_id,c('mean','median','lower','upper')] <- as.matrix(summaryPop(N, alpha=alpha, tails=tails))
          output[feature_id,'aboveThresh'] <- mean(N > popthresh)
          output[feature_id,'message'] <-  paste0(result$executionTime,'s')
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
          output[feature_id,c('mean','median','lower','upper')] <- as.matrix(summaryPop(N, alpha=alpha, tails=tails))
          output[feature_id,'aboveThresh'] <- mean(N > popthresh)
          output[feature_id,'message'] <- paste0('MultiFeature-',length(tasks_this_feature))
          
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
  output <- data.frame(matrix(output[order(as.numeric(output[,'feature_id'])),], nrow=nrow(features)))
  names(output) <- cols
  
  return(output)
}