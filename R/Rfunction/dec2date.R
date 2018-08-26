dec2date <- function(x) {
  as.Date(format(lubridate::date_decimal(x), "%Y-%m-%d"), "%Y-%m-%d")
}