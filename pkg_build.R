# initialize
rm(list=ls()); gc()

# working directory
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# install package
devtools::document('pkg')
pkgbuild::build('pkg')
