plotMOSUM <- function (bfm, plotlabs = NULL, ncols = 1, rescale = 1, ylab = "process",   # ylab = "response"
                         displayMagn = FALSE, magn_ypos = 0.3, magn_xoffset = -0.45, 
                         magn_digits = 3, displayResiduals = c("none", 
                                                                                    "all", "monperiod", "history"), type = "irregular",
                         displayOldFlag = TRUE, circleVersion = FALSE, refDate = NULL, displayRefDate = TRUE) 
{
  # allData <- bfmPredict(bfm, type = type, plotlabs = plotlabs)
  allData <- bfm$mefp$dataDf
  allData$start <- bfm$monitor[1]
  allData$breakpoint <- bfm$breakpoint
    
  # xbks <- as.Date(c(floor(min(allData$time)):ceiling(max(allData$time))))   # "1975-06-12" etc. ??
  xbks <- as.Date(time2date(c(floor(min(allData$time)):ceiling(max(allData$time)))))   # HH: changed as.Date to time2date
  p <- ggplot(data = allData, aes(x = as.Date(time2date(time)), y = abs(process_upd))) +  # y = response -> process   # HH: changed x = as.Date(time)
    geom_point(na.rm = TRUE) + 
    labs(y = ylab) + scale_x_date(breaks = xbks, date_labels = "%Y") +           # HH: changed scale_x_continuous(breaks = xbks)
    geom_vline(aes(xintercept = as.Date(time2date(start))), na.rm = TRUE, col = "grey40")        # HH: changed xintercept = start
  
 # Show old MOSUM (before updated)
  p <- p + geom_point(data = allData, aes(x = as.Date(time2date(time)), y = abs(process))) +  # y = response -> process_upd   # HH: changed x = as.Date(time)
    geom_point(na.rm = TRUE, col = "dark orange")  # size = 3, shape = 4, fill = NA
  
  
  # Display dates of old flag i.e. change not confirmed
  if(displayOldFlag) {     # HH added
    oldFlagDates <- bfm$mefp$dataDf[which(bfm$mefp$dataDf$flag == "old_flag"), "time"]
    if(NROW(oldFlagDates) != 0) {
      if(circleVersion) {
        oldFlagDf <- bfm$mefp$dataDf[which(bfm$mefp$dataDf$flag == "old_flag"),]
        p <- p + geom_point(data = oldFlagDf, 
                            aes(x = as.Date(time2date(time)), y = abs(process_upd)),
                            col = "red", size = 4, shape = 21, fill = NA, stroke = 1)
      } else {
        oldFlagDates <- data.frame(date = as.Date(time2date(oldFlagDates)))
        # p <- p + geom_vline(aes(xintercept = oldFlagDates), na.rm = TRUE)   # Think of the multiple facets!
        p <- p + geom_vline(data = oldFlagDates, aes(xintercept = date), na.rm = TRUE,
                            col = "green", lty = 2)
      }
    }
  }
  
  
  # Show boundary
  p <- p + geom_line(data = allData, aes(x = as.Date(time2date(time)), 
                                         y = abs(boundary)),
                                         col = "green",
                                         lwd = 0.8)  # y = response -> process_upd   # HH: changed x = as.Date(time)

  
  # If input is a list, thus facet plot
  if (length(levels(allData$lab) > 1)) 
    p <- p + facet_wrap(~lab, ncol = ncols)
  
  # Show dates of breakpoint (old flag, change first flagged, change confirmed; when applicable)
  if (!all(is.na(unique(allData$breakpoint)))) {
    # HH: changed to show change_flagged and change_confirmed dates
    # p <- p + geom_vline(aes(xintercept = breakpoint), na.rm = TRUE, 
    #                     col = "red", lty = 2) 
    
    if(circleVersion) {
      # First time confirmed change is flagged:
      if(!is.na(bfm$breakpoint_firstFlagged)) {
        changeFlagDf <- bfm$mefp$dataDf[which(bfm$mefp$dataDf$flag %in% c("change_flagged", "change_confirmed")),]
        p <- p + geom_point(data = changeFlagDf, 
                            aes(x = as.Date(time2date(time)), y = abs(process_upd)),
                            col = "red", size = 4, shape = 21, fill = NA, stroke = 1)
      } 
      # When change is confirmed
      changeConfirmedDate <- as.Date(time2date(bfm$breakpoint))
      p <- p + geom_vline(aes(xintercept = changeConfirmedDate), na.rm = TRUE,
                          col = "red", lty = 2, size = 0.7)                            # "change date" line thickness
      
    } else { # Non circle version
      # First time confirmed change is flagged:
      if(!is.na(bfm$breakpoint_firstFlagged)) {  
        changeFlaggedDate <- as.Date(time2date(bfm$breakpoint_firstFlagged))
        p <- p + geom_vline(aes(xintercept = changeFlaggedDate), na.rm = TRUE,
                            col = "red", lty = 2)
      }
      
      # When change is confirmed
      changeConfirmedDate <- as.Date(time2date(bfm$breakpoint))
      p <- p + geom_vline(aes(xintercept = changeConfirmedDate), na.rm = TRUE,
                          col = "red", lty = 1, size = 0.7)                            # "change date" line thickness
    }
  }
  
  # Show reference change date
  if(displayRefDate) {
    p <- p + geom_vline(aes(xintercept = refDate), na.rm = TRUE,
                        col = "forestgreen", lty = 2, lwd = 0.6)
  }
  
  return(p)
}
