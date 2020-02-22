#' Run the woprVision application
#' @description Run the woprVision application to visualize results from the WorldPop Open Population Repository.
#' @return A shiny application will be executed.
#' @export

woprVision <- function(key='key.txt', woprDir='wopr'){
  
  .GlobalEnv$woprDir <- woprDir

  if(is.null(key)){
    .GlobalEnv$key <- key
  } else if(file.exists(as.character(key))){
    .GlobalEnv$key <- dget(as.character(key))
  } else {
    .GlobalEnv$key <- key
  }

  shiny::shinyAppDir(system.file('woprVision', package='wopr'),
                     option = list(launch.browser=T))
}