# cleanup
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T)

# working directory
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

##-- package documentation --##

# functions
devtools::document()

# # vignettes
# devtools::build_vignettes(getwd())

##-- woprVision documentation --##

# wopr_README
file.copy('README.html','inst/woprVision/www/wopr_README.html', overwrite=T)

# # render README to woprVision (title doesn't render properly)
# rmarkdown::render(input='README.md',
#                   output_format=c('pdf_document'),
#                   output_file='wopr_README.pdf',
#                   output_dir='inst/woprVision/www')

# copy API_Overview to woprVision
file.copy('doc/API_Overview.pdf','inst/woprVision/www/API_Overview.pdf', overwrite=T)

##-- install package --##

# install from source
install.packages(getwd(), repo=NULL, type='source')

# # build package tarball
# pkgbuild::build('pkg')



