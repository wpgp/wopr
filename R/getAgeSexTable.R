#' Get country-specific age sex proportions either through WOPR API or locally
#' @description Get country-and-version-specific age and sex proportions through querying WOPR API or uploading local age sex table
#' @param country The ISO3 country code
#' @param version Version number of the population estimate
#' @param locator Server url or local path to age sex table (optional)
#' @return A table with age and sex proportions for the selected country and version
#' @export

getAgeSexTable <- function(country, version=NA, locator='https://api.worldpop.org/v1'){
  
  if(!grepl('http', locator)) {
    table <- read.csv(locator)

  } else {
  
  version <- gsub('v','',version)
  
  queue <- file.path(locator,'tasks')
  server <- file.path(locator,'wopr')
  endpoint <- file.path(server, "proportionsagesex")
  
  request <- list(iso3 = country,
                  ver = version,
                  id = 'null'
  )
  
  response <- httr::content( httr::POST(url=endpoint, body=request, encode="form"), as='parsed')
  
  table <- data.frame(do.call(rbind.data.frame, response$data))
  table$id <- names(response$data)

  }
  
  return(table)
}
