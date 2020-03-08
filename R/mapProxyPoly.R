#' Map proxy to make changes when polygon mode is selected
#' @description Update map for polygon mode
#' @param pointpoly Tool selection ('Selected Point' or 'Custom Area')
#' @export

mapProxyPoly <- function(pointpoly){
  
  if(pointpoly=='Selected Point'){
    
    # update map
    leafletProxy('map') %>% 
      
      # clear features
      clearShapes() %>%
      clearMarkers() %>%
      
      # remove drawToolbar
      leaflet.extras::removeDrawToolbar(clearFeatures=T) %>%
      
      # hide group
      hideGroup('Custom Area') %>%
      hideGroup('Upload File')
  }
  
  if(pointpoly=='Custom Area'){
    
    # update map
    leafletProxy('map') %>% 
      
      # clear features
      clearShapes() %>%
      clearMarkers() %>%
      
      # hide groups
      hideGroup('Upload File') %>%
      
      # custom polygon controls
      leaflet.extras::addDrawToolbar(
        targetGroup='Custom Area',
        editOptions = leaflet.extras::editToolbarOptions(remove=F),
        singleFeature = TRUE,
        polygonOptions = leaflet.extras::drawPolygonOptions(),
        polylineOptions=F, circleOptions=F, rectangleOptions=F, markerOptions=F, circleMarkerOptions=F
      )  %>%
      
      # show polygon
      showGroup('Custom Area')
  }

  if(pointpoly=='Upload File'){
    
    # update map
    leafletProxy('map') %>% 
      
      # clear marker
      clearMarkers() %>%

      # remove drawToolbar
      leaflet.extras::removeDrawToolbar(clearFeatures=T) %>%
      
      # show group
      showGroup('Upload File')
  }
}
