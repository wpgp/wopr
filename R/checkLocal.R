#' Check for local WOPR files
#' @description Check for local files required to run woprVision in local mode (without internet connection)
#' @param dir Directory where WOPR files are stored
#' @param info Data "version_info" object to update with local files (see wopr:::woprVision_global$version_info)
#' @export

checkLocal <- function(dir, info=wopr:::woprVision_global$version_info){
  
  info$local_sql <- info$local_tiles <- info$local_mastergrid <- FALSE
  
  if(dir.exists(dir)){
    for(i in 1:nrow(info)){
      
      path <- file.path(dir,info$country[i],'population',info$version[i])
      
      if(dir.exists(path)){
        
        parsed <- parseFilename(list.files(path))
        
        if(any(parsed$file_type=='sql') & any(parsed$file_type=='mastergrid')){
          info[i,'local_sql'] <- TRUE
          info[i,'local_sql_path'] <- file.path(path, parsed[which(parsed$file_type=='sql'),'filename'])
          info[i,'local_mastergrid_path'] <- file.path(path, parsed[which(parsed$file_type=='mastergrid'),'filename'])
        }
        
        if(any(parsed$file_type=='tiles' & parsed$file_extension=='')){
          info[i,'local_tiles'] <- TRUE
          info[i,'local_tiles_path'] <- file.path(path, parsed[which(parsed$file_type=='tiles' & parsed$file_extension==''),'filename'])
        } else if(any(parsed$file_type=='tiles' & parsed$file_extension=='zip')){
          warning(paste('Tiles for',info$country[i],info$version[i],'still need to be unzipped.'), call.=F)
        }
      }
    }
  }
  
  return(info)
}
