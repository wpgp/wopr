# initialize
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T); seed=runif(1,1,42); set.seed(seed)

# working directory
setwd('C:/RESEARCH/git/wpgp/wopr')

# input directory
if(T) copyWP(srcdir='Projects/WP517763_GRID3/Working/wopr', outdir='in', OS.type=.Platform$OS.type)

# output directory
dir.create('out', showWarnings=F)

# load packages
devtools::load_all('pkg') # library('wopr')

# polygons from shapefile
features <- st_read(dsn='in/PreEAs_KingKasanDumi_v01', layer='DRC_KinguDumiKasangulu_PreEAs_9km2_INITIAL_v01_classesv3')

# get population totals
totals <- tabulateTotals(features, 
                         country='COD', 
                         ver='1.0',
                         # agesex=c('m0','m1','f0','f1'),
                         confidence=0.90,
                         tails=2,
                         popthresh=1200,
                         spatialjoin=T,
                         timeout=2*60*60,
                         key='wm0LY9MakPSAehY4UQG9nDFo2KtU7POD',
                         production=F
)
totals

# map results
jpeg('out/cod_map.jpg', width=480*1.5, height=480*1.5)
tmap::tm_shape(totals) + tmap::tm_fill('mean', palette='Reds', legend.reverse=T)
dev.off()

# save features to disk as shapefile
st_write(totals, dsn='out', layer='COD_preEAs', driver='Esri Shapefile', delete_dsn=T)

# save results as csv
write.csv(st_drop_geometry(totals), file='out/COD_preEAs.csv', row.names=F)
