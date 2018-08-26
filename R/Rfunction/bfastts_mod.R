# original function source: bfast::bfastts
# temp <- data; data <- extrNDMI.ls$'515'; dates <- index(data)
# yday


bfastts_mod <- function (data, dates, type = c("irregular", "16-day", "10-day")) 
{
  yday365 <- function(x) {
    x <- as.POSIXlt(x)
    mdays <- c(31L, 28L, 31L, 30L, 31L, 30L, 31L, 31L, 30L, 
               31L, 30L, 31L)
    cumsum(c(0L, mdays))[1L + x$mon] + x$mday
  }
  if (type == "irregular") {
    zz <- zoo(data, 1900 + as.POSIXlt(dates)$year + (yday365(dates) -             # yday365 -> yday ?
                                                       1)/365, frequency = 365)
    # HH modified
    # zz <- zoo(data, decimal_date(dates))
    # OK, it's not possible to fix it here cause the output ts object (which is required by bfastpp)
    # needs to have regular freq=365 (can't have 366 days in leap years)
    
  }
  if (type == "16-day") {
    z <- zoo(data, dates)
    yr <- as.numeric(format(time(z), "%Y"))
    jul <- as.numeric(format(time(z), "%j"))
    delta <- min(unlist(tapply(jul, yr, diff)))
    zz <- aggregate(z, yr + (jul - 1)/delta/23)
  }
  if (type == "10-day") {
    tz <- as.POSIXlt(dates)
    zz <- zoo(data, 1900L + tz$year + round((tz$yday - 1L)/10L)/36L, 
              frequency = 36L)
  }
  tso <- as.ts(zz)
  return(tso)
}

