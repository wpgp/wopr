#' Get WOPR API endpoint
#' @description Returns the WOPR API endpoint based on query type.
#' @param features Features of class "sf" ("sfc_POLYGON", "sfc_MULTIPOLYGON", "sfc_POINT", or "sfc_MULTIPOINT")
#' @param agesex Logical indicating whether population totals are needed for selected age and sex groups
#' @param url API server url
#' @return A list with urls for the endpoint and the queue
#' @export

endpoint <- function(features=NA, agesex=F, url='https://api.worldpop.org/v1'){
  
  queue <- file.path(url,'tasks')
  server <- file.path(url,'wopr')

  if(!'sf' %in% class(features)){
    
    endpoint <- 'https://wopr.worldpop.org/api/v1.0/data'
    
  } else {
    
    if(any(c('sfc_POLYGON','sfc_MULTIPOLYGON') %in% c(class(features$geom), class(features$geometry)))){
      geom_type <- 'poly'
    } else if(any(c('sfc_POINT','sfc_MULTIPOINT') %in% c(class(features$geom), class(features$geometry)))){
      geom_type <- 'point'
    } else {
      stop('Input feature geometries must be of class "sfc_POLYGON", "sfc_MULTIPOLYGON", "sfc_POINT", or "sfc_MULTIPOINT"')
    }
    
    if(agesex){
      endpoint <- file.path(server,paste0(geom_type,'agesex'))
    } else{
      endpoint <- file.path(server,paste0(geom_type,'total'))
    }
  }
  
  return(list(endpoint=endpoint, queue=queue))  
}