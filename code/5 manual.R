# initialize
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T)

# load packages
library('httr')

# polygon feature
geojson <- '{"type":"FeatureCollection","features":[{"type":"Feature","properties":{},"geometry":{"type":"Polygon","coordinates":[[[3.308258056640625,6.701434474782401],[3.27392578125,6.704162283788004],[3.22723388671875,6.689159145509243],[3.190155029296875,6.6114082535287215],[3.201141357421875,6.5118147063479],[3.264312744140625,6.485889844658782],[3.3563232421875,6.503628052315478],[3.404388427734375,6.558203219021767],[3.37005615234375,6.646875098291585],[3.308258056640625,6.701434474782401]]]}}]}'
feature <- geojsonsf::geojson_sf(geojson)

# point feature
feature <- suppressWarnings(st_centroid(feature))

# agesex
agesex <- c("m0","m1","m5","m10","m15","m20","m25","m30","m35","m40","m45","m50","m55","m60","m65","m70","m75","m80",
            "f0","f1","f5","f10","f15","f20","f25","f30","f35","f40","f45","f50","f55","f60","f65","f70","f75","f80")

# get endpoint
wopr_url <- endpoint(feature, agesex=T)

# create request
if(class(feature$geometry)[1] %in% c('sfc_POINT', 'sfc_MULTIPOINT')){
  request <- list(iso3='NGA', 
                  ver='1.2',
                  lat=1,
                  lon=1,
                  # agesex=paste(c('m1','m5','f1','f5'),collapse=','),
                  key='wm0LY9MakPSAehY4UQG9nDFo2KtU7POD')
} else if(class(feature$geometry)[1] %in% c('sfc_POLYGON', 'sfc_MULTIPOLYGON')){
  request <- list(iso3='NGA', 
                  ver='1.2',
                  geojson='{"type":"FeatureCollection","features":[{"type":"Feature","properties":{},"geometry":{"type":"Polygon","coordinates":[[[3.308258056640625,6.701434474782401],[3.27392578125,6.704162283788004],[3.22723388671875,6.689159145509243],[3.190155029296875,6.6114082535287215],[3.201141357421875,6.5118147063479],[3.264312744140625,6.485889844658782],[3.3563232421875,6.503628052315478],[3.404388427734375,6.558203219021767],[3.37005615234375,6.646875098291585],[3.308258056640625,6.701434474782401]]]}}]}',
                  agesex=paste(c('m1','m5','f1','f5'),collapse=','),
                  key='wm0LY9MakPSAehY4UQG9nDFo2KtU7POD')
}

# get response
response <- content( POST(url=wopr_url$endpoint, body=request, encode="form"), as='parsed')

# get result
result <- content( GET(file.path(wopr_url$queue, response$taskid)), as='parsed')

# get result if not finished
while(result$status %in% c('created','started')){
  result <- content( GET(file.path(wopr_url$queue, response$taskid)), as='parsed')
}

# summarize posterior
x <- unlist(result$result$data$total)
summary(x)

# check result
round(mean(x))==5040498

# total time elapsed
result$time

# server execution time
result$result$executionTime

# transfer time
result$time - result$result$executionTime

# api request-response-result
result$request
result$response
result$result
