# initialize
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T)
seed=runif(1,1,42); set.seed(seed)

# working directory
setwd('C:/RESEARCH/git/wpgp/gridFree')

# load packages
devtools::load_all('pkg')

# # copy input folder from worldpop
# copyWP(srcdir='Projects/WP517763_GRID3/Working/gridFree/in', 
#        outdir='in', 
#        OS.type=.Platform$OS.type)

# output folder
outdir <- 'out'
dir.create(outdir, showWarnings=F)

# get data catalogue
catalogue <- getCatalogue()

# download data from entire catalogue
downloadData(catalogue, outdir)

# download NGA Population v1.0
catalogue_sub <- subset(catalogue, 
                        country == 'NGA' & 
                          category == 'Population' & 
                          version == 'v1.0')
downloadData(catalogue_sub, outdir)

# download first file in catalogue
downloadData(catalogue[1,], outdir)
