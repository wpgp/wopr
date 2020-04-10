#' Run the woprVision application
#' @param wopr_dir Path to WOPR files stored locally.
#' @description Run the woprVision application to visualize results from the WorldPop Open Population Repository.
#' @return A shiny application will be executed.
#' @export

woprVision <- function(wopr_dir='wopr'){
  
  .GlobalEnv$wopr_dir <- wopr_dir

  shiny::shinyAppDir(system.file('woprVision', package='wopr'),
                     option = list(launch.browser=T))
}