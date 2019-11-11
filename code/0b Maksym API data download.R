library(httr)

ISO3 = "NGA"
version = "v1.0"
type_data = "admin0"
category = "Population"

# working directory
setwd('C:/RESEARCH/git/wpgp/gridFree')

# dest_folder is a path where downloaded file will be stored
dest_folder <- "out"


res <- GET("http://grid3data.worldpop.uk/api/v1.0/data", verbose())

# you will get a respond that task is created with taskid
jsonRespParsed <- content(res,as="parsed") 


url <- jsonRespParsed[[ISO3]][[category]][[version]][[type_data]]$url

remout.file.name <- jsonRespParsed[[ISO3]][[category]][[version]][[type_data]]$file

dest_file <- paste0(dest_folder,remout.file.name)

utils::download.file(url, destfile=dest_file,mode="wb",quiet=FALSE, method="auto")


########################################################


