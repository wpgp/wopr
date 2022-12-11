#' Create an age-sex population pyramid
#' @description Produces an age sex pyramid plot with the selected age sex classes highlighted.
#' @param agesex_table The age sex table
#' @param agesex_select a character vector of selected Age and Sex groups
#' @param dict Dictionnary for text translation
#' @export

plotPyramid <- function(agesex_select, agesex_table, dict){
  if(nrow(agesex_table)>0){
    agesex_names <- colnames(agesex_table)
    male_groups <- agesex_names[grepl('m[0-9]{1,2}$',agesex_names)]
    female_groups <- agesex_names[grepl('f[0-9]{1,2}$',agesex_names)]
    
    cex.main <- 1.5
    cex.label <- 1.25
    cex.axis <- 1.1
    
    ylim <- c(0, length(male_groups))
    
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
    
    at <- seq(0,ylim[2]-1)
    age_label <- getAgeSexNames(agesex_table)
    axis(2, at=at, las=2, cex.axis=cex.axis,
         labels= age_label)
    mtext(dict[['lg_agegroup']], 2, line=4.5, cex=cex.label)
    mtext(dict[['lg_plot_proppop']], 1, line=3, cex=cex.label)
    
    text(x=-0.05, y=ylim[2], dict[['lg_female']], cex=cex.main)
    text(x=0.05, y=ylim[2], dict[['lg_male']], cex=cex.main)
    
    height <- 0.4
  
    # female
    for(g in 1:length(female_groups)){
      
      if(female_groups[g] %in% agesex_select){ col <- 'black'
      } else { col <- 'darkgrey' }
      
     xleft <- -agesex_table[,female_groups[g]] 
      
      rect(xleft=xleft, xright=-0.0005, ybottom=g-1-height, ytop=g-1+height, col=col, border=NA)
    }
    
    # male
    for(g in 1:length(male_groups)){
      
      if(male_groups[g] %in% agesex_select) { col <- 'black'
      } else { col <- 'darkgrey' }
      
      xright <- agesex_table[,male_groups[g]]
      
      rect(xleft=0.0005, xright=xright, ybottom=g-1-height, ytop=g-1+height, col=col, border=NA)
    }    
  }
}
