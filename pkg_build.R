# cleanup
rm(list=ls()); gc()

# working directory
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# package documentation
devtools::document('pkg')

# vignettes
devtools::build_vignettes('pkg')

# render API overview
rmarkdown::render(input='pkg/vignettes/wopr_api.Rmd', 
                  output_format='pdf_document', 
                  output_file='API_Overview.pdf', 
                  output_dir=getwd())

# build package
pkgbuild::build('pkg')

