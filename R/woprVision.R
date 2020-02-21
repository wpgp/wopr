#' Run the woprVision application
#' @description Run the woprVision application to visualize results from the WorldPop Open Population Repository.
#' @return A shiny application will be executed.
#' @export

woprVision <- function(key='key.txt', woprDir='wopr'){
  
  .GlobalEnv$woprDir <- file.path(getwd(), woprDir)
  
  if(file.exists(key)){
    .GlobalEnv$key <- dget(key)
  } else {
    .GlobalEnv$key <- key
  }
  
  .GlobalEnv$bins <- wopr:::woprVision_global$bins
  .GlobalEnv$pal <- wopr:::woprVision_global$pal
  .GlobalEnv$agesex <- wopr:::woprVision_global$agesex
  .GlobalEnv$version_info <- wopr:::woprVision_global$version_info
  

  shiny::shinyAppDir(system.file('woprVision', package='wopr'),
                     option = list(launch.browser=T))
}