# initialize
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T); set.seed(42)

# working directory
script.dir <- dirname(rstudioapi::getSourceEditorContext()$path)
setwd(substr(script.dir, 1, nchar(script.dir)-5)); rm(script.dir)

# install package
devtools::document('pkg')
pkgbuild::build('pkg')
install.packages(list.files(pattern='.tar.gz'), repos=NULL)

# load package
library('wopr')
