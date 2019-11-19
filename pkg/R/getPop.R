#' Get population estimate from GRID3 server via API request
#' 
#' @param geojson A geoJSON to represent the polygon where a population estimate is needed
#' @param country The ISO3 country code
#' @param ver Version number of the population estimate
#' @param timeout Seconds until timeout
#' 
#' @return A vector of samples from posterior distribution of the population total. If the task times out the function will return the task ID.
#' 
#' @export

getPop <- function(feature, country, ver, 
                   agesex=c("m0","m1","m5","m10","m15","m20","m25","m30","m35","m40","m45","m50","m55","m60","m65","m70","m75","m80",
                            "f0","f1","f5","f10","f15","f20","f25","f30","f35","f40","f45","f50","f55","f60","f65","f70","f75","f80"),
                   timeout=60){
  
  # use production server? (TRUE=production; FALSE=test)
  production <- F
  if(production) { 
    server <- 'https://api.worldpop.org/v1/grid3/stats'
    queue <- 'https://api.worldpop.org/v1/tasks'
  } else { 
    server <- 'http://10.19.100.66/v1/grid3/popag' 
    queue <- 'http://10.19.100.66/v1/tasks'
  }
  
  gj <- FROM_GeoJson(geojson)
  geometry_type <- gj$features[[1]]$geometry$type
  
  if(geometry_type %in% c('Polygon','MultiPolygon')){
    server <- file.path(server, 'popag')
    
    request <- list(iso3 = country,
                    ver = ver,
                    geojson = geojson,
                    agesex = paste(agesex, collapse=','),
                    key = "wm0LY9MakPSAehY4UQG9nDFo2KtU7POD"
                    )
    
  } else if(geometry_type %in% c('Point','MultiPoint')){
    server <- file.path(server, 'sample')
    
    request <- list(iso3 = country,
                    ver = ver,
                    geojson = geojson,
                    key = "wm0LY9MakPSAehY4UQG9nDFo2KtU7POD"
    )
  }

  
  # send request
  response <- content( POST(url=server, body=request, encode="form"), as='parsed') 
  
  # check status
  result <- content( GET(file.path(queue, response$taskid)), as='parsed')
  
  # note time
  t0 <- Sys.time()
  
  # continue checking status until finished
  while(!result$status=='finished'){
    
    # timeout
    if(difftime(Sys.time(), t0)  > timeout){
      print( paste0('Task timed out after ',timeout," seconds. Use checkTask(\'",response$taskid,"\') to retrieve results later.") )
      return(response$taskid)
      break
    }
    
    # check status
    result <- content( GET(file.path(queue, response$taskid)), as='parsed')
    
    # wait
    Sys.sleep(1)
  }
  
  # return result as vector
  return(unlist(result$data$total))
}