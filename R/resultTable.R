#' woprVision: Create a table to store results
#' @description Save results from selected locations
#' @param inp input object from ui
#' @param rval reactiveValues object from server
#' @export 

resultTable <- function(inp, rval){
  
  if(inp$pointpoly=='Upload File'){
    woprized <- T
    s <- sf::st_drop_geometry(rval$feature)
  } else {
    woprized <- F
    s <- summaryPop(N=rval$N, 
                    confidence=inp$ci_level/100, 
                    tails=ifelse(inp$ci_type=='Interval',2,1), 
                    abovethresh=inp$popthresh)
  }
  
  names.result <- c('name','data','mode',
                    'pop','pop_lower','pop_upper','abovethresh','popthresh',
                    'female_age','male_age','confidence_level','confidence_type','geojson')
  
  result <- data.frame(matrix(NA, nrow=nrow(s), ncol=length(names.result)))
  names(result) <- names.result
  
  result$name <- ifelse(woprized, s[,1], inp$save_name)
  result$data <- inp$data_select
  result$mode <- inp$pointpoly
  result$popthresh <- inp$popthresh
  result$confidence_level = paste0(inp$ci_level,'%')
  result$confidence_type = inp$ci_type
  
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
  
  if(inp$ci_type=='Interval'){
    result$pop_lower <- s$lower
    result$pop_upper <- s$upper
  } else if(inp$ci_type=='Upper Limit'){
    result$pop_lower <- NA
    result$pop_upper <- s$upper
  } else if(inp$ci_type=='Lower Limit'){
    result$pop_lower <- s$lower
    result$pop_upper <- NA
  }

  for(i in 1:nrow(result)){
    result[i,'pop'] <- s[i,'mean']
    result[i,'pop_lower'] <- s[i,'lower']
    result[i,'pop_upper'] <- s[i,'upper']
    result[i,'abovethresh'] <- s[i,'abovethresh']
    result[i,'geojson'] <- as.character(geojsonio::geojson_json(rval$feature[i,]))
  }
  result$pop <- as.integer(round(result$pop))
  result$pop_lower <- as.integer(round(result$pop_lower))
  result$pop_upper <- as.integer(round(result$pop_upper))
  
  return(result)
}