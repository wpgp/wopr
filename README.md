---
title: "_wopr_ tutorial: An R package to access to the WorldPop Open Population Repository"
author: Doug Leasure, WorldPop Research Group, University of Southampton
output: html_document
---

## Introduction
 _wopr_ is an R package that provides API access to the [WorldPop Open Population Repository](https://wopr.worldpop.org). This gives users the ability to:

1. Download WorldPop population data sets directly from the R console, and 
2. Submit spatial queries to the WorldPop server to retrieve population estimates with confidence intervals for user-defined geographic areas and demographic groups. 

Spatial queries can be submitted in the form of points or polygons. Results contain estimated population sizes and confidence intervals that can be customized for a variety of uses.
 
```{r, eval=T, echo=T}
print('Hello')
```

## Package Installation
Install the _wopr_ package from the WorldPop Group on GitHub.

```{r}
# install.packages('devtools')
# devtools::install_github('wpgp/wopr')
library(wopr)
```

## Data Download

One way to access data from WOPR is to simply download the files directly to your computer. This can be done with three easy steps.

First, retrieve the WOPR data catalogue:
```{r}
catalogue <- getCatalogue()
View(catalogue)
```

Then, select a set of files from the catalogue by subsetting the data frame:
```{r}
catalogue_select <- subset(catalogue,
                            country == 'NGA' &
                            category == 'Population' & 
                            version == 'v1.2')

```

Lastly, download the selected files:
```{r}
downloadData(catalogue_select)
```

Using the default settings, a folder named `./wopr_downloads/` will be created in your R working directory and all downloaded files will be saved there. 

A spreadsheet with WOPR data catalogue containing the files currently saved to your hard drive can be found in `./wopr_downloads/wopr_catalogue.csv`.

To list the WOPR files that have been downloaded to your working directory from within the R console, use `list.files('wopr_downloads', recursive=T)`. 

## Spatial Query

Another way to access data from WOPR is using a spatial query to get population estimates for a user-defined geographic area and demographic group(s). Spatial queries must be submitted using objects of class `sf`. ESRI shapefiles can be read into R as `sf` objects as:

```{r}
sf_feature <- sf::st_read(dsn='folder_name', layer='shapefile_name')
```

We will use example data sets included with the `wopr` package that are already in `sf` format.



#### Total population
Get the total population for the example polygon feature using the NGA v1.2 populatin estimates:
```{r}
# WOPR spatial query
N <- getPop(feature=wopr_polys[1,], 
            country='NGA', 
            ver='1.2')

# summarize population estimate
summaryPop(N, confidence=0.95, tails=2, popthresh=5e6)

```


#### Demographic groups

