library(shiny);library(leaflet);library(sf)

# import woprVision_global
version_info <- wopr:::woprVision_global$version_info
agesex <- wopr:::woprVision_global$agesex
palette <- wopr:::woprVision_global$palette

# toggle development API server
dev <- FALSE
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

# load dictionnaries for translation
dict_en <- yaml::read_yaml("www/yaml/EN.yaml")
dict_fr <- yaml::read_yaml("www/yaml/FR.yaml", fileEncoding="UTF-8")
dict_pt <- yaml::read_yaml("www/yaml/PT.yaml", fileEncoding="UTF-8")
dict_es <- yaml::read_yaml("www/yaml/ES.yaml", fileEncoding="UTF-8")
# dict_zh <- yaml::read_yaml("www/yaml/ZH.yaml", fileEncoding="UTF-8")
keys <- names(dict_en)

# agesex choices
agesex_choices <- c('<1','1-4','5-9','10-14','15-19','20-24','25-29','30-34','35-39','40-44','45-49','50-54','55-59','60-64','65-69','70-74','75-79','80+')


