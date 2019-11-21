# initialize
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T); seed=runif(1,1,42); set.seed(seed)

# working directory
setwd('C:/RESEARCH/git/wpgp/wopr')

# input directory
if(F) copyWP(srcdir='Projects/WP517763_GRID3/Working/wopr', outdir='in', OS.type=.Platform$OS.type)

# output directory
dir.create('out', showWarnings=F)

# load packages
library('wopr') # devtools::load_all('pkg')

##---- population estimates for a single polygon ----##

# geojson
geojson <- '{"type":"FeatureCollection","features":[{"type":"Feature","properties":{},"geometry":{"type":"Polygon","coordinates":[[[3.308258056640625,6.701434474782401],[3.27392578125,6.704162283788004],[3.22723388671875,6.689159145509243],[3.190155029296875,6.6114082535287215],[3.201141357421875,6.5118147063479],[3.264312744140625,6.485889844658782],[3.3563232421875,6.503628052315478],[3.404388427734375,6.558203219021767],[3.37005615234375,6.646875098291585],[3.308258056640625,6.701434474782401]]]}}]}'

# convert to sf
feature <- geojsonsf::geojson_sf(geojson)

# get population total
N <- getPop(feature=feature, 
            country='NGA', 
            ver=1.2,
            production=F,
            key='wm0LY9MakPSAehY4UQG9nDFo2KtU7POD',
            timeout=60)

# summarize population total
summaryPop(N, alpha=0.05, tails=2, popthresh=5e6)

##---- population total for children under five in a single polygon ----##

# get population total from WOPR
N <- getPop(feature=feature, 
            country='NGA', 
            ver=1.2,
            agesex=c('f1','f5','m1','m5'),
            production=F,
            key='wm0LY9MakPSAehY4UQG9nDFo2KtU7POD',
            timeout=60)

# summarize population total
summaryPop(N, alpha=0.05, tails=2, popthresh=5e6)


##---- population totals for multiple polygons ----##

# polygons from shapefile
features <- st_read(dsn='in', layer='features')

# get population totals
totals <- tabulateTotals(features, 
                         country='NGA', 
                         ver=1.2,
                         # agesex=c('m0','m1','f0','f1'),
                         alpha=0.05,
                         tails=2,
                         popthresh=5e3,
                         spatialjoin=T,
                         timeout=2*60*60,
                         key='wm0LY9MakPSAehY4UQG9nDFo2KtU7POD',
                         production=F
                         )
head(totals[,c('mean','median','lower','upper')])

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
totals <- tabulateTotals(features, 
                         country='NGA', 
                         ver=1.2,
                         # agesex=c('m0','m1','f0','f1'),
                         alpha=0.05,
                         tails=2,
                         popthresh=5e3,
                         spatialjoin=T,
                         timeout=2*60*60,
                         key='wm0LY9MakPSAehY4UQG9nDFo2KtU7POD',
                         production=F
)

head(totals[,c('mean','median','lower','upper')])