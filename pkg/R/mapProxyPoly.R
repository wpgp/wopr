#' Map proxy to make changes when polygon mode is selected
#' @description Update map for polygon mode
#' @param pointpoly Tool selection ('Selected Point' or 'Custom Area')
#' @export

mapProxyPoly <- function(pointpoly){
  
  if(pointpoly=='Custom Area'){
    
    # update map
    leafletProxy('map') %>% 
      
      # clear marker
      clearMarkers() %>%
      
      # custom polygon controls
      addDrawToolbar(
        targetGroup='Custom Area',
        editOptions = editToolbarOptions(),
        singleFeature = TRUE,
        polygonOptions = drawPolygonOptions(),
        polylineOptions=F, circleOptions=F, rectangleOptions=F, markerOptions=F, circleMarkerOptions=F
      )  %>%
      
      # show polygon
      showGroup('Custom Area')
  }
  
  if(pointpoly=='Selected Point'){
    
    # update map
    leafletProxy('map') %>% 
      
      # remove drawToolbar
      removeDrawToolbar(clearFeatures=T) %>%

      # hide group
      hideGroup('Custom Area')
  }
}
