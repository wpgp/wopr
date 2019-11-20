# initialize
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T)

# load packages
library('httr')

# function to test api
apiTest <- function(){
  t0 <- Sys.time()
  request <- list(iso3 = 'NGA',
                  ver = '1.2',
                  geojson = '{"type":"FeatureCollection","features":[{"type":"Feature","properties":{},"geometry":{"type":"Polygon","coordinates":[[[3.308258056640625,6.701434474782401],[3.27392578125,6.704162283788004],[3.22723388671875,6.689159145509243],[3.190155029296875,6.6114082535287215],[3.201141357421875,6.5118147063479],[3.264312744140625,6.485889844658782],[3.3563232421875,6.503628052315478],[3.404388427734375,6.558203219021767],[3.37005615234375,6.646875098291585],[3.308258056640625,6.701434474782401]]]}}]}',
                  runasync='true')
  response <- content( POST(url='https://api.worldpop.org/v1/grid3/stats', 
                            body=request, 
                            encode="form"), 
                       as='parsed')
  result <- content( GET(file.path('https://api.worldpop.org/v1/tasks', response$taskid)), 
                     as='parsed')
  while(!result$status %in% c('created','started')){
    result <- content( GET(file.path('https://api.worldpop.org/v1/tasks', response$taskid)), 
                       as='parsed')
  }
  return(list(request=request,
              response=response,
              result=result,
              time=difftime(Sys.time(),t0,units='secs')))
}

# test api
result <- apiTest()

# total time elapsed
result$time

# server execution time
result$response$executionTime

# summarize posterior
summary(unlist(result$response$data$total))

# api request-response
result$request
result$response
