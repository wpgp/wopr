#' woprVision: Create a table to store results
#' @description Save results from selected locations
#' @param inp input object from ui
#' @param rval reactiveValues object from server
#' @export 

resultTable <- function(inp, rval){
  
  s <- summaryPop(N = rval$N, 
                  confidence = inp$ci_level/100, 
                  tails = ifelse(inp$ci_type=='Interval',2,1), 
                  abovethresh = inp$popthresh,
                  round_result = FALSE)
  
  names.result <- c('name','data','mode',
                    'pop','pop_lower','pop_upper','abovethresh','popthresh',
                    'female_age','male_age','confidence_level','confidence_type','message','geojson')
  
  result <- data.frame(matrix(NA, nrow=nrow(s), ncol=length(names.result)))
  names(result) <- names.result
  
  result$name <- inp$save_name

  result$data <- inp$data_select
  result$mode <- inp$pointpoly
  result$popthresh <- inp$popthresh
  result$confidence_level <- paste0(inp$ci_level,'%')
  result$confidence_type <- inp$ci_type
  
  if(!is.null(s$message)) result$message <- s$message
  
  if(inp$female){
    if(inp$female_select[1]=='<1'){
      lower <- 0
    } else if(inp$female_select[1]=='80+'){
      lower <- 80
    } else {
      lower <- min(strsplit(inp$female_select[1], '-')[[1]])
    }
    if(inp$female_select[2]=='<1'){
      upper <- 1
    } else if(inp$female_select[2]=='80+'){
      upper <- '80+'
    } else {
      upper <- max(strsplit(inp$female_select[2], '-')[[1]])
    }
    result$female_age <- paste(lower,'-',upper)
  } else {
    result$female_age <- ''
  }
  
  if(inp$male){
    if(inp$male_select[1]=='<1'){
      lower <- 0
    } else if(inp$male_select[1]=='80+'){
      lower <- 80
    } else {
      lower <- min(strsplit(inp$male_select[1], '-')[[1]])
    }
    if(inp$male_select[2]=='<1'){
      upper <- 1
    } else if(inp$male_select[2]=='80+'){
      upper <- '80+'
    } else {
      upper <- max(strsplit(inp$male_select[2], '-')[[1]])
    }
    result$male_age <- paste(lower, '-', upper)
  } else {
    result$male_age <- ''
  }
  
  # if(inp$ci_type=='Interval'){
  #   result$pop_lower <- s$lower
  #   result$pop_upper <- s$upper
  # } else if(inp$ci_type=='Upper Limit'){
  #   result$pop_lower <- NA
  #   result$pop_upper <- s$upper
  # } else if(inp$ci_type=='Lower Limit'){
  #   result$pop_lower <- s$lower
  #   result$pop_upper <- NA
  # }

  for(i in 1:nrow(result)){
    result[i,'pop'] <- s[i,'mean']
    result[i,'pop_lower'] <- s[i,'lower']
    result[i,'pop_upper'] <- s[i,'upper']
    result[i,'abovethresh'] <- s[i,'abovethresh']
    
    result[i,'geojson'] <- as.character(geojsonio::geojson_json(rval$feature[i,]))
  }
  
  if(inp$ci_type=='Upper Limit'){
    result$pop_lower <- NA
  } else if(inp$ci_type=='Lower Limit'){
    result$pop_upper <- NA
  }
  
  # result$pop <- as.integer(round(result$pop))
  # result$pop_lower <- as.integer(round(result$pop_lower))
  # result$pop_upper <- as.integer(round(result$pop_upper))
  
  result$pop <- ifelse(s$mean > 5, 
                       as.integer(round(result$pop)), 
                       round(result$pop,3))
  result$pop_lower <- ifelse(s$mean > 5, 
                             as.integer(round(result$pop_lower)), 
                             round(result$pop_lower,3))
  result$pop_upper <- ifelse(s$mean > 5, 
                             as.integer(round(result$pop_upper)), 
                             round(result$pop_upper,3))
  return(result)
}