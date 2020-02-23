#' Download data from WOPR
#' @param dat Data sets to download provided as a data.frame with at least one row from the wOPR data catalogue (see ?getCatalogue)
#' @param wopr_dir Directory where downloads should be saved
#' @param maxsize Maximum file size (MB) allowed to download without notification
#' @return Files are downloaded directly to local disk
#' @export

downloadData <- function(dat, wopr_dir='wopr', maxsize=100){
  if(nrow(dat)==0 | !class(dat)=='data.frame'){
    stop('"dat" must be a data.frame with at least one row from the WOPR data catalogue. See ?wopr::getCatalogue for help getting the WOPR catalogue.')
  }
  
  dat$category <- tolower(dat$category)
  
  tryCatch({
    for(i in 1:nrow(dat)){
      dir.create(wopr_dir, showWarnings=F)
      dir.create(file.path(wopr_dir,dat[i,'country']), showWarnings=F)
      dir.create(file.path(wopr_dir,dat[i,'country'], dat[i,'category']), showWarnings=F)
      dir.create(file.path(wopr_dir,dat[i,'country'], dat[i,'category'], dat[i,'version']), showWarnings=F)
      
      filepath <- file.path(wopr_dir, dat[i,'country'], dat[i,'category'], dat[i,'version'], dat[i,'file'])
      
      filematch <- dat[i,'hash']==tools::md5sum(filepath)
      
      if(!file.exists(filepath) | !filematch){
        
        # check file size
        fname <- dat[i,'file']
        fsize <- round(dat[i,'file_size']/1024/1024, 1) 
        if(fsize > maxsize){
          
          # exit with warning
          message(paste0(fname,' was not downloaded because it requires ',fsize,' MB of disk space which exceeds maxsize (',maxsize,' MB). See ?wopr::downloadData\n'))
          
        } else {
          
          # download file
          print(paste('Downloading:', filepath))
          utils::download.file(url = dat[i,'url'], 
                               destfile = filepath, 
                               mode="wb",  
                               quiet=FALSE, 
                               method="auto")  
        }
      }
    }
    writeCatalogue(wopr_dir)
    
  }, warning=function(w) print(w), 
  error=function(e) print(paste('WOPR download ran into an error:',e)))
  
  
  
}
