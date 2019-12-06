# initialize
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T); seed=runif(1,1,42); set.seed(seed)

# working directory
script.dir <- dirname(rstudioapi::getSourceEditorContext()$path)
setwd(substr(script.dir, 1, nchar(script.dir)-5)); rm(script.dir)

# input directory
if(F) copyWP(srcdir='Projects/WP517763_GRID3/Working/wopr', outdir='in', OS.type=.Platform$OS.type)

# output directory
outdir <- 'out'
dir.create(outdir, showWarnings=F)

# load packages
library('wopr') # devtools::load_all('pkg')

t1 <- read.csv('in/NGAadmin3/NGA_population_v1_2_admin3.csv')[1:10,c('local','mean','q50','q025','q975')]
t2 <- read.csv('out/poptotals.csv')[,c('lganame','mean','median','lower','upper')]

cols <- c('local','mean','median','lower','upper')
names(t1) <- cols
names(t2) <- cols

t1 <- t1[order(t1$local),]
t2 <- t2[order(t2$local),]

head(t1)
head(t2)


