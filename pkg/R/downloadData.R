#' Download data from WOPR
#' @param dat Data sets to download provided as row or rows from the data catalogue (see ?getCatalogue)
#' @param outdir Directory where downloads should be saved
#' @param maxsize Maximum file size (MB) allowed to download without notification
#' @param dialogue Logical. If TRUE a dialogue box will ask if you want to download any file that exceeds maxsize
#' @return Files are downloaded directly to local disk
#' @export

downloadData <- function(dat, outdir, maxsize=50, dialogue=T){
  for(i in 1:nrow(dat)){
    dir.create(outdir, showWarnings=F)
    dir.create(file.path(outdir,dat[i,'country']), showWarnings=F)
    dir.create(file.path(outdir,dat[i,'country'], dat[i,'category']), showWarnings=F)
    dir.create(file.path(outdir,dat[i,'country'], dat[i,'category'], dat[i,'version']), showWarnings=F)

    filepath <- file.path(outdir, dat[i,'country'], dat[i,'category'], dat[i,'version'], dat[i,'file'])
    
    if(!file.exists(filepath) | !dat[i,'hash']==md5sum(filepath)){
      
      # check file size
      proceed <- T
      # if(dat[i,'filesize'] > maxsize){
      #   if(dialogue){
      #     message <- paste0('This file requires ',dat[i,'filesize'],' MB of disk space.\nThis exceeds the maximum download size that you selected (',maxsize,' MB).\nDo you want to proceed with the download anyways?')
      #     proceed <- dlgMessage(message, type='yesno')$res=='yes'
      #   } else {
      #     proceed <- F
      #   }
      # }
      if(dat[i,'filetype'] %in% c('sql',unique(catalogue$filetype[grepl('tiles',catalogue$filetype)]))){
        if(dialogue){
          message <- paste0('This file requires more than 50 MB of disk space (up to 20 GB).\nDo you want to proceed with the download anyways?')
          proceed <- dlgMessage(message, type='yesno')$res=='yes'
        } else {
          proceed <- F
        }
      }
      
      # download file
      if(proceed){
        print(paste('Downloading:', filepath))
        utils::download.file(url = dat[i,'url'], 
                             destfile = filepath, 
                             mode="wb",  
                             quiet=FALSE, 
                             method="auto")  
      }
    }
  }
  
  writeCatalogue(outdir)
}
