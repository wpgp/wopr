#' Summary statistics
#' @description Summarize predicted posterior probability distribution for population estimates
#' @param N Vector of posterior samples for the population total
#' @param confidence The confidence level for the confidence intervals (e.g. 0.95 = 95 percent confidence intervals)
#' @param tails The number of tails for the confidence intervals
#' @param popthresh The function will return the probability that the population size exceeds _popthresh_
#' @return A data.frame with columns containing the mean, median, lower and upper confidence intervals for the estimated population total. 
#' The 'abovethresh' column reports the probability that the population is greater than _popthresh_. 
#' One minus 'abovethresh' is the probability that the population is equal to or less than _popthresh_.
#' @export

summaryPop <- function(N, confidence=0.95, tails=2, popthresh=NA){
  
  N <- as.numeric(N)
  
  alpha <- 1-confidence
  
  result <- data.frame(mean = mean(N, na.rm=T), 
                       median = quantile(N, probs=0.5, na.rm=T), 
                       lower = quantile(N, probs=c(alpha/tails), na.rm=T),
                       upper = quantile(N, probs=c(1-alpha/tails), na.rm=T),
                       abovethresh = mean(N > popthresh, na.rm=T),
                       row.names = 1
  )
  
  round0_cols <- c('mean','median','lower','upper')
  round3_cols <- c('abovethresh')
  
  result[,round0_cols] <- as.integer(round(result[,round0_cols]))
  result[,round3_cols] <- round(result[,round3_cols], 3)
  
  return(result)
}
