# initialize
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T); seed=runif(1,1,42); set.seed(seed)

# # install packages
# devtools::install_github('wpgp/wopr',subdir='pkg')
# devtools::install_github("dr-harper/leaflet.extras")

# load package
library('wopr')

# working directory
setwd(file.path(dirname(rstudioapi::getSourceEditorContext()$path), 'wd'))

# woprVision
woprVision(key='key.txt', woprDir='D:/wopr')



