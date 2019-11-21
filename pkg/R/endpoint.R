#' Identify url for appropriate WOPR endpoint
#' @param geometry_class Class of geometry object being submitted
#' @param agesex Logical indicating whether population totals are needed for selected age-sex groups
#' @param production Logical indicating if production or development servers should be used
#' @return A list with urls for the endpoint and the queue
#' @export

endpoint <- function(geometry_class, agesex=T, production=F){
  
  if(geometry_class %in% c('sfc_POLYGON','sfc_MULTIPOLYGON')){
    geom_type <- 'polygon'
  } else if(geometry_class %in% c('sfc_POINT','sfc_MULTIPOINT')){
    geom_type <- 'point'
  } else {
    print('Input must be of class sf and include points or polygons')
    break
  }
  
  if(production) { 
    queue <- 'https://api.worldpop.org/v1/tasks'
    server <- 'https://api.worldpop.org/v1/grid3'
  } else if(!production) { 
    queue <- 'http://10.19.100.66/v1/tasks'
    server <- 'http://10.19.100.66/v1/grid3'
  }
  
  endpoint <- NA
  if(geom_type=='point'){
    if(!agesex){
      endpoint <- file.path(server,'sample')
    }
  } 
  if(geom_type=='polygon'){
    if(!agesex){
      endpoint <- file.path(server,'stats')
    } 
    if(agesex & !production){
      endpoint <- file.path(server,'popag')
    } 
  }
  if(is.na(endpoint)) print('No end point.')
  
  return(list(endpoint=endpoint, queue=queue))  
}