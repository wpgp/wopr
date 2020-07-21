library(shiny);library(leaflet);library(sf)

# import woprVision_global
version_info <- wopr:::woprVision_global$version_info
agesex <- wopr:::woprVision_global$agesex
palette <- wopr:::woprVision_global$palette

# toggle development API server
dev <- TRUE
if(dev){
  url <- 'http://10.19.100.66/v1'
  version_info$active <- T
} else {
  url <- 'https://api.worldpop.org/v1'
}

version_info <- version_info[as.logical(version_info$active),]

# maximum file upload size
options(shiny.maxRequestSize = 50*1024^2)

# check global for objects defined by woprVision()
if(!'wopr_dir' %in% ls()) wopr_dir <- 'wopr'

# check for local files
version_info <- checkLocal(wopr_dir, version_info)

# choose initial data set
country <- sample(unique(version_info$country), 1)
version <- version_info[version_info$country==country & version_info$deprecated==F,'version'][1]
data_init <- paste(country, version, sep=' ')
rm(country, version)
