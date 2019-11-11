# initialize
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T); set.seed(42)

# working directory
setwd('C:/RESEARCH/git/wpgp/gridFree')

# output folder for download
outdir <- 'out'
dir.create(outdir, showWarnings=F)

# load packages
devtools::load_all('pkg')

# copy input folder from worldpop
copyWP(srcdir='Projects/WP517763_GRID3/Working/gridFree/in', 
       outdir='in', 
       overwrite=F, 
       OS.type=.Platform$OS.type)

# get data catalogue
catalogue <- getCatalogue()

# view data catalogue
View(catalogue)

# save data catalogue
write.csv(catalogue, file=file.path(outdir,'catalogue.csv'), row.names=F)

# download entire catalogue
downloadData(catalogue, outdir)

# download NGA Population v1.0
catalogue_sub <- catalogue[catalogue$country=='NGA' & catalogue$category=='Population' & catalogue$version=='v1.0',]
downloadData(catalogue_sub, outdir)

# download first item in catalogue
downloadData(catalogue[1,], outdir)

# download first and second item in catalogue
downloadData(catalogue[1:2,], outdir)

