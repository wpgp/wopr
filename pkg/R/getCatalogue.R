#' Get the WorldPop GridFree data catalogue
#' 
#' @return A data frame with a row for each item in the data catalogue.
#' 
#' @export

getCatalogue <- function(){
  
  server <- 'http://grid3data.worldpop.uk/api/v1.0/data'
  
  response <- content( GET(server), as='parsed')
  
  cols <- c('country','category','version', 'filetype', names(response[[1]][[1]][[1]][[1]]))
  result <- data.frame(matrix(NA, ncol=length(cols), nrow=0))
  names(result) <- cols
  
  for(iso in names(response)){
    for(category in names(response[[iso]])){
      for(version in names(response[[iso]][[category]])){
        for(filetype in names(response[[iso]][[category]][[version]])){
          newrow <- data.frame(matrix(NA, ncol=length(cols), nrow=0))
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
  return(result)
}