#' Download data from WOPR
#' @param dat Data sets to download provided as row or rows from the data catalogue (see ?getCatalogue)
#' @param outdir Directory where downloads should be saved
#' @return Files are downloaded directly to local disk
#' @export

downloadData <- function(dat, outdir){
  for(i in 1:nrow(dat)){
    dir.create(outdir, showWarnings=F)
    dir.create(file.path(outdir,dat[i,'country']), showWarnings=F)
    dir.create(file.path(outdir,dat[i,'country'], dat[i,'category']), showWarnings=F)
    dir.create(file.path(outdir,dat[i,'country'], dat[i,'category'], dat[i,'version']), showWarnings=F)

    filepath <- file.path(outdir, dat[i,'country'], dat[i,'category'], dat[i,'version'], dat[i,'file'])
    
    if(!file.exists(filepath) | !dat[i,'hash']==md5sum(filepath)){
      print(paste('Downloading:', filepath))
      utils::download.file(url = dat[i,'url'], destfile = filepath, mode="wb",  quiet=FALSE, method="auto")  
    }
  }
  
  writeCatalogue(outdir)
}