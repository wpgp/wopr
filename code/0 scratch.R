# initialize
rm(list=ls()); gc(); cat("\014"); try(dev.off(), silent=T); set.seed(42)

# working directory
setwd('C:/RESEARCH/git/wpgp/gridFree')

# load packages
devtools::load_all('pkg')

# copy input folder from worldpop
copyWP(srcdir='Projects/WP517763_GRID3/Working/gridFree/in', 
       outdir='in', 
       overwrite=F, 
       OS.type=.Platform$OS.type)


##---- problem polygon for geojson api ----##
geojson <- geojsonio::geojson_json(shapefile[172,])

N <- requestPop(geojson = geojson, 
                iso3 = 'NGA', 
                ver = '1.2')

server <- 'https://api.worldpop.org/v1/grid3/stats'
queue <- 'https://api.worldpop.org/v1/tasks'

request <- list(iso3 = 'NGA',
                ver = '1.2',
                geojson = geojson,
                key = "wm0LY9MakPSAehY4UQG9nDFo2KtU7POD")

response <- content(POST(url=server, body=request, encode="form"), as='parsed')
result <- content( GET(file.path(queue, response$taskid)), as='parsed')
