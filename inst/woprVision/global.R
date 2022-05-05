library(shiny);library(leaflet);library(sf)

# import woprVision_global
version_info <- wopr:::woprVision_global$version_info
palette <- wopr:::woprVision_global$palette

# toggle development API server
dev <- T
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
rm(country, version)

# load dictionnaries for translation

languages <- c('EN', 'FR', 'PT', 'ES')
for (lang in languages) {
  assign(paste0('dict_', lang), yaml::read_yaml(paste0("www/yaml/",lang,".yaml"), fileEncoding="UTF-8"))
}
rm(lang)

keys <- names(dict_EN)

# agesex choices
agesex_choices <- c('<1','1-4','5-9','10-14','15-19','20-24','25-29','30-34','35-39','40-44','45-49','50-54','55-59','60-64','65-69','70-74','75-79','80+')


