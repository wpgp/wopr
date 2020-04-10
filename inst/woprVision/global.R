library(wopr);library(leaflet)

# import woprVision_global 
version_info <- wopr:::woprVision_global$version_info
agesex <- wopr:::woprVision_global$agesex
bins <- wopr:::woprVision_global$bins
pal <- wopr:::woprVision_global$pal

version_info <- version_info[version_info$active,]

# check global for objects defined by woprVision()
if(!'wopr_dir' %in% ls()) wopr_dir <- 'wopr'

# toggle development API server
url <- ifelse(F, 'http://10.19.100.66', 'https://api.worldpop.org')

# check for local files
version_info <- checkLocal(wopr_dir, version_info)

# choose initial data set
country <- sample(unique(version_info$country), 1)
version <- version_info[version_info$country==country,'version'][1]
data_init <- paste(country, version, sep=' ')
rm(country, version)
