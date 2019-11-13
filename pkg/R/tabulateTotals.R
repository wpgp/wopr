#' Tabulate population totals for multiple polygons.
#' Note: The operation may take a number of seconds per polygon.
#' 
#' @param polygons SpatialPolygonsDataFrame with polygons to calculate population totals
#' @param country ISO-3 code for the country requested
#' @param ver Version number of population estimates
#' @param alpha The type 1 error rate for the confidence intervals
#' @param tails The number of tails for the confidence intervals
#' @param timeout Seconds until the operation for a single polygon times out
#' 
#' @return A data frame with summaries of posterior distribtuions for estimates of total population within each polygon
#' 
#' @export

tabulateTotals <- function(polygons, country, ver, alpha=0.05, tails=2, timeout=10*60){
  t0 <- Sys.time()
  
  # use production server? (TRUE=production; FALSE=test)
  production <- F
  if(production) { 
    server <- 'https://api.worldpop.org/v1/grid3/stats'
    queue <- 'https://api.worldpop.org/v1/tasks'
  } else { 
    server <- 'http://10.19.100.66/v1/grid3/stats' 
    queue <- 'http://10.19.100.66/v1/tasks'
  }
  
  # polygon ids
  polygons@data$polygon_id <- 1:nrow(polygons)
  npoly <- nrow(polygons)
  
  ##---- submit tasks to server ----##
  tasks <- matrix(NA,ncol=4,nrow=0)
  colnames(tasks) <- c('polygon_id','task_id','status','message')
  
  for(i in 1:npoly){
    
    # disaggregate MultiPolygons into separate Polygons
    polygons_sub <- disaggregate(polygons[i,])
    polygon_id <- polygons@data$polygon_id[i]
    
    for(j in 1:nrow(polygons_sub)){
      
      # create request
      request <- list(iso3 = country,
                      ver = ver,
                      geojson = geojson_json(polygons_sub[j,]),
                      key = "wm0LY9MakPSAehY4UQG9nDFo2KtU7POD"
                      )
      
      # send request
      response <- content( POST(url=server, body=request, encode="form"), as='parsed')
      
      # save task id
      if(!'taskid' %in% names(response)){
        response$taskid <- NA
      }
      if('error_description' %in% names(response)){
        response$error_message <- response$error_description
      }
      if(is.null(response$error_message)){
        response$error_message <- NA
      }
      newrow <- data.frame(polygon_id = polygon_id, 
                           task_id = response$taskid, 
                           status = response$status, 
                           message = response$error_message)
      tasks <- rbind(tasks, newrow)
    }
    suppressWarnings(rm(polygons_sub, polygon_id, newrow))
  }
  
  # format tasks
  for(i in 1:ncol(tasks)) tasks[,i] <- as.character(tasks[,i])

  # close server connection
  close(url(server))
  
  
  ##---- retrieve results ----##
  output <- matrix(NA, nrow=npoly, ncol=6)
  colnames(output) <- c('polygon_id','mean','median','lower','upper','message')
  output[,1] <- 1:npoly

  # tasks with submission errors
  for(i in which(!tasks[,'status']=='created')){
    task_id <- tasks[i,'task_id']
    polygon_id <- tasks[i,'polygon_id']
    
    output[as.numeric(polygon_id),'message'] <- tasks[i,'message']
  }
  
  # tasks that are processing
  tasks_remaining <- sum(tasks[,'status'] == 'created')
  
  while(tasks_remaining > 0){
    
    # timeout
    if((Sys.time() - t0)  > timeout){
      print( paste0('Task timed out after ',timeout,' seconds.') )
      break
    }
    
    for(i in which(tasks[,'status'] %in% c('created','started'))){
      
      task_id <- tasks[i,'task_id']
      polygon_id <- tasks[i,'polygon_id']
      
      tasks_this_poly <- tasks[tasks[,'polygon_id']==polygon_id, 'task_id']
      tasks_this_poly <- unique(c(task_id, tasks_this_poly))
      
      ##-- Single Polygon --##
      if(length(tasks_this_poly)==1){
        
        # get result
        result <- content( GET(file.path(queue, tasks_this_poly)), as='parsed')
        
        if(result$status=='finished'){
          
          # population posterior
          N <- unlist(result$data$total)
          
          # summarize results and add to output data frame
          output[as.numeric(polygon_id),c('mean','median','lower','upper')] <- as.matrix(summaryPop(N, alpha=alpha, tails=tails))
          output[as.numeric(polygon_id),'message'] <-  paste0(result$executionTime,'s')
        }
        if(result$error){
          output[as.numeric(polygon_id),'message'] <-  result$error_message
        }
        # update task id status
        tasks[i,'status'] <- result$status
      }
      
      ##-- MultiPolygon --##
      if(length(tasks_this_poly) > 1) {
        
        results <- list()
        all_finished <- T
        all_abort <- F
        for(j in 1:length(tasks_this_poly)){
          
          results[[j]] <- content( GET(file.path(queue, tasks_this_poly[j])), as='parsed')
          
          if(!results[[j]]$status=='finished'){
            all_finished <- F
            break
          }
          
          if(!results[[j]]$status %in% c('created','started','finished')){
            output[as.numeric(polygon_id),'message'] <- result$error_message
            tasks[tasks[,'task_id'] %in% tasks_this_poly,'status'] <- results[[j]]$status
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
          for(j in 1:length(tasks_this_poly)){
            pop_sub <- unlist(results[[j]]$data$total)
            
            if(is.numeric(pop_sub)){
              N <- N + pop_sub
            } else {
              N <- NA
            }
          }
          # summarize results and add to output data frame
          output[as.numeric(polygon_id),c('mean','median','lower','upper')] <- as.matrix(summaryPop(N, alpha=alpha, tails=tails))
          output[as.numeric(polygon_id),'message'] <- paste(length(tasks_this_poly),'MultiPolygon')
            
          # update task id status
          tasks[tasks[,'task_id'] %in% tasks_this_poly,'status'] <- 'finished'
        }
      }
      
      # cleanup
      suppressWarnings(rm(N, task_id, polygon_id, tasks_this_poly))
    }
    tasks_remaining <- sum(tasks[,'status'] %in% c('created','started'))
    if(tasks_remaining > 0) Sys.sleep(1/tasks_remaining)
  }
  
  # close connection
  close(url(queue))
  
  # format output
  output <- data.frame(output[order(as.numeric(output[,'polygon_id'])),])

  return(output)
}