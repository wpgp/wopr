#' Writes the data catalogue to file based on the files currently on the local disk
#' @param outdir Output folder where data from the WorldPop GridFree catalogue are stored
#' @return Writes an updated data catalogue to disk as a .csv file.
#' @export

writeCatalogue <- function(outdir){
  catalogue <- getCatalogue()
  
  files <- basename(list.files(outdir, recursive=T))
  
  catalogue <- catalogue[catalogue$file %in% files,]
  
  write.csv(catalogue, file=file.path(outdir, 'catalogue.csv'), row.names=F)
}