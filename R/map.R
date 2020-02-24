#' woprVision: Leaflet map
#' @description Leaflet map for woprVision.
#' @param country ISO3 code for country to map
#' @param version Version of data set to map
#' @param local_tiles Logical indicating to use locally-stored tiles to display the population raster
#' @return A Leaflet map.
#' @export

map <- function(country, version, local_tiles=F) {
  
  leaflet(options = leafletOptions(minZoom=1, maxZoom=17)) %>%
    
    # base maps
    addProviderTiles(provider='Esri.WorldImagery', group='Satellite') %>% 
    addProviderTiles(provider='OpenStreetMap.Mapnik', group='Map') %>% # 'Esri.NatGeoWorldMap'
    addProviderTiles(provider='CartoDB.DarkMatter', group='Dark') %>% # 'Esri.WorldGrayCanvas'
    
    # population tiles
    addTiles(urlTemplate=ifelse(local_tiles,
                                'tiles/{z}/{x}/{y}.png',
                                file.path('https://tiles.worldpop.org/wopr',country,'population',version,'population/{z}/{x}/{y}.png')), 
             group='Population',
             layerId='tiles_population',
             options=tileOptions(minZoom=1, maxZoom=14, tms=FALSE, opacity=0.8),
             attribution='<a href="http://www.worldpop.org" target="_blank">WorldPop, University of Southampton</a>'
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

