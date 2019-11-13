#' Get population estimate from GRID3 server via API request
#' 
#' @param gj A geoJSON to represent the polygon where a population estimate is needed
#' @param country The ISO3 country code
#' @param ver Version number of the population estimate
#' @param timeout Seconds until timeout
#' 
#' @return A vector of samples from posterior distribution of the population total. If the task times out the function will return the task ID.
#' 
#' @export

getPop <- function(gj, country, ver, timeout=30){
  
  # use production server? (TRUE=production; FALSE=test)
  production <- F
  if(production) { 
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
  
  # close server connection
  close(url(server))
  
  # check status
  result <- content( GET(file.path(queue, response$taskid)), as='parsed')
  
  # note time
  t0 <- Sys.time()
  
  # continue checking status until finished
  while(!result$status=='finished'){
    
    # timeout
    if((Sys.time() - t0)  > timeout){
      print( paste0('Task timed out after ',timeout,' seconds. Use checkTask("',response$taskid,'") to retrieve results later.') )
      return(response$taskid)
      break
    }
    
    # check status
    result <- content( GET(file.path(queue, response$taskid)), as='parsed')
    
    # wait
    Sys.sleep(1)
  }
  
  # close queue connection
  close(url(queue))
  
  # return result as vector
  return(unlist(result$data$total))
}