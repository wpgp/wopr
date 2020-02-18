#' woprVision: Create a table to store results
#' @description Save results from selected locations
#' @param inp input object from ui
#' @param rval reactiveValues object from server
#' @export 

resultTable <- function(inp, rval){
  
  s <- summaryPop(N=rval$N, 
                  confidence=inp$ci_level/100, 
                  tails=ifelse(inp$ci_type=='Interval',2,1), 
                  abovethresh=inp$popthresh)
  
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
    female_string <- paste(lower, '-', upper)
  } else {
    female_string <- ''
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
    male_string <- paste(lower, '-', upper)
  } else {
    male_string <- ''
  }
  
  if(inp$ci_type=='Interval'){
    Nlow <- s$lower
    Nup <- s$upper
  } else if(inp$ci_type=='Upper Limit'){
    Nlow <- NA
    Nup <- s$upper
  } else if(inp$ci_type=='Lower Limit'){
    Nlow <- s$lower
    Nup <- NA
  }
  
  result <- data.frame(name = inp$save_name,
                       data = inp$data_select,
                       mode = inp$pointpoly,
                       Nmean = s$mean,
                       Nlow = Nlow,
                       Nup = Nup,
                       abovethresh = s$abovethresh,
                       popthresh = inp$popthresh,
                       female_age = female_string,
                       male_age = male_string,
                       confidence_level = paste0(inp$ci_level,'%'),
                       confidence_type = inp$ci_type,
                       geojson = as.character(geojsonio::geojson_json(rval$feature))
                       )
  
  round0_cols <- c('Nmean','Nlow','Nup')
  result[,round0_cols] <- as.integer(result[,round0_cols])
  
  return(result)
}