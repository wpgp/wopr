#' woprVision: Leaflet map helper
#' @description Display ESRI ImageServer tiles for the Leaflet in woprVision
#' @param map A map widget object created from leaflet()
#' @param url URL of ImageServer tiles server
#' @param layerId tile layer Id
#' @param group The name of the group the newly created layers should belong to
#' @param opacity layer opacity (int between 0 and 1)
#' @return A Leaflet map.
#' @export
#' 
addEsriImageMapLayer <- function(map, url, layerId = NULL, group = NULL, opacity) {
  
  dependancy <-   htmltools::htmlDependency(
    "esri-leaflet",
    version = "3.0.4",
    src = file.path(system.file(package = "wopr"), "htmlwidgets/"),
    script = c("esri-leaflet-prod.js","esri-leaflet-bindings.js")
  )
  
  map$dependencies <- c(map$dependencies,  list(dependancy))
  
  leaflet::invokeMethod(
    map, leaflet::getMapData(map),
    "addEsriImageMapLayer", url, layerId, group, opacity)
  
}


#' woprVision: Leaflet map
#' @description Leaflet map for woprVision.
#' @param country ISO3 code for country to map
#' @param version Version of data set to map
#' @param local_tiles Logical indicating to use locally-stored tiles to display the population raster
#' @param southern Logical indicating if the country is in the southern hemisphere (to use "{-y}" format for Leaflet tiles)
#' @param bins Color bins for legend
#' @param pal Function for legend color palette (see ?leaflet::colorBin)
#' @param dict Dictionnary for text translation
#' @return A Leaflet map.
#' @export

map <- function(country, version, local_tiles=F, southern=F, dev=F,
                bins=wopr:::woprVision_global$bins,
                pal=wopr:::woprVision_global$pal,
                dict=dict_EN) {
  
  m <- leaflet(options = leafletOptions(minZoom=1, maxZoom=17)) %>%
    
    # base maps
    addProviderTiles(provider='Esri.WorldImagery', group='Satellite', options = providerTileOptions(zIndex=1)) %>%
    addProviderTiles(provider='CartoDB.DarkMatter', group='Dark', options = providerTileOptions(zIndex=1)) %>% # 'Esri.WorldGrayCanvas'
    
    # basemap tiles
    addTiles(urlTemplate=ifelse(dir.exists(file.path(wopr_dir,'basemap')),
                                'basemap/{z}/{x}/{y}.png',
                                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'),
             group='Map',
             options=tileOptions(minZoom=1, maxZoom=19, tms=F, zIndex=1),
             attribution='<a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors') %>% 
    
    # layers control
    addLayersControl(baseGroups=c('Dark','Map','Satellite'),
                     overlayGroups=c('Population'),
                     options=layersControlOptions(collapsed=FALSE, autoZIndex=F)) %>%
    
    # population legend
    addLegend(position='bottomright',
              pal=pal,
              values=bins,
              title=dict[["lg_map_legend"]],
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
  
  # population tiles
  if (dev|local_tiles) {
    m %>% 
      addTiles(urlTemplate=ifelse(local_tiles,
                                  paste0('tiles/{z}/{x}/',ifelse(southern,'{-y}','{y}'),'.png'),
                                  file.path('https://tiles.worldpop.org/wopr',
                                            country,
                                            'population',
                                            version,
                                            paste0('population/{z}/{x}/',ifelse(southern,'{-y}','{y}'),'.png'))),
               group='Population',
               layerId='tiles_population',
               options=tileOptions(minZoom=1, maxZoom=14, tms=FALSE, opacity=0.8, zIndex = 3),
               attribution='<a href="http://www.worldpop.org" target="_blank">WorldPop, University of Southampton</a>'
      )
  } else {
    m %>% 
      addEsriImageMapLayer(
        url=paste0("https://gis.worldpop.org/arcgis/rest/services/grid3/",
                   country, "_population_", sub("\\.", "_", version), "_gridded/ImageServer"),
        group='Population', layerId='tiles_population', opacity = 0.8) 
  }
  
  
}

