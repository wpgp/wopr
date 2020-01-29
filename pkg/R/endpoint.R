#' Get URL for WOPR endpoint
#' @description Depending on your query type (point, polygon, age-sex selection), this function will return the correct API endpoint.
#' @param geometry_class Class of geometry object being submitted
#' @param agesex Logical indicating whether population totals are needed for selected age and sex groups
#' @param production Logical indicating if production or development servers should be used
#' @return A list with urls for the endpoint and the queue
#' @export

endpoint <- function(features=NA, agesex=T, production=F){
  
  if(!'geometry' %in% names(features)){
    
    endpoint <- 'https://wopr.worldpop.org/api/v1.0/data'
    queue <- NA

  } else {
    
    if(class(features$geometry)[1] %in% c('sfc_POLYGON','sfc_MULTIPOLYGON')){
      geom_type <- 'poly'
    } else if(class(features$geometry)[1] %in% c('sfc_POINT','sfc_MULTIPOINT')){
      geom_type <- 'point'
    } else {
      print('Input must be of class sf and include points or polygons')
      break
    }
    
    if(production) { 
      queue <- 'https://api.worldpop.org/v1/tasks'
      server <- 'https://api.worldpop.org/v1/wopr'
    } else if(!production) { 
      queue <- 'http://10.19.100.66/v1/tasks'
      server <- 'http://10.19.100.66/v1/wopr'
    }
    
    if(agesex){
      endpoint <- file.path(server,paste0(geom_type,'agesex'))
    } else{
      endpoint <- file.path(server,paste0(geom_type,'total'))
    }
  }
  
  return(list(endpoint=endpoint, queue=queue))  
}