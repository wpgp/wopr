#' Check for local WOPR files
#' @description Check for local files required to run woprVision in local mode (without internet connection)
#' @param dir Directory where WOPR files are stored
#' @param info Data "version_info" object to update with local files (see wopr:::woprVision_global$version_info)
#' @export

checkLocal <- function(dir, info=wopr:::woprVision_global$version_info){
  
  info$local_sql <- info$local_tiles <- FALSE
  
  if(dir.exists(dir)){
    for(i in 1:nrow(info)){
      
      path <- file.path(dir,info$country[i],'population',info$version[i])
      
      prefix <- paste0(info$country[i],
                       '_population_',
                       gsub('.','_',as.character(info$version[i]), fixed=T),'_')
      
      sql_path <- paste0(file.path(path, prefix),'sql.sql')
      mastergrid_path <- paste0(file.path(path,prefix),'mastergrid.tif')
      tile_path <- paste0(file.path(path, prefix), 'tiles')
      
      if(file.exists(sql_path) & file.exists(mastergrid_path)) {
        info[i,'local_sql'] <- TRUE}
      if(dir.exists(tile_path)){
        info[i,'local_tiles'] <- TRUE}
    }
  }
  return(info)
}