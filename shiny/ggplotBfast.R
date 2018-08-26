# based on ggplot.bfastIR in breakInterpretR
# To do: look at bfmPlot code to add trend line

ggplotBfast <- function(pp, bpOutput, seg = TRUE, order, formula) {  
  
  ggdf <- pp                                                # pp = bfastpp()
  
  ggdf[,'breaks'] <- NA
  ggdf$breaks[bpOutput$breakpoints] <- 1                    # bpOutput = breakpoints()
  
  xIntercept <- ggdf$time[ggdf$breaks == 1]
  ggdf[,'breakNumber'] <- NA
  if (!is.na(bpOutput$breakpoints)) {
    ggdf$breakNumber[!is.na(ggdf$breaks)] <- 1:length(bpOutput$breakpoints)
  } else {
    ggdf$breakNumber[floor(nrow(ggdf)/2)] <- "No Break"
  }
  ggdf[,'maxY'] <- max(ggdf$response)
  
  
  gg <- ggplot(ggdf, aes(time, response)) +
    # geom_line() +                # HH removes line between points
    geom_point(color = 'black') +  # before was 'green'                                            
    geom_vline(xintercept = xIntercept, color = 'red', linetype = 'dashed') +
    geom_text(aes(x = time + 0.5, y = maxY, label = breakNumber)) +
    scale_x_continuous(breaks=floor(min(ggdf$time)):ceiling(max(ggdf$time))) +
    theme(axis.text.x = element_text(angle = 60, hjust = 1))
  
  if(seg && !is.na(bpOutput$breakpoints)) {
    # Segments on time column
    segments <- c(ggdf$time[c(1,bpOutput$breakpoints, nrow(ggdf))])
    for(i in seq_along(segments[-1])) {
      predTs <- bfastts(rep(NA, ncol(ggdf)), date_decimal(ggdf$time), type = 'irregular')
      predDf <- bfastpp(predTs, order = order, na.action = na.pass)
      predDfSub <- subset(predDf, time <= segments[i + 1] & time >= segments[i])
      trainDfSub <- subset(ggdf, time <= segments[i + 1] & time >= segments[i])
      model <- lm(formula = formula, data = trainDfSub)
      model_trend <- lm(formula = response ~ trend, data = trainDfSub)  # HH adds
      predDfSub$pred <- predict(model, newdata = predDfSub)
      predDfSub$pred_trend <- predict(model_trend, newdata = predDfSub)        # HH adds
      
      gg <- gg + geom_line(data = predDfSub, aes(x = time, y = pred), color = 'blue') +
        geom_line(data = predDfSub, aes(x = time, y = pred_trend), color = 'blue',              # HH adds
                  lty = 2, na.rm = TRUE)    
      
    }    
  }
  gg
}