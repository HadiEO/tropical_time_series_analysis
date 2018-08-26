# Original code source: not mine
# Modification:
# Mark dates of old flag, change first flagged, change confirmed
# UPDATE 2018-03-03: also mark reference date

# Consider doing in the beginning already:
# allData$time <- as.Date(time2date(time))
# since we use scale_x_date()
# Thus no need to do the date conversion in later parts of the script

bfmPlot_mod <- function (bfm, plotlabs = NULL, ncols = 1, rescale = 1, ylab = "response", 
          displayMagn = FALSE, magn_ypos = 0.3, magn_xoffset = -0.45, 
          magn_digits = 3, displayTrend = TRUE, displayResiduals = c("none", 
                                                                     "all", "monperiod", "history"), type = "irregular",
          displayOldFlag = TRUE, circleVersion = FALSE, refDate = NULL, displayRefDate = TRUE,
          displayBoundaryRMSE = FALSE) 
{
  allData <- bfmPredict(bfm, type = type, plotlabs = plotlabs)
  # xbks <- as.Date(c(floor(min(allData$time)):ceiling(max(allData$time))))   # "1975-06-12" etc. ??
  xbks <- as.Date(time2date(c(floor(min(allData$time)):ceiling(max(allData$time)))))   # HH: changed as.Date to time2date
  p <- ggplot(data = allData, aes(x = as.Date(time2date(time)), y = response)) +     # HH: changed x = as.Date(time)
    geom_point(na.rm = TRUE) + 
    # geom_line(aes(y = prediction), col = "blue", na.rm = TRUE) +                
    # HH: comment out geom_line(), display trend later. allData$prediction is the same as allData$predictionTrend for trend only model? 
    # Uncomment if includes seasonal model!
    labs(y = ylab) + scale_x_date(breaks = xbks, date_labels = "%Y") +           # HH: changed scale_x_continuous(breaks = xbks)
    geom_vline(aes(xintercept = as.Date(time2date(start))), na.rm = TRUE, col = "grey40")        # HH: changed xintercept = start
   
  # Display residuals moved here so plot the line on the background 
   if (displayResiduals[1] != "none" & ("monperiod" %in% displayResiduals | 
                                       "all" %in% displayResiduals)) {
    p <- p + geom_segment(data = allData[allData$time >= allData$start, ], 
                          aes(x = as.Date(time2date(time)), xend = as.Date(time2date(time)),  # HH: changed x = time, xend = time
                              y = response, yend = prediction), 
                          col = "grey50", lty = 5, na.rm = TRUE)
   }
  
  if (displayResiduals[1] != "none" & ("history" %in% displayResiduals | 
                                       "all" %in% displayResiduals)) {
    p <- p + geom_segment(data = allData[allData$time < allData$start, ], 
                          aes(x = as.Date(time2date(time)), xend = as.Date(time2date(time)), 
                              y = response, yend = prediction), 
                          col = "grey50", lty = 5, na.rm = TRUE)
  }
  
  # Display dates of old flag i.e. change not confirmed
  if(displayOldFlag) {     # HH added
    oldFlagDates <- bfm$mefp$dataDf[which(bfm$mefp$dataDf$flag == "old_flag"), "time"]
    if(NROW(oldFlagDates) != 0) {
      if(circleVersion) {
        oldFlagDf <- bfm$mefp$dataDf[which(bfm$mefp$dataDf$flag == "old_flag"),]
        p <- p + geom_point(data = oldFlagDf, 
                             aes(x = as.Date(time2date(time)), y = response),
                             col = "red", size = 4, shape = 21, fill = NA, stroke = 1)   # Old flag circle border thickness
      } else {
        oldFlagDates <- data.frame(date = as.Date(time2date(oldFlagDates)))
        # p <- p + geom_vline(aes(xintercept = oldFlagDates), na.rm = TRUE)   # Think of the multiple facets!
        p <- p + geom_vline(data = oldFlagDates, aes(xintercept = date), na.rm = TRUE,
                          col = "green", lty = 2)
      }
      }
  }
  
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
                             aes(x = as.Date(time2date(time)), y = response),
                             col = "red", size = 4, shape = 21, fill = NA, stroke = 1)    # Change circle border thickness
       } 
        # When change is confirmed
        changeConfirmedDate <- as.Date(time2date(bfm$breakpoint))
        p <- p + geom_vline(aes(xintercept = changeConfirmedDate), na.rm = TRUE,
                           col = "red", lty = 2, size = 0.7)                 # "change date" line thickness
        
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
                           col = "red", lty = 1, size = 0.7)                               # "change date" line width
     }
  }
  
  # Show reference change date
  if(displayRefDate) {
    p <- p + geom_vline(aes(xintercept = refDate), na.rm = TRUE,
                        col = "forestgreen", lty = 2, lwd = 0.6)
  }
  
  
  
  # Show trend model
  if (displayTrend) {
    p <- p + geom_line(aes(y = predictionTrend), col = "blue", 
                       lty = 1, na.rm = TRUE)                      # HH: changed lty = 2
  }
  
  # Show change magnitude. Todo: check why magnitude doesn't compute right in this modified function
  if (displayMagn) {    
    magn_ypos <- min(allData$response, na.rm = TRUE) + magn_ypos * 
      diff(range(allData$response, na.rm = TRUE))
    magns <- unique(allData$magnitude)
    xpos <- unique(allData$start) + magn_xoffset
    magn <- data.frame(magn = round(magns * rescale, magn_digits), 
                       x = xpos, y = magn_ypos, lab = unique(allData$lab))
    p <- p + geom_text(data = magn, aes(x = x, y = y, label = paste("m = ", 
                                                                    magn, sep = ""), group = NULL), size = 5)
  }
 
  # Show boundary RMSE, different k = 1, 2, 3, 4
  if(displayBoundaryRMSE) {
    allData.monitor <- subset(allData, time > allData$start)
    # allData.monitor$predictionTrendPlus1RMSE <- allData.monitor$predictionTrend + 1 * bfm$mefp$histrmse
    # allData.monitor$predictionTrendMinus1RMSE <- allData.monitor$predictionTrend - 1 * bfm$mefp$histrmse
    
    allData.monitor$predictionTrendPlusFactRMSE <- allData.monitor$predictionTrend + bfm$mefp$factrmse * bfm$mefp$histrmse
    allData.monitor$predictionTrendMinusFactRMSE <- allData.monitor$predictionTrend - bfm$mefp$factrmse * bfm$mefp$histrmse
    
    p <- p + geom_line(data = allData.monitor, 
                       aes(x = as.Date(time2date(time)), y = predictionTrendPlusFactRMSE), col = "green", 
                       lty = 1, na.rm = TRUE, lwd = 0.8) +
      geom_line(data = allData.monitor, 
                aes(x = as.Date(time2date(time)), y = predictionTrendMinusFactRMSE), col = "green", 
                lty = 1, na.rm = TRUE, lwd = 0.8)
  }
  
  return(p)
}



# For debugging                                             # To comment out!!
# bfm = mod_bfm_out_historyDipsRm_Cons4_Span2
# plotlabs = NULL
# ncols = 1
# rescale = 1
# ylab = "NDMI"
# displayMagn = FALSE
# magn_ypos = 0.3
# magn_xoffset = -0.45
# magn_digits = 3
# displayTrend = TRUE
# displayResiduals = "monperiod"
# type = "irregular"
# displayOldFlag = TRUE
