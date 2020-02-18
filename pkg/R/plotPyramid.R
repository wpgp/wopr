#' Create an age-sex population pyramid
#' @description Produces an age sex pyramid plot with the selected age sex classes highlighted.
#' @param agesexTable The age sex table
#' @param agesexSelect a character vector of selected Age and Sex groups
#' @export

plotPyramid <- function(agesexSelect, agesexTable){
  if(nrow(agesexTable)>0){
    
    male_groups <- paste0('m',c(0,1,seq(5,80,by=5)))
    female_groups <- paste0('f',c(0,1,seq(5,80,by=5)))
    
    cex.main <- 1.5
    cex.label <- 1.25
    cex.axis <- 1.1
    
    ylim <- c(0, max(length(male_groups)-1, length(female_groups)-1))
    
    par(mar=c(4.5, 6, 2, 0.5))
    
    plot(NA, 
         main=NA,
         xlim=c(-0.1, 0.1), 
         ylim=ylim,
         cex.axis=cex.axis, 
         yaxt='n', xaxt='n', bty='n',
         xlab=NA, ylab=NA)
    
    at <- seq(-0.1,0.1, by=0.05)
    axis(1, at=at, labels=paste0(abs(at)*100,'%'), cex.axis=cex.axis)
    
    at <- seq(1,ylim[2])
    axis(2, at=at, las=2, cex.axis=cex.axis,
         labels=c('0-4','5-9','10-14','15-19','20-24','25-29','30-34','35-39','40-44','45-49','50-54','55-59','60-64','65-69','70-74','75-79','80+')
         )
    mtext('Age Group', 2, line=4.5, cex=cex.label)
    mtext('Proportion of Population', 1, line=3, cex=cex.label)
    
    text(x=-0.05, y=ylim[2], 'Female', cex=cex.main)
    text(x=0.05, y=ylim[2], 'Male', cex=cex.main)
    
    height <- 0.4
  
    # female
    for(g in 2:length(female_groups)){
      
      if(female_groups[g] %in% agesexSelect){ col <- 'black'
      } else if(g==2 & female_groups[1] %in% agesexSelect) { col <- 'black'
      } else { col <- 'darkgrey' }
      
      if(g==2) { xleft <- -sum(agesexTable[,female_groups[1:2]])
      } else { xleft <- -agesexTable[,female_groups[g]] }
      
      rect(xleft=xleft, xright=-0.0005, ybottom=g-1-height, ytop=g-1+height, col=col, border=NA)
    }
    
    # male
    for(g in 2:length(male_groups)){
      
      if(male_groups[g] %in% agesexSelect) { col <- 'black'
      } else if(g==2 & male_groups[1] %in% agesexSelect) { col <- 'black'
      } else { col <- 'darkgrey' }
      
      if(g==2) { xright <- sum(agesexTable[,male_groups[1:2]])
      } else { xright <- agesexTable[,male_groups[g]] }
      
      rect(xleft=0.0005, xright=xright, ybottom=g-1-height, ytop=g-1+height, col=col, border=NA)
    }    
  }
}