# cleanup
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T)

# working directory
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# package documentation
devtools::document('pkg')
file.copy('README.md','pkg/inst/woprVision/www/wopr_README.md', overwrite=T)
# rmarkdown::render(input='README.md',
#                   output_format=c('pdf_document'),
#                   output_file='wopr_README.pdf', 
#                   output_dir='pkg/inst/woprVision/www')


# # vignettes
# devtools::build_vignettes('pkg')

# # render API overview
# rmarkdown::render(input='pkg/vignettes/wopr_api.Rmd',
#                   output_format=c('pdf_document'),
#                   output_file='API_Overview.pdf',
#                   output_dir=getwd())
# file.copy('API_Overview.pdf','pkg/inst/woprVision/www/API_Overview.pdf')
 
# # build package tarball
# pkgbuild::build('pkg')

# install package
install.packages('pkg', repo=NULL, type='source')

