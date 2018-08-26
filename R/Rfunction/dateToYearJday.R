dateToYearJday <- function(x) {
  out <- c(year(x), yday(x))
  return(out)
}
