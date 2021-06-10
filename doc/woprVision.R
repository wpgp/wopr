## ---- echo=F, message=F, warning=F, results='asis'----------------------------
cat(readCitationFile('../inst/CITATION', meta=read.dcf('../DESCRIPTION', all=T))$textVersion)

