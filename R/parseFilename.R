#' Parse WOPR file names
#' @description Parse WOPR file names to return the country, category, version, file type, optional info, and the file extension.
#' @param filenames character vector. WOPR file name.
#' @return data.frame. Table of results.
#' @export

parseFilename <- function(filenames){
  
  if(length(filenames)==0) {
    result <- NA
  } else {
    result <- data.frame(filename=filenames,
                         country = NA,
                         category = NA,
                         version_major = NA,
                         version_minor = NA,
                         version_patch = NA,
                         file_type = NA,
                         file_optional = NA,
                         file_extension = NA
    )
    
    
    testNumeric <- function(y){
      !is.na(suppressWarnings(as.numeric(y)))
    }
    
    for(i in 1:nrow(result)){
      
      x_split <- unlist(strsplit(filenames[i], '_'))
      
      result[i,'country'] <- x_split[1]
      result[i,'category'] <- x_split[2]
      result[i,'version_major'] <- as.numeric(gsub('v','',unlist(strsplit(x_split[3], '-'))[1]))
      
      # version format x-y-z
      if(grepl('-',x_split[3])){
        x3_split <- unlist(strsplit(x_split[3], '-'))
        result[i,'version_minor'] <- x3_split[2]
        if(length(x3_split) > 2){
          result[i,'version_patch'] <- x3_split[3]
        } else {
          result[i,'version_patch'] <- 0
        }
        
      } else {
        result[i,'version_minor'] <- as.numeric(tools::file_path_sans_ext(x_split[4]))
        if(testNumeric(x_split[5])){
          result[i,'version_patch'] <- as.numeric(x_split[5])
        } else {
          result[i,'version_patch'] <- 0
        }
      }
      
      n <- length(x_split)
      if(testNumeric(tools::file_path_sans_ext(x_split[n]))){
        result[i,'file_extension'] <- tools::file_ext(x_split[n])
      } else if(n==4 | testNumeric(x_split[max(1,n-1)])){
        result[i,'file_type'] <- tools::file_path_sans_ext(x_split[n])
        result[i,'file_extension'] <- tools::file_ext(x_split[n])
      } else {
        result[i,'file_type'] <- x_split[max(1,n-1)]
        result[i,'file_optional'] <- tools::file_path_sans_ext(x_split[n])
        result[i,'file_extension'] <- tools::file_ext(x_split[n])
      }
    }
  }
  
  return(result)
}
