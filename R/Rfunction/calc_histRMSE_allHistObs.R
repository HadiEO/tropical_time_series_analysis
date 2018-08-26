calc_histRMSE_allHistObs <- function() {
  data_tspp <- bfastpp(data_backup,  # data_backup not denoised
                       order = order, lag = lag, slag = slag)  
  
  history_tspp <- subset(data_tspp, time < start)
  
  if (is.null(history)) {
    history <- start(history_tspp$response)            # default history = "all"
  }
  else if (all(is.character(history))) {
    # history <- match.arg(history)                    # HH: comment out cause it gives error when history="ROC"
    history <- switch(history, 
                      "all" = start(history_tspp$response), 
                      "ROC" = history_roc(formula, data = history_tspp, level = level[2]), 
                      "BP" = history_break(formula, data = history_tspp, hpc = hpc))
  }
  else if (all(is.function(history))) {
    history <- history(formula, data = history_tspp)
  }
  history <- time2num(history)                                 # 1 <- time2num(c(1,1))  ???
  history_tspp <- subset(history_tspp, time >= history)
  
  test_tspp <- history_tspp
  
  # ***********************************************
  test_lm <- lm(formula, data = test_tspp)
  # ***********************************************
  
  histRMSE <- sqrt(mean(test_lm$residuals^2))
  
  return(histRMSE)
}
