#' Run the woprVision application
#' @param key (optional) API access key (character) or a path to a text file that contains the key in quotations (e.g. "iqRvecPORXiFQbsMesKUOPhSmaTegpoT")
#' @param wopr_dir Path to WOPR files stored locally.
#' @param local_mode Logical indicating to run woprVision in local mode when internet access is not available.
#' @description Run the woprVision application to visualize results from the WorldPop Open Population Repository.
#' @return A shiny application will be executed.
#' @export

woprVision <- function(key='key.txt', wopr_dir='wopr', local_mode=F){
  
  .GlobalEnv$wopr_dir <- wopr_dir
  .GlobalEnv$local_mode <- local_mode

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