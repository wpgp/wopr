# cleanup
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T);

# working directory
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# R library
lib <- NULL
try(suppressWarnings(source('wd/lib.r')), silent=T)

# package documentation
devtools::document()

# rebuild README and vignettes
if(T){

  ##-- package documentation --##

  # render README to markdown and html
  rmarkdown::render(input='README.rmd',
                    output_format=c('github_document'),
                    output_file='README.md',
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

  # copy translated woprVision overview to woprVision
  file.copy('doc/woprVisionFR.html','inst/woprVision/www/woprVisionFR.html', overwrite=T)
  file.copy('doc/woprVisionES.html','inst/woprVision/www/woprVisionES.html', overwrite=T)
  file.copy('doc/woprVisionPT.html','inst/woprVision/www/woprVisionPT.html', overwrite=T)
}

##-- install package --##

# restart R
rstudioapi::restartSession()

# install from source
install.packages(getwd(), repo=NULL, type='source', lib=lib)

# load package
library(wopr, lib=lib)

# citation
citation('wopr')

# run app (API-mode)
wopr::woprVision()

# run app (local-mode)
wopr::woprVision('e:/wopr')

