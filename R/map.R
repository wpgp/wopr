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
addEsriImageMapLayer <- function(map, url, layerId = NULL, group = NULL,  options = NULL) {
  
  dependancy <-   htmltools::htmlDependency(
    "esri-leaflet",
    version = "3.0.4",
    src = file.path(system.file(package = "wopr"), "htmlwidgets/"),
    script = c("esri-leaflet-prod.js","esri-leaflet-bindings.js")
  )
  if (is.null(options)) {
    options <- list()
  }
  map$dependencies <- c(map$dependencies,  list(dependancy))
  
  leaflet::invokeMethod(
    map, leaflet::getMapData(map),
    "addEsriImageMapLayer", url, layerId, group,  options)
  
}


#' woprVision: Leaflet map
#' @description Leaflet map for woprVision.
#' @param country ISO3 code for country to map
#' @param version Version of data set to map
#' @param dict Dictionary for text translation
#' @param token Token generated for access to password-protected datasets
#' @return A Leaflet map.
#' @export

map <- function(country, version, 
                dict=dict_EN,
                token = NULL) {
  
  #get legend
  esri_legend <-  sapply(httr::content( httr::GET(
    paste0("https://gis.worldpop.org/arcgis/rest/services/grid3/",
           country, "_population_", sub("\\.", "_", version), "_gridded/ImageServer/legend?f=json"),
    httr::add_headers(Authorization = paste("Bearer", token , sep = " "))
  ))[[1]][[1]]$legend, '[[', 1)
  
  bins <-  c(
    sapply(esri_legend[-length(esri_legend)], function(x) as.integer(strsplit(x, '-')[[1]][1])),
    as.integer(substr(esri_legend[length(esri_legend)], start=1, stop=nchar(esri_legend[length(esri_legend)])-1)))
  
  bins <- c(
    bins,
    round(max(bins[length(bins)] + diff(bins[c(length(bins)-1, length(bins))]),
              version_info[paste(country, version),'popmax']))
  )
    
  pal <- leaflet::colorBin(palette=woprVision_global$palette$cols[2:nrow(woprVision_global$palette)],
                    bins=bins,
                    na.color=woprVision_global$palette$cols[1],
                    domain=1:1000, pretty=F, alpha=T, reverse=F)
  
  m <- leaflet(options = leafletOptions(minZoom=1, maxZoom=17)) %>%
    
    # base maps
    addProviderTiles(provider='Esri.WorldImagery', group='Satellite', options = providerTileOptions(zIndex=1)) %>%
    addProviderTiles(provider='CartoDB.DarkMatter', group='Dark', options = providerTileOptions(zIndex=1)) %>% # 'Esri.WorldGrayCanvas'
    
    # basemap tiles
    addTiles(urlTemplate='https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
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
  m %>% 
    addEsriImageMapLayer(
      url=paste0("https://gis.worldpop.org/arcgis/rest/services/grid3/",
                 country, "_population_", sub("\\.", "_", version), "_gridded/ImageServer"),
      group='Population', layerId='tiles_population', options= leaflet::filterNULL(list(opacity=0.8, token=token))
    )
  
}

