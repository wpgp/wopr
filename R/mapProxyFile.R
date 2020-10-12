#' Map proxy to make changes when a GeoJSON is uploaded
#' @description Update map for polygon mode
#' @param features sf features
#' @export

mapProxyFile <- function(features=NULL){
  
  if(is.null(features)){
    # update map
    leafletProxy('map') %>% 
      
      # clear old polygons
      clearGroup('Upload File')
  }
  
  else {
    
    # feature bounding box
    bbox <- sf::st_bbox(features)
    
    if(class(features$geometry)[1] %in% c('sfc_POLYGON','sfc_MULTIPOLYGON')){
      
      # update map
      leafletProxy('map') %>% 
        
        # clear old polygons
        clearGroup('Upload File') %>%
        
        # add polygons
        addPolygons(data=features, 
                    group='Upload File') %>%
        
        # fit bounds
        setView(lng=mean(bbox[c('xmin','xmax')]),
                lat=mean(bbox[c('ymin','ymax')]),
                zoom=8)
    }
    
    if(class(features$geometry)[1] %in% c('sfc_POINT','sfc_MULTIPOINT')){
      
      # update map
      leafletProxy('map') %>% 
        
        # clear old points
        clearGroup('Upload File') %>%
        
        # add points
        addCircles(data=features, radius=56, weight=15, opacity=0.75,
                   group='Upload File') %>%
        
        # fit bounds
        setView(lng=mean(bbox[c('xmin','xmax')]),
                lat=mean(bbox[c('ymin','ymax')]),
                zoom=8)
    }
  }
}



