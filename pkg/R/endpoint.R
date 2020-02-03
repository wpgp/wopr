#' Get WOPR API endpoint
#' @description Returns the WOPR API endpoint based on query type.
#' @param features Features of class "sf" ("sfc_POLYGON", "sfc_MULTIPOLYGON", "sfc_POINT", or "sfc_MULTIPOINT")
#' @param agesex Logical indicating whether population totals are needed for selected age and sex groups
#' @return A list with urls for the endpoint and the queue
#' @export

endpoint <- function(features=NA, agesex=F){
  
  if(!class(features)[1]=='sf'){
    
    endpoint <- 'https://wopr.worldpop.org/api/v1.0/data'
    queue <- 'https://api.worldpop.org/v1/tasks'

  } else {
    
    if(class(features$geometry)[1] %in% c('sfc_POLYGON','sfc_MULTIPOLYGON')){
      geom_type <- 'poly'
    } else if(class(features$geometry)[1] %in% c('sfc_POINT','sfc_MULTIPOINT')){
      geom_type <- 'point'
    } else {
      print('Input feature geometries must be of class "sfc_POLYGON", "sfc_MULTIPOLYGON", "sfc_POINT", or "sfc_MULTIPOINT"')
      break
    }
    
    if(file.exists('srv.txt')) {
      source('srv.txt')
    } else {
      queue <- 'https://api.worldpop.org/v1/tasks'
      server <- 'https://api.worldpop.org/v1/wopr'
    }
    
    if(agesex){
      endpoint <- file.path(server,paste0(geom_type,'agesex'))
    } else{
      endpoint <- file.path(server,paste0(geom_type,'total'))
    }
  }
  
  return(list(endpoint=endpoint, queue=queue))  
}