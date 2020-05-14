#' Submit polygon or point features to WOPR
#' @param features An object of class sf with polygons or points
#' @param country ISO-3 code for the country requested
#' @param agesex_select Character vector of age-sex groups
#' @param url_endpoint The url of the WorldPop API endpoint (see ?endpoint)
#' @param version Version number of population estimates. If NA, defaults to latest version. Acceptable formats include: 'v1.2','1.2', or 1.2.
#' @param key Access key (not required)
#' @param verbose Logical to toggle progress messages
#' @return A data frame with information about each task submitted
#' @export

submitTasks <- function(features, country, url_endpoint, agesex_select=c(paste0('m',c(0,1,seq(5,80,5))),paste0('f',c(0,1,seq(5,80,5)))), version=NA, key='key.txt', verbose=T){

  if(verbose) {
    cat(paste('Submitting',nrow(features),'feature(s) to:\n'))
    cat(paste(' ',url_endpoint,'\n'))
  }

  # get key
  if(file.exists(key)) key <- dget(key)

  # get latest version
  if(is.na(version)){
    catalogue <- getCatalogue(spatial_query=T)
    version <- max(as.numeric(gsub('v','',catalogue[with(catalogue, country==country),'version'])))
  }

  # format version
  version <- gsub('v','',version)

  # geometry type
  features <- sf::st_cast(features)
  if(class(features$geometry)[1] %in% c('sfc_POLYGON','sfc_MULTIPOLYGON')){
    geom_type <- 'polygon'
  } else if(class(features$geometry)[1] %in% c('sfc_POINT','sfc_MULTIPOINT')){
    geom_type <- 'point'
  } else {
    stop('Input feature geometries must be of class "sfc_POLYGON", "sfc_MULTIPOLYGON", "sfc_POINT", or "sfc_MULTIPOINT".')
  }

  # wgs84
  features <- sf::st_transform(features, crs='+proj=longlat +ellps=WGS84')

  # feature ids
  features$feature_id <- 1:nrow(features)

  # data frame to list tasks
  tasks <- matrix(NA,ncol=4,nrow=0)
  colnames(tasks) <- c('feature_id','task_id','status','message')

  # disaggregate multi-part features
  features <- sf::st_cast(features, toupper(geom_type), warn=F)
  
  # check task limit
  task_limit <- 1e3
  if(nrow(features) > task_limit){
    
    warning(paste0('Request exceeded ',task_limit,' tasks. Try subsetting your features.'), call.=F)
    
  } else {
    
    for(i in 1:nrow(features)){
      
      # create request
      if(geom_type=='polygon'){
        request <- list(iso3 = country,
                        ver = version,
                        geojson = suppressWarnings(geojsonio::geojson_json(features[i,])),
                        agesex = paste(agesex_select, collapse=','),
                        key = key
        )
      } else if(geom_type=='point'){
        coords <- sf::st_coordinates(features[i,])
        request <- list(iso3 = country,
                        ver = version,
                        lat = coords[,'Y'],
                        lon = coords[,'X'],
                        agesex = paste(agesex_select, collapse=','),
                        key = key)
        rm(coords)
      }
      if(key=='key.txt') request <- request[-which(names(request)=='key')]
      if(length(agesex_select)==36) request <- request[-which(names(request)=='agesex')]
      
      # send request
      response <- httr::content( httr::POST(url=url_endpoint, body=request, encode="form"), as='parsed')
      
      # save task id
      if(!'taskid' %in% names(response)){
        response$taskid <- NA
      }
      if('error_description' %in% names(response)){
        response$error_message <- response$error_description
      }
      if(is.null(response$error_message)){
        response$error_message <- NA
      }
      if(is.null(response$status) & 'taskid' %in% names(response)){
        response$status <- 'created'
      }
      tasks <- rbind(tasks, data.frame(feature_id = features$feature_id[i],
                                       task_id = response$taskid,
                                       status = response$status,
                                       message = response$error_message))
    }
  }

  # format tasks
  for(i in 1:ncol(tasks)) tasks[,i] <- as.character(tasks[,i])

  return(tasks)
}
