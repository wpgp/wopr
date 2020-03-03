library(leaflet)

# import woprVision_global 
bins <- wopr:::woprVision_global$bins
pal <- wopr:::woprVision_global$pal
agesex <- wopr:::woprVision_global$agesex
version_info <- wopr:::woprVision_global$version_info

# check global for objects defined by woprVision()
if(!'wopr_key' %in% ls()) wopr_key <- 'key.txt'
if(!'wopr_dir' %in% ls()) wopr_dir <- 'wopr'
if(!'local_mode' %in% ls()) local_mode <- FALSE

# wopr url
url <- 'https://api.worldpop.org'
# url <- 'http://10.19.100.66'

# retrieve catalogue
if(local_mode){
  catalogue_full <- read.csv(system.file('extdata', 'wopr_catalogue.csv', package='wopr', mustWork=T), stringsAsFactors=F) 
} else {
  catalogue_full <- getCatalogue()
}
catalogue <- subset(catalogue_full,
                    category=='Population' & filetype=='sql',
                    c('country','version'))  
catalogue <- with(catalogue, catalogue[order(country, -as.numeric(gsub('v','',version))),])
row.names(catalogue) <- with(catalogue, paste(country, version))

# check for local files
checkLocal <- function(dir, info){
  info$local_sql <- info$local_tiles <- FALSE
  if(dir.exists(dir)){
    for(i in 1:nrow(info)){
      path <- file.path(dir,info$country[i],'population',info$version[i])
      prefix <- paste0(info$country[i],'_population_',gsub('.','_',as.character(info$version[i]), fixed=T),'_')
      sql_path <- paste0(file.path(path, prefix),'sql.sql')
      mastergrid_path <- paste0(file.path(path,prefix),'mastergrid.tif')
      tile_path <- paste0(file.path(path, prefix), 'tiles')
      if(file.exists(sql_path) & file.exists(mastergrid_path)) {
        info[i,'local_sql'] <- TRUE}
      if(dir.exists(tile_path)){
        info[i,'local_tiles'] <- TRUE}
    }
  }
  return(info)
}

version_info <- checkLocal(wopr_dir, version_info)

if(local_mode & sum(version_info$local_sql)==0){
  stop('No local SQL databases available in "',wopr_dir,'" to run woprVision in local mode. See ?wopr::downloadData or https://wopr.worldpop.org', call.=F)
} else if(local_mode){
  catalogue <- catalogue[row.names(version_info)[version_info$local_sql],]
}

# choose initial data set
country <- sample(unique(catalogue$country), 1)
version <- catalogue[catalogue$country==country,'version'][1]
data_init <- paste(country, version, sep=' ')
rm(country, version)

# functions
getmode <- function(x) {
  uniqx <- unique(x)
  return(uniqx[which.max(tabulate(match(x, uniqx)))])
}

# cleanup
onStop(function() {
  gc()
})

