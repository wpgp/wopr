library(shiny);library(leaflet);library(sf)

# import woprVision_global
version_info <- wopr:::woprVision_global$version_info

# toggle development API server
dev <- F
if(dev){
  url <- 'http://152.78.226.148/v1'
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

# split into review/default
version_info_default <- version_info[which(version_info$under_review==F),]

# choose initial data set
country <- sample(unique(version_info_default$country), 1)
version <- version_info_default[version_info_default$country==country & version_info_default$deprecated==F,'version'][1]
data_init <- paste(country, version, sep=' ')
agesex_choices <- getAgeSexNames(getAgeSexTable(country, version))
rm(country, version)

# load dictionnaries for translation

languages <- c('EN', 'FR', 'PT', 'ES')
for (lang in languages) {
  assign(paste0('dict_', lang), yaml::read_yaml(paste0("www/yaml/",lang,".yaml"), fileEncoding="UTF-8"))
}
rm(lang)

keys <- names(dict_EN)
