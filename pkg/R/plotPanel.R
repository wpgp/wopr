#' woprVision: create a panel to hold plots
#' @description Produces a panel to hold the population density plot and the population pyramid
#' @export

plotPanel <- function(N, agesexSelect, agesexTable=NULL, confidence=95, tails='Interval', popthresh=100){
  
  if(is.null(N)){
    plot(0,type='n',bty='n',yaxt='n',xaxt='n',ylab=NA,xlab=NA,
         main='Click the map to select a location.\nPush "Submit" to retrieve population estimates.')
  } else {
    layout(matrix(c(1,2), ncol=1, byrow=T), height=c(1,1))
    
    plotPop(N=N, confidence=confidence, tails=tails, popthresh=popthresh)
    
    plotPyramid(agesexTable=agesexTable, agesexSelect=agesexSelect)
  }
}

