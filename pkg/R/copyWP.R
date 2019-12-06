#' Copy WorldPop folder to your local working directory. 
#' 
#' @description Copy files from WorldPop server to your local working directory. 
#' This allows everyone to work locally with identical inputs.
#'
#' @param srcdir Directory of source files
#' @param outdir Directory to write output files to
#' @param OS.type Type of operating system (see \code{.Platform$OS.type})
#'
#' @return Writes input files to disk
#'
#' @export

copyWP <- function(srcdir, outdir, OS.type='windows'){

  # format server name
  if(.Platform$OS.type=="windows"){
    srcdir <- file.path('//worldpop.files.soton.ac.uk/worldpop', srcdir)
  }
  if(.Platform$OS.type=="unix"){
    srcdir <- file.path('/Volumes/worldpop', srcdir)
  } 

  # check source directory exists
  if(!dir.exists(srcdir)){
    
    print(paste('Source directory does not exist:', srcdir))
    
  } else {
    
    # create output directory
    if(!dir.exists(outdir)) dir.create(outdir, showWarnings=F)

    # create output sub-directories
    ld <- list.dirs(srcdir, full.names=F)[-1]
    for(d in ld){
      dir.create(file.path(outdir, d), showWarnings=F)
    }
    
    # list files
    lf <- list.files(srcdir, recursive=T, include.dirs=F)
    
    # copy files
    for(f in lf){
      
      # copy if destination file does not exist
      toggleCopy <- !file.exists(file.path(outdir,f))
      
      # copy if destination file is different than source file
      if(!toggleCopy){
        if(!md5sum(file.path(srcdir,f))==md5sum(file.path(outdir,f))){
          toggleCopy <- T
        }
      }
      
      # copy the file
      if(toggleCopy){
        print(f)
        file.copy(from=file.path(srcdir,f), to=file.path(outdir,f), overwrite=T)
      }
    }
  }
}
