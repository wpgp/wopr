#' Tabulate population totals for polygons
#' 
#' @param shapes SpatialPolygonsDataFrame with polygons to calculate population totals
#' 
#' @return The SpatialPolygonsDataFrame with population totals added into columns: meanPop, medianPop, lowerPop, upperPop
#' 
#' @export

tabulateTotals <- function(shapes){
  
  # column names
  cols <- c('meanPop','medianPop','lowerPop','upperPop')
  
  # prepare new columns
  shapes@data[, cols] <- NA
  
  # loop through features
  for(i in 1:nrow(shapes)){
    
    print(paste0(i,'/',nrow(shapes)))
    
    # get posteriors for population total in feature i
    N <- requestPop(geojson = geojsonio::geojson_json(shapes[i,]), 
                iso3 = 'NGA', 
                ver = '1.2')
    
    # add summary statistics to data frame
    shapes[i,cols] <- summaryPop(N, alpha=0.05, tails=2)
  }
  
  return(shapes)
}