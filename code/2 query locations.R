# initialize
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T); seed=runif(1,1,42); set.seed(seed)

# working directory
script.dir <- dirname(rstudioapi::getSourceEditorContext()$path)
setwd(substr(script.dir, 1, nchar(script.dir)-5)); rm(script.dir)

# input directory
if(F) copyWP(srcdir='Projects/WP517763_GRID3/Working/wopr', outdir='in', OS.type=.Platform$OS.type)

# output directory
dir.create('out', showWarnings=F)

# load packages
library('wopr') # devtools::load_all('pkg')

# api key
key <- 'zWrlmcPDRXWFQbsMHsKUOphSmYTegSrw'

##---- population estimates for a single polygon ----##

# geojson Lagos
geojson <- '{"type":"FeatureCollection","features":[{"type":"Feature","properties":{},"geometry":{"type":"Polygon","coordinates":[[[3.308258056640625,6.701434474782401],[3.27392578125,6.704162283788004],[3.22723388671875,6.689159145509243],[3.190155029296875,6.6114082535287215],[3.201141357421875,6.5118147063479],[3.264312744140625,6.485889844658782],[3.3563232421875,6.503628052315478],[3.404388427734375,6.558203219021767],[3.37005615234375,6.646875098291585],[3.308258056640625,6.701434474782401]]]}}]}'

# geojson Kinshasa
geojson <- '{"type":"FeatureCollection","features":[{"type":"Feature","properties":{},"geometry":{"type":"Polygon","coordinates":[[[15.32661437988281,-4.296771016800865],[15.28575897216797,-4.294374508461301],[15.24250030517578,-4.3245014930191905],[15.22430419921875,-4.426171173838907],[15.334167480468748,-4.447051107498101],[15.376052856445312,-4.367293443949956],[15.32661437988281,-4.296771016800865]]]}}]}'
geojson <- '{"type":"FeatureCollection","features":[{"type":"Feature","properties":{},"geometry":{"type":"Polygon","coordinates":[[[16.94091796875,-4.127285323245357],[17.5341796875,-4.127285323245357],[17.5341796875,-3.5572827265412794],[16.94091796875,-3.5572827265412794],[16.94091796875,-4.127285323245357]]]}}]}'

# convert to sf
feature <- geojsonsf::geojson_sf(geojson)

# get population total
N <- getPop(feature=feature, 
            country='NGA', 
            ver='1.1',
            production=F,
            key=key,
            timeout=60,
            verbose=T)

# summarize population total
summaryPop(N, confidence=0.95, tails=2, popthresh=5e6)

##---- population total for children under five in a single polygon ----##

# get population total from WOPR
N <- getPop(feature=feature, 
            country='NGA', 
            ver=1.2,
            agesex=c('f0','f1','m0','m1'),
            production=F,
            key=key,
            timeout=60,
            verbose=T)

# summarize population total
summaryPop(N, confidence=0.95, tails=2, popthresh=5e6)

##---- point ----##
feature <- suppressWarnings(st_centroid(feature))

feature <- features[6,]

# get population total
N <- getPop(feature=feature, 
            country='NGA', 
            ver=1.2,
            production=F,
            agesex=c('m1','m5','f1','f5'),
            key=key,
            timeout=60,
            verbose=T)

# summarize population total
summaryPop(N, confidence=0.95, tails=2, popthresh=100)


##---- population totals for multiple polygons ----##

# polygons from shapefile
features <- st_read(dsn='in', layer='features')

# get population totals
totals <- woprize(features, 
                         country='NGA', 
                         ver=1.2,
                         # agesex=c('m0','m1','f0','f1'),
                         confidence=0.95,
                         tails=2,
                         popthresh=5e3,
                         spatialjoin=T,
                         timeout=2*60*60,
                         key=key,
                         production=F
                         )
totals

# map results
jpeg('out/map.jpg', width=480*1.5, height=480*1.5)
tmap::tm_shape(totals) + tmap::tm_fill('mean', palette='Reds', legend.reverse=T)
dev.off()

# save features to disk as shapefile
st_write(totals, dsn='out', layer='poptotals', driver='Esri Shapefile', delete_dsn=T)

# save results as csv
write.csv(st_drop_geometry(totals), file='out/poptotals.csv', row.names=F)

##---- population sizes for multiple point locations ----##

# points from shapefile
features <- suppressWarnings(st_centroid(st_read(dsn='in', layer='features')))

# get population totals
totals <- woprize(features, 
                         country='NGA', 
                         ver=1.2,
                         # agesex=c('m0','m1','f0','f1'),
                         confidence=0.95,
                         tails=2,
                         agesex=c('m1','m5','f1','f5'),
                         popthresh=5e3,
                         spatialjoin=T,
                         timeout=2*60*60,
                         key=key,
                         production=F
)

head(totals[,c('mean','median','lower','upper')])