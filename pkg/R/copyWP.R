#' Copy WorldPop folder to your local working directory. 
#' 
#' @description Copy files from WorldPop server to your local working directory. 
#' This allows everyone to work locally with identical inputs.
#'
#' @param srcdir Directory of source files
#' @param outdir Directory to write output files to
#' @param overwrite Logical indicating to overwrite local files if they already exist
#' @param OS.type Type of operating system (see \code{.Platform$OS.type})
#'
#' @return Writes input files to disk
#'
#' @export

copyWP <- function(srcdir, outdir, overwrite=F, OS.type='windows'){

  # format server name
  if(.Platform$OS.type=="windows"){
    srcdir <- file.path('//worldpop.files.soton.ac.uk/worldpop', srcdir)
  }
  if(.Platform$OS.type=="unix"){
    srcdir <- file.path('/Volumes/worldpop', srcdir)
  } 

  if(!dir.exists(srcdir)){
    
    print(paste('Source directory does not exist:', srcdir))
    
  } else {
    
    # create output directory
    if(!dir.exists(outdir)) dir.create(outdir, showWarnings=F)

    # list files
    lf <- list.files(srcdir, recursive=T, include.dirs=T)

    # copy files
    for(f in lf){
      
      if(overwrite | !file.exists(file.path(srcdir,f))) print(f)
      
      file.copy(from=file.path(srcdir,f), to=file.path(outdir), overwrite=overwrite)
    }
  }
}
