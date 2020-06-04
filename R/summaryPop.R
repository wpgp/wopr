#' Summary statistics
#' @description Summarize predicted posterior probability distribution for population estimates
#' @param N numeric vector. Vector of posterior samples for the population total
#' @param confidence numeric. The confidence level for the confidence intervals (e.g. 0.95 = 95 percent confidence intervals)
#' @param tails integer. The number of tails for the confidence intervals
#' @param belowthresh numeric. The function will return the probability that the population size is less than _belowthresh_
#' @param abovethresh numeric. The function will return the probability that the population size exceeds _abovethresh_
#' @param round_result logical. If TRUE the results will be rounded to a pre-determined number of digits for each column.
#' @return A data.frame with columns containing the mean, median, lower and upper confidence intervals for the estimated population total. 
#' The 'abovethresh' column reports the probability that the population is greater than _abovethresh_. 
#' The 'belowthresh' column reports the probability that the population is less than _abovethresh_.
#' Note: One minus 'abovethresh' is the probability that the population is equal to or less than _abovethresh_.
#' @export

summaryPop <- function(N, confidence=0.95, tails=2, belowthresh=NA, abovethresh=NA, round_result=F){
  
  N <- as.numeric(N)
  
  alpha <- 1-confidence
  
  result <- data.frame(mean = mean(N, na.rm=T), 
                       median = quantile(N, probs=0.5, na.rm=T), 
                       lower = quantile(N, probs=c(alpha/tails), na.rm=T),
                       upper = quantile(N, probs=c(1-alpha/tails), na.rm=T),
                       belowthresh = mean(N < belowthresh, na.rm=T),
                       abovethresh = mean(N > abovethresh, na.rm=T),
                       row.names = 1
  )
  
  round0_cols <- c('mean','median','lower','upper')
  round3_cols <- c('abovethresh', 'belowthresh')
  
  if(round_result){
    result[,round0_cols] <- as.integer(round(result[,round0_cols]))
    result[,round3_cols] <- round(result[,round3_cols], 3)
  }
  
  return(result)
}
