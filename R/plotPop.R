#' Plot population estimate
#' @description Plot population estimate
#' @param N Numerical vector. Population estimate from WOPR.
#' @param confidence The confidence level for the confidence intervals (i.e. percentage from 0 to 100)
#' @param tails The confidence type: 'Interval', 'Lower Threshold', or 'Upper Threshold'
#' @param popthresh The function will return the probability that the population size exceeds _popthresh_
#' @param popmax numeric. Maximum population size for a pixel in the country
#' @param dict Dictionnary for text translation
#' @export

plotPop <- function(N, confidence=95, tails='Interval', popthresh=100, popmax=NA, dict=dict_en){
  
  s <- summaryPop(N = N, 
                  confidence = confidence/100, 
                  tails = ifelse(tails=='Interval',2,1), 
                  abovethresh = popthresh,
                  round_result = FALSE)
  
  # plot margins
  par(mar=c(4.5, 1.5, 4.5, 0.5))
  
  cex.main <- 1.5
  cex.lab <- 1.25
  cex.axis <- 1.1

  ##-- plot --##
  
  # pop is NA
  if(!is.numeric(N)){
    
    plot(NA, main=dict[['lg_plot_mainNA']], xlab=dict[['lg_plot_xlab']], ylab=NA, 
         yaxt='n', type='n', xlim=c(0,1), ylim=c(0,1),
         cex.main=cex.main, cex.lab=cex.lab, cex.axis=cex.axis)
    
  } 
  
  # pop is deterministic
  else if(length(N)==1){
      
    xlim <- c(0, 1.5*N)
    if(xlim[2]==0) xlim[2] <- 1
    if(!is.na(popmax) & N < popmax) xlim[2] <- popmax
    
    plot(N, main=NULL, xlab=dict[['lg_plot_xlab']], ylab=NA,  
         yaxt='n', type='n', xlim=xlim, ylim=c(0,1),
         cex.main=cex.main, cex.lab=cex.lab, cex.axis=cex.axis)
    
    abline(v=N, lty=2, lwd=2)
    
  } 
  
  # pop + uncertainty
  else {

    d <- density(N, adjust=3)
    d <- data.frame(cbind(d$x, d$y))
    names(d) <- c('x','y')
    
    d <- d[d$x>=0,]
    
    d <- rbind(d[1,],d)
    d <- rbind(d,d[nrow(d),])
    d[c(1,nrow(d)),'y'] <- 0
    
    if(tails=='Lower Limit') {
      s$upper <- max(N) 
    } else if(tails=='Upper Limit') {
      s$lower <- 0
    }
    
    if(any(d$x >= s$lower)){
      ilow <- min(which(d$x >= s$lower))
    } else{
      ilow <- 1
    }
    if(any(d$x <= s$upper)){
      iup <- max(which(d$x <= s$upper)) 
    } else{
      iup <- nrow(d)
    }
    
    dsub <- d[ilow:iup,]
    dsub <- rbind(data.frame(x=rep(s$lower,2), 
                              y=c(0, mean(d$y[c(ilow,ilow-1)]))), 
                  dsub)
    dsub <- rbind(dsub,
                  data.frame(x=rep(s$upper,2), 
                             y=c(mean(d$y[c(iup,iup+1)]),0)))
    
    plot(d, 
         main=NULL, xlab=dict[['lg_plot_xlab']], ylab=NA,  
         yaxt='n', type='n', 
         xlim=quantile(N,probs=c(0,0.99)),
         cex.main=cex.main, cex.lab=cex.lab, cex.axis=cex.axis)
    
    mtext(dict[['lg_plot_ylab']], 2, line=0.5, cex=cex.lab)
    
    polygon(d, col='lightgrey', border=NA)
    polygon(dsub, col='grey', border=NA)
    
    if(!tails=='Upper Limit') arrows(x0=s$lower, y0=0, y1=dsub[2,'y'], lty=3, lwd=2, length=0)
    if(!tails=='Lower Limit') arrows(x0=s$upper, y0=0, y1=dsub[nrow(dsub)-1,'y'], lty=3, lwd=2, length=0)
    
    if(is.numeric(popthresh)) arrows(x0=popthresh, y0=0, y1=d[which.min(abs(d$x-popthresh)),'y'], lty=1, lwd=3, length=0, col='darkgrey')
    
    arrows(x0=s$mean, y0=0, y1=d[which.min(abs(d$x-s$mean)),'y'], lty=2, lwd=2, length=0)
    
    lines(d, lwd=2)
    
    legend('topright',
           legend=c(dict[['lg_mean']],
                    paste0(confidence, '% CI'),
                    dict[['lg_threshold']]),
           lwd=c(2,2,3),
           lty=c(2,3,1),
           col=c('black','black','darkgrey'),
           bg=rgb(1,1,1,0.9),
           box.col=rgb(1,1,1,0),
           inset=0.01,
           cex=1.1)
  }
  
  
  
  #-- plot title--##
  if(is.numeric(N)){

    # data
    pop_mean <- ifelse(s$mean > 5, round(s$mean), round(s$mean,1))
    
    if(length(N)>1){
      pop_lower <- ifelse(s$mean > 5, round(s$lower), round(s$lower,1))
      pop_upper <- ifelse(s$mean > 5, round(s$upper), round(s$upper,1))
      pop_abovethresh <- round(s$abovethresh*100)
    } else {
      pop_lower <- pop_upper <- pop_abovethresh <- NA
    }
    
    # Main title
    line <- 3
    mtext(paste0(dict[['lg_plot_main1']],prettyNum(pop_mean,big.mark=','),dict[['lg_plot_main2']]),
          line=line, cex=1.5)
    
    # Sub title A
    line <- 1.5
    cex <- 1.2
    if(length(N)==1){
      
      mtext(paste0(round(confidence),'%', dict[['lg_probability']], ':  ',dict[['lg_plot_main6']]), 
            line=line, cex=cex)
      
    } else if(tails=='Interval'){
      
      mtext(paste0(round(confidence),'%', dict[['lg_probability']], ': ', prettyNum(pop_lower,big.mark=','),' - ', prettyNum(pop_upper, big.mark=','),dict[['lg_plot_main2']]), 
            line=line, cex=cex)
      
    } else if(tails=='Lower Limit'){
      
      mtext(paste0(round(confidence),'%', dict[['lg_probability']], ': > ', prettyNum(pop_lower,big.mark=','), dict[['lg_plot_main2']]), 
            line=line, cex=cex)
      
    } else if(tails=='Upper Limit'){
      
      mtext(paste0(round(confidence),'%', dict[['lg_probability']], ': < ', prettyNum(pop_upper,big.mark=','),dict[['lg_plot_main2']]), 
            line=line, cex=cex)
    }
    
    # Sub title B
    if(is.numeric(popthresh)){
      line <- 0.25
      
      if(length(N)==1){
        
        mtext(dict[['lg_plot_main5']], 
              line=line, cex=cex*0.9, col=grey(0.5))
        
      } else {
        mtext(paste0(dict[['lg_plot_main4']], prettyNum(popthresh,big.mark=','), dict[['lg_plot_main3']],': ', pop_abovethresh, '%', dict[['lg_probability']]),
              line=line, cex=cex)
      }
    }
  }
}

