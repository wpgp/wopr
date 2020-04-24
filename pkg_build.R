# cleanup
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T); .libPaths('c:/research/r/library')

# working directory
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

##-- package documentation --##

# functions
devtools::document()

# render README to HTML
rmarkdown::render(input='README.md',
                  output_format=c('html_document'),
                  output_file='README.html',
                  output_dir=getwd())

# vignettes
devtools::build_vignettes(getwd())

##-- woprVision documentation --##

# wopr_README
file.copy('README.html','inst/woprVision/www/wopr_README.html', overwrite=T)

# copy API overview to woprVision
file.copy('doc/woprAPI.html','inst/woprVision/www/woprAPI.html', overwrite=T)

# copy woprVision overview to woprVision
file.copy('doc/woprVision.html','inst/woprVision/www/woprVision.html', overwrite=T)

##-- install package --##

# install from source
install.packages(getwd(), lib="C:/RESEARCH/R/R-3.6.3/library", repo=NULL, type='source')

# # build package tarball
# pkgbuild::build()

# load package
library(wopr)

# run app
wopr::woprVision()


