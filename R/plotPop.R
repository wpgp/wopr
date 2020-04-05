#' Plot population estimate
#' @description Plot population estimate
#' @param N Numerical vector. Population estimate from WOPR.
#' @param confidence The confidence level for the confidence intervals (i.e. percentage from 0 to 100)
#' @param tails The confidence type: 'Interval', 'Lower Threshold', or 'Upper Threshold'
#' @param popthresh The function will return the probability that the population size exceeds _popthresh_
#' @export

plotPop <- function(N, confidence=95, tails='Interval', popthresh=100){
  
  s <- summaryPop(N=N, 
                  confidence=confidence/100, 
                  tails=ifelse(tails=='Interval',2,1), 
                  abovethresh=popthresh)
  
  # plot margins
  par(mar=c(4.5,1,4.5,0.5))
  
  cex.main <- 1.5
  cex.lab <- 1.25
  cex.axis <- 1.1

  if(!is.numeric(N)){
    
    plot(NA, main='Population Estimate: NA', xlab='Population', ylab=NA, 
         yaxt='n', type='n', xlim=c(0,1), ylim=c(0,1),
         cex.main=cex.main, cex.lab=cex.lab, cex.axis=cex.axis)
    
  } else if(length(N)==1){
      
    plot(0, main=NULL, xlab='Population', ylab=NA, 
         yaxt='n', type='n', xlim=c(0,1), 
         cex.main=cex.main, cex.lab=cex.lab, cex.axis=cex.axis)
      
  } else {

    d <- density(N, adjust=3)
    d <- data.frame(cbind(d$x, d$y))
    names(d) <- c('x','y')
    
    d <- rbind(d[1,],d)
    d <- rbind(d,d[nrow(d),])
    d[c(1,nrow(d)),'y'] <- 0
    
    if(tails=='Lower Limit') {
      s$upper <- max(N) 
    } else if(tails=='Upper Limit') {
      s$lower <- 0
    }
    
    ilow <- min(which(d$x >= s$lower))
    iup <- max(which(d$x <= s$upper))
    
    dsub <- d[ilow:iup,]
    dsub <- rbind(data.frame(x=rep(s$lower,2), 
                              y=c(0, mean(d$y[c(ilow,ilow-1)]))), 
                  dsub)
    dsub <- rbind(dsub,
                  data.frame(x=rep(s$upper,2), 
                             y=c(mean(d$y[c(iup,iup+1)]),0)))
    
    plot(d, 
         main=NULL, xlab='Population', ylab=NA, 
         yaxt='n', type='n', 
         xlim=quantile(N,probs=c(0,0.99)),
         cex.main=cex.main, cex.lab=cex.lab, cex.axis=cex.axis)
    
    polygon(d, col='lightgrey', border=NA)
    polygon(dsub, col='grey', border=NA)
    
    if(!tails=='Upper Limit') arrows(x0=s$lower, y0=0, y1=dsub[2,'y'], lty=3, lwd=2, length=0)
    if(!tails=='Lower Limit') arrows(x0=s$upper, y0=0, y1=dsub[nrow(dsub)-1,'y'], lty=3, lwd=2, length=0)
    
    if(is.numeric(popthresh)) arrows(x0=popthresh, y0=0, y1=d[which.min(abs(d$x-popthresh)),'y'], lty=1, lwd=3, length=0, col='darkgrey')
    
    arrows(x0=s$mean, y0=0, y1=d[which.min(abs(d$x-s$mean)),'y'], lty=2, lwd=2, length=0)
    
    lines(d, lwd=2)
    
    legend('topright',
           legend=c('Mean',
                    paste0(confidence, '% CI'),
                    'Threshold'),
           lwd=c(2,2,3),
           lty=c(2,3,1),
           col=c('black','black','darkgrey'),
           bg=rgb(1,1,1,0.9),
           box.col=rgb(1,1,1,0),
           inset=0.01,
           cex=1.1)
  }
  
  if(is.numeric(N)){

    # Main title
    line <- 3
    mtext(paste0('Population Estimate: ',prettyNum(s$mean,big.mark=','),' people'),
          line=line, cex=1.5)
    
    # Sub title A
    line <- 1.5
    cex <- 1.25
    if(tails=='Interval'){
      
      mtext(paste0(round(confidence),'% probability: ', prettyNum(s$lower,big.mark=','),' - ', prettyNum(s$upper, big.mark=','),' people'), 
            line=line, cex=cex)
      
    } else if(tails=='Lower Limit'){
      
      mtext(paste0(round(confidence),'% probability: > ', prettyNum(s$lower,big.mark=','), ' people'), 
            line=line, cex=cex)
      
    } else if(tails=='Upper Limit'){
      
      mtext(paste0(round(confidence),'% probability: < ', prettyNum(s$upper,big.mark=','),' people'), 
            line=line, cex=cex)
    }
    
    # Sub title B
    if(is.numeric(popthresh)){
      line <- 0.25
      mtext(paste0(round(s$abovethresh*100),'% probability: > ', prettyNum(popthresh,big.mark=','), ' people (threshold)'),
            line=line, cex=cex)
    }
  }
}

