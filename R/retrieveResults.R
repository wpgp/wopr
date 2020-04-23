#' Retrieve results from WOPR
#' @param tasks A data frame with information about tasks (see ?submitTasks)
#' @param url The url of the WorldPop queue to check for results (see ?endpoint)
#' @param confidence The confidence level for the confidence intervals (e.g. 0.95 = 95 percent confidence intervals)
#' @param tails The number of tails for the confidence intervals
#' @param abovethresh The function will return the probability that the population size exceeds _abovethresh_
#' @param belowthresh The function will return the probability that the population size is less than _belowthresh_
#' @param summarize Logical indicating to summarize results or return all posterior samples
#' @param timeout Seconds until function times out
#' @param verbose Logical indicating to print progress updates
#' @param save_messages Save messages from WOPR including task ids that can be used to retrieve results later using checkTask()
#' @return A data frame with outputs
#' @export

retrieveResults <- function(tasks, url,
                            confidence=0.95, tails=2,
                            abovethresh=NA, belowthresh=NA,
                            summarize=T, timeout=30*60, verbose=T, save_messages=F){
  t0 <- Sys.time()
  timed_out <- F

  if(verbose) {
    cat(paste('Checking status of',nrow(tasks),'tasks until complete or',timeout/60,'minutes elapse:\n'))
    cat('  ')
  }

  # setup output
  output_cols <- c('feature_id',names(summaryPop(1)),'task_id','agesexid','message')
  output <- matrix(NA, nrow=length(unique(tasks$feature_id)), ncol=length(output_cols))
  colnames(output) <- output_cols
  row.names(output) <- output[,'feature_id'] <- 1:nrow(output)

  # add task ids to output
  for(i in 1:nrow(output)){
    output[i,'task_id'] <- paste(tasks[tasks$feature_id==output[i,'feature_id'], 'task_id'], collapse=',')
  }

  # tasks with submission errors
  for(i in which(!tasks[,'status']=='created')){
    output[tasks[i,'feature_id'],'message'] <- tasks[i,'message']
  }

  # tasks that are processing
  tasks_remaining <- sum(tasks[,'status'] == 'created')

  myprogress <- function(tasks_remaining, total_tasks=nrow(tasks), print_progress=verbose){
    progress <- round(100*(1-(tasks_remaining / total_tasks)))
    if(print_progress){
      cat(paste0(progress,'%...'))
    }
    return(progress)
  }

  progress_indicator <- old_progress_indicator <- myprogress(tasks_remaining, print_progress=F)

  while(tasks_remaining > 0 & !timed_out){

    for(i in which(tasks[,'status'] %in% c('created','started'))){

      task_id <- tasks[i,'task_id']
      feature_id <- tasks[i,'feature_id']

      tasks_this_feature <- tasks[tasks[,'feature_id']==feature_id, 'task_id']

      ##-- single feature --##
      if(length(tasks_this_feature)==1){

        # parse result
        result <- httr::content( httr::GET(file.path(url, tasks_this_feature)), as='parsed')

        # update task id status
        tasks[i,'status'] <- result$status

        # error handling
        abort <- F
        if(result$error){

          # save message
          output[feature_id,'message'] <-  result$error_message

          # abort unless value error (which may mean settled area = 0)
          if(!result$error_message=='No User Description for this type of error: ValueError'){
            abort <- T
          }
        }

        # process finished result
        if(result$status=='finished' & !abort){

          # population posterior
          N <- unlist(result$data$total)

          # fill in zero for unsettled areas
          if(is.null(N)){
            N <- 0
          }

          # agesex id
          if(!is.null(result$data$agesexid)) {
            output[feature_id,'agesexid'] <- result$data$agesexid
          }

          # summarize results and add to output data frame
          summaryN <- summaryPop(N, confidence=confidence, tails=tails, abovethresh=abovethresh, belowthresh=belowthresh)
          output[feature_id, names(summaryN)] <- as.matrix(summaryN)

          # save full posterior
          if(!summarize){
            if(!'pop1' %in% names(output)){
              output_bind <- matrix(NA, nrow=nrow(output), ncol=length(N))
              colnames(output_bind) <- paste0('pop',1:length(N))
              output <- cbind(output, output_bind)
            }
            output[feature_id, paste0('pop',1:length(N))] <- N
          }
        }
      }

      ##-- multi-part feature --##
      if(length(tasks_this_feature) > 1) {

        results <- list()
        all_finished <- T
        all_abort <- F
        for(j in 1:length(tasks_this_feature)){

          # get result
          results[[j]] <- httr::content( httr::GET(file.path(url, tasks_this_feature[j])), as='parsed')

          # not yet finished
          if(!results[[j]]$status=='finished'){
            all_finished <- F
            break
          }

          # error handling
          if(results[[j]]$error){
            output[feature_id,'message'] <- results[[j]]$error_message
            tasks[tasks[,'task_id'] %in% tasks_this_feature,'status'] <- results[[j]]$status
            if(!results[[j]]$error_message=='No User Description for this type of error: ValueError'){
              results[[j]]$data$total <- NA
              all_abort <- T
              break
            }
          }
        }

        # update status
        if(!all_finished & !all_abort){
          tasks[i,'status'] <- results[[1]]$status
        }

        # process completed features
        if(all_finished & !all_abort){

          # sum population posteriors across sub-polygons
          N <- 0
          Nmean <- rep(NA, length(tasks_this_feature))
          for(j in 1:length(tasks_this_feature)){
            Ntask <- unlist(results[[j]]$data$total)
            if(is.numeric(Ntask)) {
              N <- N + Ntask
              Nmean[j] <- mean(Ntask)
            }
          }

          # find most common agesex id
          if(is.numeric(Nmean) > 0){
            k <- which(Nmean==max(Nmean,na.rm=T))
            if(!is.null(results[[k]]$data$agesexid)){
              output[,'agesexid'] <- results[[k]]$data$agesexid
            }
          }

          # summarize results and add to output data frame
          summaryN <- summaryPop(N, confidence=confidence, tails=tails, abovethresh=abovethresh, belowthresh=belowthresh)
          output[feature_id, names(summaryN)] <- as.matrix(summaryN)

          # save full posterior
          if(!summarize) {
            if(!'pop1' %in% colnames(output)){
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

      # check progress
      tasks_remaining <- sum(tasks[,'status'] %in% c('created','started'))

      # progress indicator
      progress_indicator <- myprogress(tasks_remaining, print_progress=F)
      if(progress_indicator > (old_progress_indicator+10)){
        old_progress_indicator <- myprogress(tasks_remaining)
      }

      # timeout
      if(difftime(Sys.time(), t0, units='secs')  > timeout){
        warning(paste0('Task timed out after ',timeout,' seconds. Use the taskid(s) to retrieve results (',paste(tasks_this_feature,sep=', '),'). See wopr R package (?wopr::checkTask) and/or the wopr REST API documentation.'), call.=F)
        timed_out <- T
        break
      }

      # cleanup
      suppressWarnings(rm(N, task_id, feature_id, tasks_this_feature))
    }
    if(tasks_remaining > 0) Sys.sleep(1/tasks_remaining)
  }

  # format output as data.frame
  cols <- colnames(output)
  output <- data.frame(matrix(output[order(as.numeric(output[,'feature_id'])),], nrow=nrow(output)))
  names(output) <- cols

  # keep full posteriors
  if(!summarize & 'pop1' %in% cols){
    output[,which(cols=='pop1'):length(cols)] <- lapply(output[which(cols=='pop1'):length(cols)], function(x) as.numeric(as.character(x)))
  }

  # save as numeric
  output[,c('mean','median','lower','upper','abovethresh','agesexid')] <- lapply(output[c('mean','median','lower','upper','abovethresh','agesexid')], function(x) as.numeric(as.character(x)))

  # drop cols
  if(!save_messages) output <- output[,!names(output) %in% c('task_id','message')]

  cat('\n')
  return(output)
}
