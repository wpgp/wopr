#' Map proxy to make changes when a GeoJSON is uploaded
#' @description Update map for polygon mode
#' @param features sf features
#' @param map_zoom current leaflet map zoom level
#' @export

mapProxyFile <- function(features, map_zoom){
  
  # feature bounding box
  bbox <- sf::st_bbox(features)

  # update map
  leafletProxy('map') %>% 
    
    # add polygons
    addPolygons(data=features, group='Upload File') %>%
    
    # fit bounds
    setView(lng=mean(bbox[c('xmin','xmax')]), 
            lat=mean(bbox[c('ymin','ymax')]), 
            zoom=max(map_zoom, 9))
}



