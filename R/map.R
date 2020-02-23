#' woprVision: Leaflet map
#' @description Leaflet map for woprVision.
#' @return A Leaflet map.
#' @export

map <- function(country, version, localTiles=F) {
  
  leaflet(options = leafletOptions(minZoom=1, maxZoom=17)) %>%
    
    # base maps
    addProviderTiles(provider='Esri.WorldImagery', group='Satellite') %>% 
    # addProviderTiles(provider='Esri.NatGeoWorldMap', group='Map') %>%
    # addProviderTiles(provider='CartoDB.DarkMatter', group='Dark') %>% # 'Esri.WorldGrayCanvas'
    
    # DarkMatter tiles
    addTiles(urlTemplate='https://api.maptiler.com/maps/darkmatter/{z}/{x}/{y}.png?key=gVR5ppSzDLVxvDV30OUT',
             attribution='<a href="https://www.maptiler.com/copyright/" target="_blank">© MapTiler</a> <a href="https://www.openstreetmap.org/copyright" target="_blank">© OpenStreetMap contributors</a>',
             group='Dark',
             tileOptions(minZoom=1, maxZoom=14, tms=FALSE, opacity=1)) %>%
    
    # OSM tiles
    addTiles(urlTemplate='https://api.maptiler.com/maps/basic/{z}/{x}/{y}.png?key=gVR5ppSzDLVxvDV30OUT',
             attribution='<a href="https://www.maptiler.com/copyright/" target="_blank">© MapTiler</a> <a href="https://www.openstreetmap.org/copyright" target="_blank">© OpenStreetMap contributors</a>',
             group='Map',
             tileOptions(minZoom=1, maxZoom=14, tms=FALSE, opacity=1)) %>%
    
    # population tiles
    addTiles(urlTemplate=ifelse(localTiles,
                                'tiles/{z}/{x}/{y}.png',
                                file.path('https://tiles.worldpop.org/wopr',country,'population',version,'population/{z}/{x}/{y}.png')), 
             group='Population',
             layerId='tiles_population',
             options=tileOptions(minZoom=1, maxZoom=14, tms=FALSE, opacity=0.6),
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

