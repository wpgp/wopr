# initialize
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T); seed=runif(1,1,42); set.seed(seed)

# working directory
setwd('C:/RESEARCH/git/wpgp/wopr')

# input directory
if(F) copyWP(srcdir='Projects/WP517763_GRID3/Working/wopr', outdir='in', OS.type=.Platform$OS.type)

# output directory
outdir <- 'out'
dir.create(outdir, showWarnings=F)

# load packages
library('wopr') # devtools::load_all('pkg')

# get data catalogue
catalogue <- getCatalogue()

# download data from entire catalogue
downloadData(catalogue, outdir, dialogue=F)

# download NGA Population v1.0
catalogue_sub <- subset(catalogue, 
                        country == 'NGA' & 
                          category == 'Population' & 
                          version == 'v1.0')
downloadData(catalogue_sub, outdir)

# download first file in catalogue
downloadData(catalogue[1,], outdir)
