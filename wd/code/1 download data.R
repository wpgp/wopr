# initialize
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T); seed=runif(1,1,42); set.seed(seed)

# working directory
script.dir <- dirname(rstudioapi::getSourceEditorContext()$path)
setwd(substr(script.dir, 1, nchar(script.dir)-5)); rm(script.dir)

# input directory
if(F) copyWP(srcdir='Projects/WP517763_GRID3/Working/wopr', outdir='in', OS.type=.Platform$OS.type)

# load packages
library('wopr') # devtools::load_all('pkg')

# get data catalogue
catalogue <- getCatalogue()

# download all data from entire catalogue
downloadData(catalogue, outdir='out/wopr_downloads')

# download NGA Population v1.0
catalogue_sub <- subset(catalogue, 
                        country == 'NGA' & 
                          category == 'Population' & 
                          version == 'v1.2')
downloadData(catalogue_sub)

# download first file in catalogue
downloadData(catalogue[1,], outdir)
