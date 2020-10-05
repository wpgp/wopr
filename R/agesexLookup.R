#' Format shiny age-group selection for WOPR
#' @param male logical. Toggle male age-sex selection
#' @param female logical. Toggle female age-sex selection
#' @param male_select character vector. Male age-sex selection (e.g. c('m0','m1') is males under 5 years old)
#' @param female_select character vector. Female age-sex selection (e.g. c('m0','m1','m5') is females under 10 years old)
#' @export

agesexLookup <- function(male, female, male_select, female_select){
  
  mcols <- fcols <- NULL
  breaks <- c(0, 1, seq(5,80,by=5))
  labels <- c('<1','1-4','5-9','10-14','15-19','20-24','25-29','30-34','35-39','40-44','45-49','50-54','55-59','60-64','65-69','70-74','75-79','80+')
  
  if(male) {
    
    if('0-4' %in% male_select){
      male_select <- c('<1','1-4', male_select[-which(male_select %in% c('0-4','<1','1-4'))])
    }
    map <- setNames(paste0('m',breaks), labels)
    index <- sapply(male_select, function(y) which(map[y] == map))
    mcols <- as.character(map[min(index):max(index)])
  }
  if(female) {
    
    if('0-4' %in% female_select){
      female_select <- c('<1','1-4', female_select[-which(female_select %in% c('0-4','<1','1-4'))])
    }
    map <- setNames(paste0('f',breaks), labels)
    index <- sapply(female_select, function(y) which(map[y] == map))
    fcols <- as.character(map[min(index):max(index)])
  }
  return(c(mcols, fcols))
}



           


