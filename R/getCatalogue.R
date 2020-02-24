#' WOPR data catalogue
#' @description Get a complete listing of data in the WOPR data catalogue.
#' @param spatial_query Logical. If TRUE will return the data sets that support a spatial query (i.e. contain an SQL database). If FALSE will return the entire data catalogue.
#' @return A data frame with a row for each item in the data catalogue.
#' @export

getCatalogue <- function(spatial_query=F){
  
  server <- endpoint()$endpoint
  
  response <- httr::content( httr::GET(server), as='parsed')
  
  cols <- c('country','category','version', 'filetype', names(response[[1]][[1]][[1]][[1]]))
  result <- data.frame(matrix(NA, ncol=length(cols), nrow=0))
  names(result) <- cols
  
  for(iso in names(response)){
    for(category in names(response[[iso]])){
      for(version in names(response[[iso]][[category]])){
        for(filetype in names(response[[iso]][[category]][[version]])){
          newrow <- data.frame(matrix(NA, ncol=length(cols), nrow=1))
          names(newrow) <- cols
          
          newrow[1,c('country','category','version','filetype')] <- c(iso, category, version, filetype)
          
          for(attribute in names(response[[iso]][[category]][[version]][[filetype]])){
            value <- response[[iso]][[category]][[version]][[filetype]][[attribute]]
            if(!is.null(value)){
              newrow[1, attribute] <- value  
            }
          }
          result <- rbind(result, newrow)
        }
      }
    }
  }
  # # get file sizes
  # result[,'filesize'] <- NA
  # for(i in 1:nrow(result)){
  #   result[i,'filesize'] <- as.numeric(strsplit(strsplit(getURL(result[i,'url'], nobody=1L, header=1L), "\r\n")[[1]][15], ' ')[[1]][2]) / 1024 / 1024
  # }
  
  if(spatial_query){
    result <- result[result$filetype=='sql',c('country','version')]
  }
  
  return(result)
}