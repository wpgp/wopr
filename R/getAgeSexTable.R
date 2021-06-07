#' Get region-specific age sex proportions either through WOPR API or locally
#' @description Query WOPR API to get region-specific age and sex proportions
#' @param country The ISO3 country code
#' @param version Version number of the population estimate
#' @param agesexid Character age sex id 
#' @param url Server url (optional)
#' @param local Local path for age sex table (optional)
#' @return A vector of samples from posterior distribution of the population total. If the task times out the function will return the task ID.
#' @export

getAgeSexTable <- function(country, version=NA, agesexid, url='https://api.worldpop.org/v1', local_path=""){
  
  if(nchar(local_path)>1) {
    table <- read.csv(local_path)
    table <- table[which(table["id"]==agesexid),]
    
  } else {
  
  version <- gsub('v','',version)
  
  queue <- file.path(url,'tasks')
  server <- file.path(url,'wopr')
  endpoint <- file.path(server, "proportionsagesex")
  
  request <- list(iso3 = country,
                  ver = version,
                  id = agesexid
  )
  
  response <- httr::content( httr::POST(url=endpoint, body=request, encode="form"), as='parsed')
  
  table <- t(as.data.frame(unlist(response$data[[agesexid]])))
  row.names(table) <- ""
  }
  
  return(table)
}
