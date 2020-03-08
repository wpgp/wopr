#' Map proxy to make changes when a GeoJSON is uploaded
#' @description Update map for polygon mode
#' @param features sf features
#' @export

mapProxyFile <- function(features){
  
  # feature bounding box
  bbox <- sf::st_bbox(features)
  
  # update map
  leafletProxy('map') %>% 
    
    # add polygons
    addPolygons(data=features, group='Custom Area') %>%
    
    # show polygon
    showGroup('Custom Area') %>%
    
    # fit bounds
    fitBounds(lng1=bbox$xmin, lng2=bbox$xmax, lat1=bbox$ymin, lat2=bbox$ymax)
}



