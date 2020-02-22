# cleanup
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T)

# working directory
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# package documentation
devtools::document()
file.copy('README.md','inst/woprVision/www/wopr_README.md', overwrite=T)

# rmarkdown::render(input='README.md',
#                   output_format=c('pdf_document'),
#                   output_file='wopr_README.pdf', 
#                   output_dir='inst/woprVision/www')

# # vignettes
# devtools::build_vignettes(getwd())

# # render API overview
# rmarkdown::render(input='vignettes/wopr_api.Rmd',
#                   output_format=c('pdf_document'),
#                   output_file='doc/API_Overview.pdf',
#                   output_dir=getwd())
# file.copy('API_Overview.pdf','inst/woprVision/www/API_Overview.pdf')
 
# # build package tarball
# pkgbuild::build('pkg')

# install package
install.packages(getwd(), repo=NULL, type='source')

