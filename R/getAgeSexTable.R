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

#' Extract agesex group labels from an agesex table
#'
#' @param agesex_table Table retrieved with getAgeSexTable
#'
#' @return
#' @export

getAgeSexNames <-  function(agesex_table){
  # extract colname for one sex (female)
  agesex_names <- colnames(agesex_table)[grepl('f[0-9]{1,2}$',colnames(agesex_table))] 
  ages <- as.integer(gsub('f', '',agesex_names))
  # transform last group as open ended
  agesex_choices <- c(paste(ages[-length(ages)], ages[-1]-1, sep='-'), paste0(max(ages), '+'))
  # relabel the under1
  if(any(grepl('0-0', agesex_choices))){
    agesex_choices <- gsub('0-0', '<1', agesex_choices)
  }
  
  return(agesex_choices)
}
