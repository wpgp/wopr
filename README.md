<h1><img src="./wopr.jpg" width="90" alt="" align="left" hspace="10px"> wopr: An R package to query the <br> WorldPop Open Population Repository</h1><br>

WorldPop Research Group  
University of Southampton

28 August 2020

## Introduction

 _wopr_ is an R package that provides API access to the <a href="https://wopr.worldpop.org" target="_blank">WorldPop Open Population Repository</a>. This gives users the ability to:

1. Download WorldPop population data sets directly from the R console, 
2. Submit spatial queries (points or polygons) to the WorldPop server to retrieve population estimates within user-defined geographic areas,
3. Get estimates of population sizes for specific demographic groups (i.e. age and sex), and
4. Get probabilistic estimates of uncertainty for all population estimates.
5. Run the <a href='https://apps.worldpop.org/woprVision' target='_blank'>woprVision</a> web application locally from the R console.

Code for the _wopr_ package is openly available on GitHub: <a href='https://github.com/wpgp/wopr' target='_blank'>https://github.com/wpgp/wopr</a>.

## Installation

First, start a new R session. Then, install the _wopr_ R package from WorldPop on GitHub:

```r
devtools::install_github('wpgp/wopr')
library(wopr)
```

You may be prompted to update some of your existing R packages. This is not required unless the _wopr_ installation fails. You can avoid checking for package updates by adding the argument `upgrade='never'`. If needed, you can update individual packages that may be responsible for any _wopr_ installation errors using `install.packages('package_name')`. Or, you can use `devtools::install_github('wpgp/wopr', upgrade='ask')` to update all of the packages that _wopr_ depends on. In R Studio, you can also update all of your R packages by clicking "Tools > Check for Package Updates". 

Note: When updating multiple packages, it may be necessary to restart your R session before each installation to ensure that packages being updated are not currently loaded in your R environment.

## Usage

Demo code is provided in `demo/wopr_demo.R` that follows the examples in this README.

You can list vignettes that are available using: `vignette(package='wopr')`

The <a href='https://apps.worldpop.org/woprVision' target='_blank'>woprVision web application</a> is an interactive web map that allows you to query population estimates from the <a href='https://wopr.worldpop.org' target='_blank'>WorldPop Open Population Repository</a>. See the vignette for woprVision with: `vignette('woprVision', package='wopr')`

If you are intersted in developing your own front end applications that query the WOPR API, please read the vignette that describes the API backend for developers: `vignette('woprAPI', package='wopr')`

### woprVision

woprVision is an R shiny application that allows you to browse an interactive map to get population estimates for specific locations and demographic groups. woprVision is available on the web at <a href='https://apps.worldpop.org/woprVision' target='_blank'>https://apps.worldpop.org/woprVision</a>. You can also run woprVision locally from your R console using:

```r
wopr::woprVision()
```

We suggest installing Michael Harper's fix to the leaflet.extras draw toolbar:

```r
devtools::install_github("dr-harper/leaflet.extras")
```

This is not required, but it fixes a bug that prevents the draw toolbar from being removed from the map when it is inactive.

### Data Download

One way to access data from WOPR is to simply download the files directly to your computer from the R console. This can be done with three easy steps:

```r
# Retrieve the WOPR data catalogue
catalogue <- getCatalogue()

# Select files from the catalogue by subsetting the data frame
selection <- subset(catalogue,
                    country == 'NGA' &
                      category == 'Population' & 
                      version == 'v1.2')

# Download selected files
downloadData(selection)
```

Note: `'NGA'` refers to Nigeria. WOPR uses <a href="https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3" target="_blank">ISO country codes</a> to abbreviate country names.  

By default, `downloadData()` will not download files larger than 100 MB unless you change the `maxsize` argument (see `?downloadData`). Using the default settings, a folder named `./wopr` will be created in your R working directory for downloaded files. A spreadsheet listing all WOPR files currently saved to your hard drive can be found in `./wopr/wopr_catalogue.csv`. To list the files that have been downloaded to your working directory from within the R console, use `list.files('wopr', recursive=T)`. In multiple calls to downloadData(), files that you have previously downloaded will be overwritten if your local files do not match the server files (based on an md5sums check). This allows you to keep up-to-date local copies of every file.

You can download the entire WOPR data catalogue using: `downloadData(getCatalogue(), maxsize=Inf)`. Note: Some files in the WOPR data catalogue are very large (e.g. 140 GB), so please ensure that you have enough disk space. If disk space is limited, you can restrict the maximum file size that you woud like to download using the `maxsize` argument (default = 100 MB).

### Spatial Query

Population estimates can also be obtained from WOPR using spatial queries (geographic points or polygons) for user-defined geographic area(s) and demographic group(s). 

Spatial queries must be submitted using objects of class `sf`. You can explore this functionality using example data from Nigeria that are included with the `wopr` package. Plot the example data using:

```r
data(wopr_points)
plot(wopr_points, pch=16)

data(wopr_polys)
plot(wopr_polys)
```

Note: ESRI shapefiles (and other file types) can be read into R as `sf` objects using:

```r
sf_feature <- sf::st_read('shapefile.shp')
```

WOPR will return an error if your features contain any geometry errors. To avoid this, you can ensure you have valid geometries using:

```r
sf_feature <- sf::st_make_valid(sf_feature)
```

To submit a spatial query, you must first identify which WOPR databases support spatial queries:

```r
getCatalogue(spatial_query=T)
```

This will return a `data.frame`:

<div style="width:200px">

country | version
--------|--------
NGA     | v1.2
NGA     | v1.1
COD     | v1.0

</div>

These results indicate that there are currently two WOPR databases for Nigeria (NGA) that support spatial queries and one database for Democratic Republic of Congo (COD).

#### Query total population at a single point

To get the total population for a single point location from the NGA v1.2 population estimates use:

```r
N <- getPop(feature=wopr_points[1,], 
            country='NGA', 
            version='v1.2')
```

Notice that the population estimate is returned as a vector of samples from the Bayesian posterior distribution:

```r
print(N)
hist(N)
```

This can be summarized using:

```r
summaryPop(N, confidence=0.95, tails=2, abovethresh=1e5, belowthresh=5e4)
```

The `confidence` argument controls the width of the confidence intervals. The `tails` argument controls whether the confidence intervals are calculated as one-tailed or two-tailed probabilities. If `confidence=0.95` and `tails=2`, then there is a 95% probability that the true population falls within the confidence intervals, given the model structure and the data used to fit the model. If `confidence=0.95` and `tails=1`, then there is a 95% chance that the true population exceeds the lower confidence interval and a 95% chance that the true population is less than the upper confidence interval.

The `abovethresh` argument defines the threshold used to calculate the probability that the population will exceed this threshold.  For example, if `abovethresh=1e5`, then the `abovethresh` result from `summaryPop()` is the probability that the population exceeds 100,000 people. The `belowthresh` argument is similar except it will return the probability that the population is less than this threshold.

#### Query total population within a single polygon

To query WOPR using a single polygon works exactly the same as a point-based query:

```r
N <- getPop(feature=wopr_polygons[1,], 
            country='NGA', 
            version='v1.2')

summaryPop(N, confidence=0.95, tails=2, abovethresh=1e2, belowthresh=50)
```

#### Query population for specific demographic groups

To query population estimates for specific demographic groups, you can use the `agesex_select` argument (see `?getPop`). This argument accepts a character vector of age-sex groups. `'f0'` represents females less than one year old; `'f1'` represents females from age one to four; `'f5'` represents females from five to nine; `'f10'` represents females from 10 to 14; and so on. `'m0'` represents males less than one, etc.

Query the population of children under the age of five within a single polygon:

```r
N <- getPop(feature=wopr_polygons[1,], 
            country='NGA', 
            version='v1.2',
            agesex_select=c('f0','f1','m0','m1'))

summaryPop(N, confidence=0.95, tails=2, abovethresh=10, belowthresh=1)
```

If the `agesex` argument is not included, the `getPop()` function will return estimates of the _total_ population (as above).

#### Query multiple point or polygon features

We can query multiple point or polygon features using the `woprize()` function:

```r
N_table <- woprize(features=wopr_polys, 
                   country='NGA', 
                   version='1.2',
                   agesex_select=c('m0','m1','f0','f1'),
                   confidence=0.95,
                   tails=2,
                   abovethresh=2e4,
                   belowthresh=1e4
                   )
```

You can save these results in a number of ways:

```r
# save results as shapefile
sf::st_write(N_table, 'example_shapefile.shp')

# save results as csv
write.csv(sf::st_drop_geometry(N_table), file='example_spreadsheet.csv', row.names=F)

# save image of mapped results
jpeg('example_map.jpg')
tmap::tm_shape(N_table) + tmap::tm_fill('mean', palette='Reds', legend.reverse=T)
dev.off()
```

## Contributing
The WorldPop Open Population Repository (WOPR) was developed by the WorldPop Research Group within the Department of Geography and Environmental Science at the University of Southampton. Funding was provided by the Bill and Melinda Gates Foundation and the United Kingdom Department for International Development (OPP1182408). Professor Andy Tatem provides oversight of the WorldPop Research Group. The wopr R package was developed by Doug Leasure. Maksym Bondarenko and Niko Ves developed the API backend server. Gianluca Boo created the WOPR logo. Population data have been contributed to WOPR by many different researchers within the WorldPop Research Group.

## Suggested Citation 
Leasure DR, Bondarenko M, Tatem AJ. 2020. wopr: An R package to query the WorldPop Open Population Repository, version 0.3.5. WorldPop, University of Southampton. <a href="https://github.com/wpgp/wopr" target="_blank">doi:10.5258/SOTON/WP00679</a> 

## License
GNU General Public License v3.0 (GNU GPLv3)]
  
  
  
