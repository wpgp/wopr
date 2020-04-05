# cleanup
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T)

# working directory
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

##-- package documentation --##

# functions
devtools::document()

# # render README to HTML
# rmarkdown::render(input='README.md',
#                   output_format=c('html_document'),
#                   output_file='README.html',
#                   output_dir=getwd())
# 
# # vignettes
# devtools::build_vignettes(getwd())

##-- woprVision documentation --##

# wopr_README
file.copy('README.html','inst/woprVision/www/wopr_README.html', overwrite=T)

# copy API overview to woprVision
file.copy('doc/woprAPI.html','inst/woprVision/www/woprAPI.html', overwrite=T)

# copy woprVision overview to woprVision
file.copy('doc/woprVision.html','inst/woprVision/www/woprVision.html', overwrite=T)

# wopr catalogue for offline woprVision
# write.csv(getCatalogue(), file='inst/extdata/wopr_catalogue.csv', row.names=F)

##-- install package --##

# install from source
install.packages(getwd(), repo=NULL, type='source')

# # build package tarball
# pkgbuild::build('pkg')



