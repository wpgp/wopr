# initialize
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T); seed=runif(1,1,42); set.seed(seed)

# working directory
setwd(file.path(dirname(rstudioapi::getSourceEditorContext()$path),'..'))

# load packages
library('wopr')

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


