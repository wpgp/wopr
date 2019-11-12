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
  
  result <- data.frame(mean=mean(N), 
                       median=quantile(N, probs=0.5), 
                       lower=quantile(N, probs=c(alpha/tails)),
                       upper=quantile(N, probs=c(1-alpha/tails)),
                       row.names=1
                       )
  
  result <- round(result)
  
  return(result)
}
