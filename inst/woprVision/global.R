library(leaflet)

# wopr url
url <- 'https://api.worldpop.org'
# url <- 'http://10.19.100.66'

# retrieve catalogue
catalogue_full <- getCatalogue()
catalogue <- subset(catalogue_full,
                    category=='Population' & filetype=='sql',
                    c('country','version'))  
catalogue <- with(catalogue, catalogue[order(country, -as.numeric(gsub('v','',version))),])

# choose initial data set
country <- sample(unique(catalogue$country), 1)
version <- catalogue[catalogue$country==country,'version'][1] 
data_init <- paste(country,version,sep=' ')
rm(country, version)

# check global
if(!'key' %in% ls()) key <- 'key.txt'
if(!'woprDir' %in% ls()) woprDir <- normalizePath('wopr')

# load woprVision global environment
list2env(woprVision_global, globalenv())

# check for local files
checkLocal <- function(dir, info){
  
  info$localSql <- info$localTiles <- FALSE
  
  if(dir.exists(dir)){
    for(i in 1:nrow(info)){
      path <- file.path(dir,
                        info$country[i],
                        'population',
                        info$version[i])
      prefix <- paste0(info$country[i],
                       '_population_',
                       gsub('.','_',as.character(info$version[i]), fixed=T),
                       '_')
      
      sql_path <- paste0(file.path(path, prefix),'sql.sql')
      mastergrid_path <- paste0(file.path(path,prefix),'mastergrid.tif')
      if(file.exists(sql_path) & file.exists(mastergrid_path)) {
        info[i,'localSql'] <- TRUE
      }
      
      tile_path <- paste0(file.path(path, prefix), 'tiles')
      if(dir.exists(tile_path)){
        info[i,'localTiles'] <- TRUE
      }
    }
  }
  return(info)
}

version_info <- checkLocal(woprDir, version_info)

# functions
getmode <- function(x) {
  uniqx <- unique(x)
  return(uniqx[which.max(tabulate(match(x, uniqx)))])
}
