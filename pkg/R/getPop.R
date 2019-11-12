#' Get population estimate from GRID3 server via API request
#' 
#' @param gj A geoJSON to represent the polygon where a population estimate is needed
#' @param country The ISO3 country code
#' @param ver Version number of the population estimate
#' @param timeout Seconds until timeout
#' @param test Logical indicating whether to use the test server or production server
#' 
#' @return A vector of samples from posterior distribution of the population total. If the task times out the function will return the task ID.
#' 
#' @export

getPop <- function(gj, country, ver, timeout=30){
  
  # choose api server url (TRUE=production; FALSE=test)
  if(FALSE) { 
    server <- 'https://api.worldpop.org/v1/grid3/stats'
    queue <- 'https://api.worldpop.org/v1/tasks'
  } else { 
    server <- 'http://10.19.100.66/v1/grid3/stats' 
    queue <- 'http://10.19.100.66/v1/tasks'
  }
  
  # format request
  request <- list(iso3 = country,
                  ver = ver,
                  geojson = gj,
                  key = "wm0LY9MakPSAehY4UQG9nDFo2KtU7POD"
                  )
  
  # send request
  response <- content( POST(url=server, body=request, encode="form"), as='parsed') 
  
  # check status
  result <- content( GET(file.path(queue, response$taskid)), as='parsed')
  
  # note time
  t0 <- Sys.time()
  
  # continue checking status until finished
  while(!result$status=='finished'){
    
    # timeout
    if((Sys.time() - t0)  > timeout){
      print( paste('Task timed out after',timeout,'seconds. Use checkTask(',response$taskid,') to retrieve results later.') )
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