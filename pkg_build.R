# cleanup
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T); 

# working directory
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# rebuild documentation
if(T){
  
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
  
  # copy woprVision_FR overview to woprVision_FR
  file.copy('doc/woprVisionFR.html','inst/woprVision/www/woprVisionFR.html', overwrite=T)
}

##-- install package --##

# restart R
rstudioapi::restartSession()

# install from source
install.packages(getwd(), repo=NULL, type='source', lib='c:/research/r/library')

# load package
library(wopr, lib='c:/research/r/library')

citation('wopr')

# run app
wopr::woprVision()


