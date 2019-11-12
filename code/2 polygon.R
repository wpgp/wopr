# initialize
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T); set.seed(42)

# working directory
setwd('C:/RESEARCH/git/wpgp/gridFree')

# load packages
devtools::load_all('pkg')

# copy input folder from worldpop
copyWP(srcdir='Projects/WP517763_GRID3/Working/gridFree/in', 
       outdir='in', 
       overwrite=F, 
       OS.type=.Platform$OS.type)



##---- single geojson example ----##

# create geojson
geojson <- '{"type":"FeatureCollection","features":[{"type":"Feature","properties":{},"geometry":{"type":"Polygon","coordinates":[[[3.308258056640625,6.701434474782401],[3.27392578125,6.704162283788004],[3.22723388671875,6.689159145509243],[3.190155029296875,6.6114082535287215],[3.201141357421875,6.5118147063479],[3.264312744140625,6.485889844658782],[3.3563232421875,6.503628052315478],[3.404388427734375,6.558203219021767],[3.37005615234375,6.646875098291585],[3.308258056640625,6.701434474782401]]]}}]}'

# posterior population total
N <- requestPop(geojson=geojson, iso3='NGA', ver='1.2', test=T)

# summarize population total
summaryPop(N, alpha=0.05, tails=2)

# coefficient of variation (standardized measure of uncertainty)
sd(N)/mean(N)

# probability that population exceeds threshold
thresh <- 10e6
mean(N < thresh)



##---- population totals for shapefile polygons ----##

# shapefile with Nigerian local government areas
shapefile <- rgdal::readOGR(dsn='in', layer='lgas')

# population totals for each polygon
totals <- tabulateTotals(shapefile[1:20,], parallel=T, test=T)




