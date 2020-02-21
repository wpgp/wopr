#' woprVision: Leaflet map
#' @description Leaflet map for woprVision.
#' @return A Leaflet map.
#' @export

map <- function(country, version, localTiles=F) {
  
  leaflet(options = leafletOptions(minZoom=6, maxZoom=17)) %>%
    
    # base maps
    addProviderTiles(provider='Esri.WorldImagery', group='Satellite') %>% 
    addProviderTiles(provider='Esri.NatGeoWorldMap', group='Map') %>%
    addProviderTiles(provider='CartoDB.DarkMatter', group='Dark') %>% # 'Esri.WorldGrayCanvas'
    
    # population tiles
    addTiles(urlTemplate=ifelse(localTiles,
                                'tiles/{z}/{x}/{y}.png',
                                file.path('https://tiles.worldpop.org/wopr',country,'population',version,'population/{z}/{x}/{y}.png')), 
             group='Population',
             layerId='tiles_population',
             options=tileOptions(minZoom=6, maxZoom=14, tms=FALSE, opacity=1),
             attribution='<a href="http://www.worldpop.org">WorldPop, University of Southampton</a>'
             ) %>%
    
    # layers control
    addLayersControl(baseGroups=c('Dark','Map','Satellite'), 
                     overlayGroups=c('Population','Custom Area'),  
                     options=layersControlOptions(collapsed=FALSE, autoZIndex=T)) %>%
    
    # population legend
    addLegend(position='bottomright', 
              pal=pal,
              values=bins,
              title='People per hectare',
              opacity=1,
              group='Population') %>%
    
    # hide groups by default
    hideGroup('Custom Area') %>%
    
    # full zoom out button
    addEasyButton(easyButton(
        icon="fa-globe", title="Zoom Out",
        onClick=JS("function(btn, map){ map.setZoom(7); }"))) %>%
      
    # zoom to country boundary
    setView(lng=version_info[paste(country, version),'lng'],
            lat=version_info[paste(country, version),'lat'],
            zoom=version_info[paste(country, version),'zoom']) %>%
    
    # scale bar
    addScaleBar(position='topleft')
}

