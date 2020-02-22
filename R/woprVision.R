#' Run the woprVision application
#' @description Run the woprVision application to visualize results from the WorldPop Open Population Repository.
#' @return A shiny application will be executed.
#' @export

woprVision <- function(key='key.txt', woprDir='wopr'){
  
  .GlobalEnv$woprDir <- woprDir

  if(file.exists(key)){
    .GlobalEnv$key <- dget(key)
  } else {
    .GlobalEnv$key <- NULL
  }

  shiny::shinyAppDir(system.file('woprVision', package='wopr'),
                     option = list(launch.browser=T))
}