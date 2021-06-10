## ----echo=F-------------------------------------------------------------------
x <- rpois(1e4, 100)
hist(x, main='WOPR Result', xlab='Population', freq=F)

## -----------------------------------------------------------------------------
summary(x)

## -----------------------------------------------------------------------------
quantile(x, probs=c(0.025, 0.975))

## ---- echo=F, message=F, warning=F, results='asis'----------------------------
cat(readCitationFile('../inst/CITATION', meta=read.dcf('../DESCRIPTION', all=T))$textVersion)

