#' Get population estimate from GRID3 server via API request
#' 
#' @param geojson A geoJSON to represent the polygon where a population estimate is needed
#' @param iso3 The ISO3 country code
#' @param ver The version of the population estimate
#' 
#' @return A vector of samples from posterior distributio of the population total
#' 
#' @export

requestPop <- function(geojson, iso3, ver, timeout=30, test=F){
  
  # api grid3 server url
  if(!test) { 
    server <- 'https://api.worldpop.org/v1/grid3/stats'
    queue <- 'https://api.worldpop.org/v1/tasks'
  } else { 
    server <- 'http://10.19.100.66/v1/grid3/stats' 
    queue <- 'http://10.19.100.66/v1/tasks'
  }
  
  # format request
  request <- list(iso3 = iso3,
                  ver = ver,
                  geojson = geojson,
                  key = "wm0LY9MakPSAehY4UQG9nDFo2KtU7POD"
                  )
  
  # send request
  response <- content( POST(url=server, body=request, encode="form"), as='parsed') 
  
  if(test) print(response)
  
  # check status
  result <- content( GET(file.path(queue, response$taskid)), as='parsed')
  
  if(test) print(result)
  
  # note time
  t0 <- Sys.time()
  
  # continue checking status until finished
  while(!result$status=='finished'){
    
    # timeout
    if((Sys.time() - t0)  > timeout){
      print( paste('Task timed out after',timeout,'seconds (task ID:',response$taskid,')') )
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