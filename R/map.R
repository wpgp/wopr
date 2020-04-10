#' woprVision: Leaflet map
#' @description Leaflet map for woprVision.
#' @param country ISO3 code for country to map
#' @param version Version of data set to map
#' @param local_tiles Logical indicating to use locally-stored tiles to display the population raster
#' @param southern Logical indicating if the country is in the southern hemisphere (to use "{-y}" format for Leaflet tiles)
#' @return A Leaflet map.
#' @export

map <- function(country, version, local_tiles=F, southern=F) {
  
  leaflet(options = leafletOptions(minZoom=1, maxZoom=17)) %>%
    
    # base maps
    addProviderTiles(provider='Esri.WorldImagery', group='Satellite') %>% 
    addProviderTiles(provider='CartoDB.DarkMatter', group='Dark') %>% # 'Esri.WorldGrayCanvas'

    # basemap tiles
    addTiles(urlTemplate=ifelse(dir.exists(file.path(wopr_dir,'basemap')),
                                'basemap/{z}/{x}/{y}.png',
                                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'),
             group='Map',
             options=tileOptions(minZoom=1, maxZoom=19, tms=F),
             attribution='<a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors') %>%
    
    # population tiles
    addTiles(urlTemplate=ifelse(local_tiles,
                                paste0('tiles/{z}/{x}/',ifelse(southern,'{-y}','{y}'),'.png'),
                                file.path('https://tiles.worldpop.org/wopr',
                                          country,
                                          'population',
                                          version,
                                          paste0('population/{z}/{x}/',ifelse(southern,'{-y}','{y}'),'.png'))), 
             group='Population',
             layerId='tiles_population',
             options=tileOptions(minZoom=1, maxZoom=14, tms=FALSE, opacity=0.8),
             attribution='<a href="http://www.worldpop.org" target="_blank">WorldPop, University of Southampton</a>'
             ) %>%
    
    # layers control
    addLayersControl(baseGroups=c('Dark','Map','Satellite'), 
                     overlayGroups=c('Population'),  
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
    hideGroup('Upload File') %>%
    
    # zoom to data extent
    fitBounds(lng1 = version_info[paste(country, version),'xmin'],
              lng2 = version_info[paste(country, version),'xmax'],
              lat1 = version_info[paste(country, version),'ymin'],
              lat2 = version_info[paste(country, version),'ymax']) %>%

    # scale bar
    addScaleBar(position='topleft')
}

