rm(list=ls()); gc()
setwd(dirname(rstudioapi::getSourceEditorContext()$path))
devtools::document('pkg')
pkgbuild::build('pkg')
