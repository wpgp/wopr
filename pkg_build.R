# initialize
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T); set.seed(42)

# working directory
setwd(file.path(dirname(rstudioapi::getSourceEditorContext()$path)))

# install package
devtools::document('pkg')
pkgbuild::build('pkg')
install.packages(list.files(pattern='.tar.gz'), repos=NULL)
