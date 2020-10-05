#' woprVision: create a panel to hold plots
#' @param agesex_table The age sex table
#' @param agesex_select a character vector of selected Age and Sex groups
#' @param confidence The confidence level for the confidence intervals (e.g. 0.95 = 95 percent confidence intervals)
#' @param tails The number of tails for the confidence intervals
#' @param popthresh Threshold population used to for _abovethresh_ in wopr::summaryPop()
#' @param popmax numeric. Maximum population size for a pixel in the country
#' @param dict Dictionnary for text translation
#' @description Produces a panel to hold the population density plot and the population pyramid
#' @export

plotPanel <- function(N, agesex_select, agesex_table=NULL, confidence=95, tails='Interval', popthresh=100, popmax=NA, dict=dict_en){
  if(!is.numeric(N)){
    

    par(mar=c(0,0,0,0))
    plot(0,type='n',bty='n',yaxt='n',xaxt='n',ylab=NA,xlab=NA,xlim=c(0,1),ylim=c(0,1))
    
    legend(x = -0.1,
           y = 0.7,
           legend = c(as.expression(bquote(bold(.(dict[['lg_panel1']])))),
                      as.expression(bquote(bold(.(dict[['lg_panel2']])))),
                      as.expression(bquote(bold(.(dict[['lg_panel3']]))))),
           cex = 1.2,
           y.intersp = 2,
           bty = 'n')
  } else {
    layout(matrix(c(1,2), ncol=1, byrow=T), height=c(1,1))

    plotPop(N=N, confidence=confidence, tails=tails, popthresh=popthresh, popmax=popmax, dict=dict)

    plotPyramid(agesex_table=agesex_table, agesex_select=agesex_select, dict=dict)
  }
}

