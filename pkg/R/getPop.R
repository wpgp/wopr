#' Get population estimate from GRID3 server via API request
#' 
#' @param geojson A geoJSON to represent the polygon where a population estimate is needed
#' @param iso3 The ISO3 country code
#' @param ver The version of the population estimate
#' 
#' @return A list with the mean, median, lower and upper confidence interval for the population total
#' 
#' @export

getPop <- function(geojson, iso3, ver){
  
  # server url
  server <- 'https://api.worldpop.org/v1/grid3/stats'
  queue <- 'https://api.worldpop.org/v1/tasks'
  
  # format request
  request <- list(iso3 = iso3,
                  ver = ver,
                  geojson = geojson,
                  key= "wm0LY9MakPSAehY4UQG9nDFo2KtU7POD"
                  )
  
  # send request
  response <- POST(url=server, body=request, encode="form")
  
  # format response
  response <- content(response, as='parsed') 
  
  # Check result
  result <- GET( file.path(queue, response$taskid) )
  result <- content(result, as='parsed') 
  
  # check status
  while(!result$status=='finished'){
    result <- GET( file.path(queue, response$taskid) )
    result <- content(result, as='parsed')
    Sys.sleep(1)
  }
  
  return(unlist(result$data$total))
}