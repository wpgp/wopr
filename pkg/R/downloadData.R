downloadData <- function(dat, outdir){
  for(i in 1:nrow(dat)){
    dir.create(outdir, showWarnings=F)
    dir.create(file.path(outdir,dat[i,'country']), showWarnings=F)
    dir.create(file.path(outdir,dat[i,'country'], dat[i,'category']), showWarnings=F)
    dir.create(file.path(outdir,dat[i,'country'], dat[i,'category'], dat[i,'version']), showWarnings=F)

    filepath <- file.path(outdir, dat[i,'country'], dat[i,'category'], dat[i,'version'], dat[i,'file'])
    
    if(!file.exists(filepath) | !dat[i,'hash']==md5sum(filepath)){
      utils::download.file(url = dat[i,'url'], destfile = filepath, mode="wb",  quiet=FALSE, method="auto")  
    }
  }
}