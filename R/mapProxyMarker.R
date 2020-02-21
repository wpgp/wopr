#' Leaflet map proxy to update on map click
#' @description Leaflet map proxy that zooms to map click and drops a pin.
#' @return A n updated leaflet map.
#' @export
mapProxyMarker <- function(pointpoly, map_click, map_zoom){
  
  if(pointpoly=='Selected Point'){
    
    # click location
    x <- map_click$lng
    y <- map_click$lat
    
    # update map
    leafletProxy('map') %>% 
      
      # clear old marker
      clearMarkers() %>%
      
      # add new marker
      addMarkers(lng=x, lat=y, 
                 popup = paste('Long:',round(x,4),'<br/>Lat:',round(y,4)),
                 labelOptions = list(noHide=TRUE, textsize=14), 
                 popupOptions = list(keepInview=T),
                 group='selected') %>%
      
      # center and zoom
      setView(lng=x, lat=y, zoom=max(map_zoom, 10, na.rm=T))
      # flyTo(lng=x, lat=y, zoom=max(map_zoom, 10, na.rm=T))
  }
}

