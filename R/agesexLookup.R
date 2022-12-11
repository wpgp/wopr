#' Format shiny age-group selection for WOPR
#'
#' @param male logical. Toggle male age-sex selection
#' @param female logical. Toggle female age-sex selection
#' @param male_select character vector. Male age-sex selection (e.g. c('m0','m1') is males under 5 years old)
#' @param female_select character vector. Female age-sex selection (e.g. c('m0','m1','m5') is females under 10 years old)
#' @param age_labels character vector. Age group labels
#' @param agesex_table data.frame. Age sex proportions table
#'
#' @export

agesexLookup <- function(male, female, male_select, female_select, age_labels, agesex_table){
  
  mcols <- fcols <- NULL
  agesex_group <- colnames(agesex_table)
  age_breaks <-  as.integer(gsub('f', '',agesex_group[grepl('f', agesex_group)]))

  if(male) {

    map <- setNames(paste0('m',age_breaks), age_labels)
    index <- sapply(male_select, function(y) which(map[y] == map))
    mcols <- as.character(map[min(index):max(index)])
  }
  if(female) {
    
    map <- setNames(paste0('f',age_breaks), age_labels)
    index <- sapply(female_select, function(y) which(map[y] == map))
    fcols <- as.character(map[min(index):max(index)])
  }
  return(c(mcols, fcols))
}



           


