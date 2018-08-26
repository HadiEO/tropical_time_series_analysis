# Original code source: bfast::bfastmonitor

time2num <- function(x) if (length(x) > 1L) {
  x[1L] + (x[2L] - 1)/freq
} else { x }