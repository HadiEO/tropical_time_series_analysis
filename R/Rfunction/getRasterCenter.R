getRasterCenter <- function(img) {                             ## Function to get raster center coordinate
  xcent <- extent(img)@xmin + 0.5 * (extent(img)@xmax - extent(img)@xmin)
  ycent <- extent(img)@ymin + 0.5 * (extent(img)@ymax - extent(img)@ymin)
  xycent <- c(xcent, ycent)
  
  xbuff <- 0.5 * (extent(img)@xmax - extent(img)@xmin)
  ybuff <- 0.5 * (extent(img)@ymax - extent(img)@ymin)
  
  res <- list(xycent = xycent, xbuff = xbuff, ybuff = ybuff)
  return(res)
}