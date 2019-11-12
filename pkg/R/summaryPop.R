#' Summarize predicted posterior probability distribution for population estimates
#' 
#' @param N Vector of posterior samples for the population total
#' @param alpha The type 1 error rate for the confidence intervals
#' @param tails The number of tails for the confidence intervals
#' 
#' @return A list with the mean, median, lower and upper confidence intervals for the population total (rounded to integers)
#' 
#' @export

summaryPop <- function(N, alpha=0.05, tails=2){
  
  result <- data.frame(mean=mean(N, na.rm=T), 
                       median=quantile(N, probs=0.5, na.rm=T), 
                       lower=quantile(N, probs=c(alpha/tails), na.rm=T),
                       upper=quantile(N, probs=c(1-alpha/tails), na.rm=T),
                       row.names=1
                       )
  
  result <- round(result)
  
  return(result)
}
