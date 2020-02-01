# initialize
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T); seed=runif(1,1,42); set.seed(seed)

# working directory
setwd(file.path(dirname(rstudioapi::getSourceEditorContext()$path),'wd'))

# install dependencies (temporary step until public repo)
install.packages(c('sf','httr','geojsonio'))

# install wopr package
install.packages('../wopr_0.1.0.tar.gz', repos=NULL)

# load package
library('wopr')

# api key (optional)
key <- 'key.txt'

##---- DATA DOWNLOAD ----##

# Get data catalogue
catalogue <- getCatalogue()

View(catalogue)

# Example 1:  Download first file in catalogue
downloadData(catalogue[1,])

# Example 2:  Download subset of catalog: NGA Population v1.2
catalogue_sub <- subset(catalogue, 
                        country == 'NGA' & 
                          category == 'Population' & 
                          version == 'v1.2')
downloadData(catalogue_sub)

# Example 3:  Download all data from catalogue
downloadData(catalogue)


##---- SPATIAL QUERIES ----##

# see available databases for spatial queries
getCatalogue(spatialQuery=T)

# select database
country <- 'NGA'
ver <- '1.2'

# WOPR example data
plot(wopr_points, pch=16)
plot(wopr_polys)

##---- population total for a single point ----##

# get population total
N <- getPop(feature=wopr_points[1,], 
            country=country, 
            ver=ver,
            key=key)

# summarize estimated population total (Bayesian posterior prediction)
summaryPop(N, confidence=0.95, tails=2, popthresh=5)
hist(N)

##---- population of children under five for a single point ----##

# get population total
N <- getPop(feature=wopr_points[1,], 
            country=country, 
            ver=ver,
            agesex=c('f0','f1','m0','m1'),
            key=key)

# summarize population total
summaryPop(N, confidence=0.95, tails=2, popthresh=3)
hist(N)

##---- population estimates for a single polygon ----##

# get population total
N <- getPop(feature=wopr_polys[1,], 
            country=country, 
            ver=ver,
            key=key)

# summarize population total
summaryPop(N, confidence=0.95, tails=2, popthresh=2e5)
hist(N)

##---- population total for children under five in a single polygon ----##

# get population total from WOPR
N <- getPop(feature=wopr_polys[1,], 
            country=country, 
            ver=ver,
            agesex=c('f0','f1','m0','m1'),
            key=key)

# summarize population total
summaryPop(N, confidence=0.95, tails=2, popthresh=2e4)
hist(N)



##---- population estimates for multiple features ----##

# get population totals
totals <- woprize(features=wopr_polys[c(2,5,7),], 
                  country=country, 
                  ver=ver,
                  #agesex=c('m0','m1','f0','f1'),
                  confidence=0.95,
                  tails=2,
                  popthresh=2e4,
                  key=key
                  )
sf::st_drop_geometry(totals)

# save image of mapped results
jpeg('example_map.jpg')
tmap::tm_shape(totals) + tmap::tm_fill('mean', palette='Reds', legend.reverse=T)
dev.off()

# save results as shapefile
sf::st_write(totals, 'example_shapefile.shp')

# save results as csv
write.csv(sf::st_drop_geometry(totals), file='example_spreadsheet.csv', row.names=F)



##---- example polygon from GeoJSON ----##

# geojson as character string
geojson <- '{"type":"FeatureCollection","features":[{"type":"Feature","properties":{},"geometry":{"type":"Polygon","coordinates":[[[3.308258056640625,6.701434474782401],[3.27392578125,6.704162283788004],[3.22723388671875,6.689159145509243],[3.190155029296875,6.6114082535287215],[3.201141357421875,6.5118147063479],[3.264312744140625,6.485889844658782],[3.3563232421875,6.503628052315478],[3.404388427734375,6.558203219021767],[3.37005615234375,6.646875098291585],[3.308258056640625,6.701434474782401]]]}}]}'

# convert to sf
feature <- geojsonsf::geojson_sf(geojson)

# submit query
N <- getPop(feature=feature,
            country=country,
            ver=ver)

summaryPop(N)
hist(N)
