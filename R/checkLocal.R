#' Check for local WOPR files
#' @description Check for local files required to run woprVision in local mode (without internet connection)
#' @param dir Directory where WOPR files are stored
#' @param info Data "version_info" object to update with local files (see wopr:::woprVision_global$version_info)
#' @export

checkLocal <- function(dir, info=wopr:::woprVision_global$version_info){
  
  info$local_sql <- info$local_tiles <- info$local_mastergrid <- info$local_agesex_table <-  FALSE
  
  if(dir.exists(dir)){
    for(i in 1:nrow(info)){
      
      path <- file.path(dir,info$country[i],'population',info$version[i])
      
      if(dir.exists(path)){
        
        parsed <- parseFilename(list.files(path))
        
        # check mastergrid
        if(any(parsed$file_type=='mastergrid')){
          info[i,'local_mastergrid'] <- TRUE
          info[i,'local_mastergrid_path'] <- file.path(path, parsed[which(parsed$file_type=='mastergrid'),'filename'])
        } 
        
        # check SQL
        if(any(parsed$file_type=='sql')){
          info[i,'local_sql'] <- TRUE
          info[i,'local_sql_path'] <- file.path(path, parsed[which(parsed$file_type=='sql'),'filename'])
        } 
        
        # check age-sex table
        if(any(parsed$file_type=='agesex'& parsed$file_extension=='' )){
          
          info[i,'local_agesex_table_path'] <- file.path(path, 
                                                         parsed[which(parsed$file_type=='agesex'& parsed$file_extension==''),'filename'],
                                                         paste0(parsed[which(parsed$file_type=='agesex'& parsed$file_extension==''),'filename'], "_table.csv"))
          
          if(file.exists(info[i,'local_agesex_table_path'])){
            
            info[i,'local_agesex_table'] <- TRUE
            
          } else {
            
            warning(paste('Age sex table for',
                          row.names(info)[i],
                          'not found in ', file.path(path, 
                                                     parsed[which(parsed$file_type=='agesex'& parsed$file_extension==''),'filename'])))
            
          }
        } 
        
        # check tiles
        if(any(parsed$file_type=='tiles' & parsed$file_extension=='')){
          info[i,'local_tiles'] <- TRUE
          info[i,'local_tiles_path'] <- file.path(path, parsed[which(parsed$file_type=='tiles' & parsed$file_extension==''),'filename'])
        } else if(any(parsed$file_type=='tiles' & parsed$file_extension=='zip')){
          warning(paste('Tiles for',info$country[i],info$version[i],'may still need to be unzipped.'), call.=F)
        }
      }
    }
  }
  
  return(info)
}
