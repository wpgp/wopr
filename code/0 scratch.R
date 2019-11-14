# initialize
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T)
seed=runif(1,1,42); set.seed(seed)

# working directory
setwd('C:/RESEARCH/git/wpgp/gridFree')

# load packages
devtools::load_all('pkg')

# copy input folder from worldpop
copyWP(srcdir='Projects/WP517763_GRID3/Working/gridFree/in', 
       outdir='in', 
       OS.type=.Platform$OS.type)


##---- compare totals ----##

t1 <- read.csv('in/GRID3_NGA_population_v1_2_admin3.csv')[,c('local','mean','q50','q025','q975')]
t2 <- read.csv('out/poptotals.csv')[,c('lganame','mean','median','lower','upper')]

cols <- c('local','mean','median','lower','upper')
names(t1) <- cols
names(t2) <- cols

t1 <- t1[order(t1$local),]
t2 <- t2[order(t2$local),]

head(t1)
head(t2)


##---- problem polygon for geojson api ----##

shapefile <- rgdal::readOGR(dsn='in', layer='lgas')

x <- geojson_json(disaggregate(shapefile[172,]))

N <- requestPop(geojson = x, 
                iso3 = 'NGA', 
                ver = '1.2')

server <- 'http://10.19.100.66/v1/grid3/stats' 
queue <- 'http://10.19.100.66/v1/tasks'

request <- list(iso3 = 'NGA',
                ver = '1.2',
                geojson = geojson,
                key = "wm0LY9MakPSAehY4UQG9nDFo2KtU7POD")

response <- content(POST(url=server, body=request, encode="form"), as='parsed')
result <- content( GET(file.path(queue, response$taskid)), as='parsed')
