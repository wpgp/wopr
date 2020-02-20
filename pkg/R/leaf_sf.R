#' Convert a leaflet drawn polygon to shapefile
#' @description Convert leaflet polygon to sf_POLYGONS
#' @param geometry leaflet polygon
#' @param pointpoly location selection mode ('Selected Point' or 'Custom Area')
#' @export

leaf_sf <- function(geometry, pointpoly='Selected Point'){
  result <- NULL
  try({
    if(pointpoly=='Selected Point' & !is.null(geometry)){
      
      result <- sf::st_point(c(geometry$lng, geometry$lat),'XY')
      result <- sf::st_sfc(geom=result, crs=4326)
      result <- data.frame(id=1,result)
      result <- sf::st_sf(result)
      
    } else if(pointpoly=='Custom Area' & length(geometry$features)>0){
      
      geometry <- geometry$features[[1]]$geometry
      xy <- matrix(NA, ncol=2, nrow=length(geometry$coordinates[[1]]))
      for (i in 1:nrow(xy)){
        xy[i,1] <- geometry$coordinates[[1]][[i]][[1]]
        xy[i,2] <- geometry$coordinates[[1]][[i]][[2]]
      }
      result <- sf::st_polygon(list(xy))
      result <- sf::st_sfc(geom=result, crs=4326)
      result <- data.frame(id=1,result)
      result <- sf::st_sf(result)
    }
  })
  
  if(!class(result)[1]=='sf'){
    result <- NULL
  }
  
  return(result)
}