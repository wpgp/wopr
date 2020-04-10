#' Get cell ids from point or polygon
#' @description Returns cell ids for a polygon or point location that can be used to query a WOPR SQL database.
#' @param feature An object of class sf with a polygon or point
#' @param mastergrid A mastergrid raster downloaded from WOPR
#' @return A numeric vector containing cell IDs
#' @export

cellids <- function(feature, mastergrid){
  
  # keep only first feature
  feature <- feature[1,]
  
  # get cell ids
  if(class(feature$geometry)[1] %in% c('sfc_POLYGON','sfc_MULTIPOLYGON')){
    
    x <- which(!is.na(raster::values(fasterize::fasterize(feature, mastergrid))))
    
  } else if(class(feature$geometry)[1] %in% c('sfc_POINT','sfc_MULTIPOINT')){
    
    x <- raster::cellFromXY(mastergrid, sf::st_coordinates(feature))
  } else {
    
    stop('feature must be class "sf" (sfc_POLYGON, sfc_MULTIPOLYGON, sfc_POINT, or sfc_MULTIPOINT.')
  }
  
  # result
  return(x)
}