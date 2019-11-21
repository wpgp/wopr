#' Submit polygon or point features to WOPR
#' @param features An object of class sf with polygons or points
#' @param country ISO-3 code for the country requested
#' @param ver Version number of population estimates
#' @param agesex Character vector of age-sex groups
#' @param url The url of the WorldPop API endpoint
#' @return A data frame with information about each task submitted
#' @export

submitTasks <- function(features, country, ver, agesex, url, key=NA, verbose=T){
  
  if(verbose) print(paste('Submitting',nrow(features),'features to',url,'...'))
  
  # geometry type
  if(class(features$geometry)[1] %in% c('sfc_POLYGON','sfc_MULTIPOLYGON')){
    geom_type <- 'polygon'
  } else if(class(features$geometry)[1] %in% c('sfc_POINT','sfc_MULTIPOINT')){
    geom_type <- 'point'
  }
  
  # feature ids
  features$feature_id <- 1:nrow(features)
  
  # data frame to list tasks
  tasks <- matrix(NA,ncol=4,nrow=0)
  colnames(tasks) <- c('feature_id','task_id','status','message')
  
  # disaggregate multi-part features
  features <- st_cast(features, toupper(geom_type), warn=F)
  
  for(i in 1:nrow(features)){
    
    # create request
    if(geom_type=='polygon'){
      request <- list(iso3 = country,
                      ver = ver,
                      geojson = geojson_json(features[i,]),
                      agesex = paste(agesex, collapse=','),
                      key = key
      )
    } else if(geom_type=='point'){
      coords <- st_coordinates(features[i,])
      request <- list(iso3 = country,
                      ver = ver,
                      lat = coords[,'Y'],
                      lon = coords[,'X'],
                      key = key)
      rm(coords)
    }
    
    # send request
    response <- content( POST(url=url, body=request, encode="form"), as='parsed')
    
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
    if(is.null(response$status)){
      response$status <- 'created'
    }
    tasks <- rbind(tasks, data.frame(feature_id = features$feature_id[i], 
                                     task_id = response$taskid, 
                                     status = response$status, 
                                     message = response$error_message))
  }
  
  # format tasks
  for(i in 1:ncol(tasks)) tasks[,i] <- as.character(tasks[,i])
  
  return(tasks)
}