require(RColorBrewer)

# Input x => change year = round(bfmArea$breakpoint, 0)
# Input out => output filename and its directory. E.g. out <- str_c(path, "/prelim_figs/pdf/test.pdf")
plot_bfastSpatial <- function(x, out) { 
  brks <- seq(x@data@min, x@data@max, by = 1)
  brks.char <- as.character(brks)
  col <- "RdYlBu"   # "RdBu"
  raster::plot(x, col=rev(brewer.pal(10, col)), legend.only=T, legend.width=1, legend.shrink=1, side=4, cex=1.25,   # cex=1.25
               axis.args=list(at=brks, labels=brks.char, cex.axis=1.25))
  
  if(!is.null(out)) {
    pdf(out, )
    raster::plot(x, col=rev(brewer.pal(10, col)), legend.only=T, legend.width=1, legend.shrink=1, side=4, cex=1.25,   # cex=1.25
                 axis.args=list(at=brks, labels=brks.char, cex.axis=1.25))
    dev.off()
  }
}
