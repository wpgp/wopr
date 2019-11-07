library(httr)

geojson_example <-'{"type":"FeatureCollection","features":[{"type":"Feature","properties":{},"geometry":{"type":"Polygon","coordinates":[[[3.308258056640625,6.701434474782401],[3.27392578125,6.704162283788004],[3.22723388671875,6.689159145509243],[3.190155029296875,6.6114082535287215],[3.201141357421875,6.5118147063479],[3.264312744140625,6.485889844658782],[3.3563232421875,6.503628052315478],[3.404388427734375,6.558203219021767],[3.37005615234375,6.646875098291585],[3.308258056640625,6.701434474782401]]]}}]}'

form_r <- list(
  iso3 = "NGA",
  ver = "1.2",
  geojson = geojson_example,
  key= "wm0LY9MakPSAehY4UQG9nDFo2KtU7POD"
)

res <- POST("https://api.worldpop.org/v1/grid3/stats", body = form_r, encode = "form", verbose())

# you will get a respond that task is created with taskid
jsonRespParsed <- content(res,as="parsed")

# Check results using taskid (this can be done in a loop checking the status	"finished" jsonResp_Check_Parsed$status)

Check.results <- function(taskid) 
{
  return( 
    GET( paste0("https://www.api.worldpop.org/v1/tasks/",taskid))
  )  
}

time_limit <- 360
while (time_limit > 0 )
{
  res_check <- Check.results(jsonRespParsed$taskid) 
  jsonResp_Check_Parsed <- content(res_check,as="parsed")
  
  if (jsonResp_Check_Parsed$status == "finished") {
    break
  }else{
    time_limit <- time_limit - 1
    print( paste0("Cheking results. It took ", (360 - time_limit), " sec"))
    Sys.sleep(1)
  }
  
}

print(jsonResp_Check_Parsed$data)



