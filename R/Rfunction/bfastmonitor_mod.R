# Original code source: bfast::bfastmonitor

# Modify bfastmonitor code
# (1) Allow noise removal within historical observations
# (2) Allow noise removal within all observations (whole time series). 
# If (2) is TRUE, (1) is FALSE, and vice versa.
# (3) Confirm change if consecutive anomaly (process > boundary) for "cons" times and
# within "maxTimeSpan" years
# (4) NEW 01.03.2018 - for boundaryRMSE = TRUE

# Criteria 
# cons <- 4   # Required no. of consecutive flagged change to confirm change. 
# If set to 1, consecutive criterion not applied. 
# maxTimeSpan <- 2 # Required maximum time span between the consecutive flagged change [decimal years]


# Require custom functions in .Rprofile








bfastmonitor_mod <- function (data, start, formula = response ~ trend + harmon, 
                              order = 3, lag = NULL, slag = NULL, history = c("ROC", "BP", 
                                                                              "all"), 
                              type = "OLS-MOSUM", h = 0.25, end = 10, level = 0.05, 
                              hpc = "none", verbose = FALSE, plot = FALSE,
                              historyNoiseRemoved = FALSE,
                              allNoiseRemoved = FALSE,
                              searchWindow,
                              cons,                     
                              maxTimeSpan,
                              updateMOSUM = FALSE,
                              factorRMSE = NULL,
                              boundaryRMSE = FALSE,
                              snapDate = TRUE,
                              originalDateNoNA,                 # Update 2018-03-06 need this to fix the apparently mismatched date caused by possibly issue in bfastts(), maybe due to all years treated 365 days        
                              factorRMSE_immediate = NULL,
                              allowImmediateConfirm = FALSE,
                              rejectPositiveBp = FALSE)                            
{
  if(cons == 1) maxTimeSpan <- 9999      # Not apply consecutive anomaly for confirming change
  
  level <- rep(level, length.out = 2)
  if (!is.ts(data)) 
    data <- as.ts(data)
  freq <- frequency(data) # 365
  time2num <- function(x) if (length(x) > 1L) {
    x[1L] + (x[2L] - 1)/freq
  } else { x } 
  start <- time2num(start)  # c(2002, 272) --> 2002.742
  
  # Back-up the data for histRMSE calculation using all historical obs (incl. noise)
  data_backup <- data
  
  if(historyNoiseRemoved) {                                    # Should we remove noise in history period? ***                      
    allNoiseRemoved <- FALSE
    data_history <- window(data, end = start)
    data_monitor <- window(data, start = start)
    # Remove noise
    data_history_dipsRm <- removedips_mod(data_history, updateX = TRUE, searchWindow = searchWindow)               
    # Need to convert to xts object to concatenate time series
    data_history_dipsRm_xts <- xts(as.numeric(data_history_dipsRm), 
                                   as.Date(format(date_decimal((index(data_history_dipsRm))), "%d-%m-%Y"), "%d-%m-%Y"))
    data_monitor_xts <- xts(as.numeric(data_monitor), 
                            as.Date(format(date_decimal((index(data_monitor))), "%d-%m-%Y"), "%d-%m-%Y"))
    data_bind_xts <- c(data_history_dipsRm_xts, data_monitor_xts)   # here ok to just append side by side, but better to use merge.xts
    # Convert back to ts object
    data_bind_backTs <- ts(as.numeric(data_bind_xts), 
                          start = c(year(start(data_bind_xts)), day(start(data_bind_xts))), 
                          frequency = 365)     
    data <- data_bind_backTs
  }
  
  if(allNoiseRemoved) {                                    # Should we remove noise in whole time series? ***                      
    historyNoiseRemoved <- FALSE
    # Remove noise
    data_dipsRm <- removedips_mod(data, updateX = TRUE, searchWindow = searchWindow)               
    data <- data_dipsRm
  }
  
  # Plot to check (to comment out)                                           # To comment out *******
  # plot(time(data_history), data_history, ylim = c(-0.2, 0.7))
  # points(time(data_history_dipsRm), data_history_dipsRm, col = "red", cex = 2)
  # plot(time(data), data, ylim = c(-0.2, 0.7))
  # points(time(data_bind_backTs), data_bind_backTs, col = "red", cex = 2)
  # End plot to check
  

  data_tspp <- bfastpp(data, order = order, lag = lag, slag = slag)  # Time series preprocessing for subsequent regression modeling
  # bfastpp omits NA in input data which is regularized ts
  # bfastpp always includes seasonality term
  
  # ***************************************************************************************
  # Fix the date (decimal) in data_tspp$time # <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  # ***************************************************************************************
  # decimal_date(as.Date("2015-01-02"))
  
  if(is.null(originalDateNoNA)) snapDate <- FALSE
  
  if(snapDate) {
    # Get the obs idx that are replaced as NA during noise removal, typically in historical period (end = start)
    isNA_data_backup_idx <- which(!is.na(window(data_backup, end = start))) # c(2012,1) is ok here cause all my time series ends after
    isNA_data_idx <- which(!is.na(window(data, end = start)))
    dips2NA_idx <- which(!isNA_data_backup_idx %in% isNA_data_idx)   # If no replacement with NA (e.g. if noise removal not applied), this will be integer(0)
    
    # data_tspp_time_backup <- data_tspp$time
    if(NROW(dips2NA_idx) > 0) {  # If there are replacement with NA 
      data_tspp$time <- decimal_date(originalDateNoNA[-dips2NA_idx])
      noiseToNA <- 1
    } else {
      data_tspp$time <- decimal_date(originalDateNoNA)
      noiseToNA <- 0
    }
  }
  


  
  
  # ***************************************************************************************
  
  history_tspp <- subset(data_tspp, time < start)
  
  if (is.null(history)) {
    history <- start(history_tspp$response)            # default history = "all"
  } else if (all(is.character(history))) {
    # history <- match.arg(history)                    # HH: comment out cause it gives error when history="ROC"
    history <- switch(history, 
                      "all" = start(history_tspp$response), 
                      "ROC" = history_roc(formula, data = history_tspp, level = level[2]), 
                      "BP" = history_break(formula, data = history_tspp, hpc = hpc))
  } else if (all(is.function(history))) {
    history <- history(formula, data = history_tspp)
  }
  
  history <- time2num(history)                                 # 1 <- time2num(c(1,1))  ???
  history_tspp <- subset(history_tspp, time >= history)
  
  if (verbose) {
    cat("\nBFAST monitoring\n\n1. History period\n")
    cat(sprintf("Stable period selected: %i(%i)--%i(%i)\n", 
                start(history_tspp$response)[1], start(history_tspp$response)[2], 
                end(history_tspp$response)[1], end(history_tspp$response)[2]))
    cat(sprintf("Length (in years): %f\n", NROW(history_tspp)/freq))
  }
  
  test_tspp <- history_tspp
  
  # mefp object class created below
  # The monitoring itself is performed by monitor, which can be called arbitrarily often on objects of class "mefp"
  #****************************************************************
  test_mefp <- mefp(formula, data = test_tspp, type = type,     
                    period = end, h = h, alpha = level[1])
  #****************************************************************
  
  test_lm <- lm(formula, data = test_tspp)
  
  if (floor(h * NROW(test_tspp)) <= 1 | NROW(test_tspp) <= 
      length(coef(test_lm))) {
    ok <- FALSE
    failedTooFewHistObs <- TRUE
    warning("too few observations in selected history period")
  }
  else {
    ok <- TRUE
    failedTooFewHistObs <- FALSE
    # Update 2018-02-19: Get RMSE of historical model for boundary of breakpoint detection
    histRMSE <- sqrt(mean(test_lm$residuals^2))
    if(historyNoiseRemoved | allNoiseRemoved) {   # Update 2018-03-01 histRMSE calculated from all historical obs (incl. noise)
       # The following creates a function to run some steps above but using data_backup (not denoised)
       # in order to return histRMSE including all hist obs
       # The function is defined here cause we need the objects in current run of the bfastmonitor_mod() for current processed ts
       calc_histRMSE_allHistObs <- function() {
          data_tspp <- bfastpp(data_backup,                             # data_backup not denoised ****
                               order = order, lag = lag, slag = slag)  
          history_tspp <- subset(data_tspp, time < start)
          if (is.null(history)) {
            history <- start(history_tspp$response)            # default history = "all"
          }  else if (all(is.character(history))) {
            history <- switch(history, 
                              "all" = start(history_tspp$response), 
                              "ROC" = history_roc(formula, data = history_tspp, level = level[2]), 
                              "BP" = history_break(formula, data = history_tspp, hpc = hpc))
          }  else if (all(is.function(history))) {
            history <- history(formula, data = history_tspp)
          }
          history <- time2num(history)                                 # 1 <- time2num(c(1,1))  ???
          history_tspp <- subset(history_tspp, time >= history)
          test_tspp <- history_tspp
          test_lm <- lm(formula, data = test_tspp)
          histRMSE <- sqrt(mean(test_lm$residuals^2))  #
          return(histRMSE)
      }
      histRMSE <- calc_histRMSE_allHistObs()    #
    }
  }
  if (verbose) { 
    cat("Model fit:\n")
    print(coef(test_lm))
  }
  test_tspp <- subset(data_tspp, time >= history)             # subset data to monitoring period ? it starts from 1988. Aha, if history = "all" basically monitors from the beginning?
  if (ok) {
    
    #****************************************************************
   if(boundaryRMSE) {   # UPDATE: added 2018-02-19
      test_mon <- monitor_mod(test_mefp, data = test_tspp, verbose = FALSE,   # change with monitor_mod()
                        cons = cons, maxTimeSpan = maxTimeSpan, # With 2 more arguments
                        updateMOSUM = updateMOSUM,
                        histRMSE = histRMSE,         
                        factorRMSE = factorRMSE,
                        boundaryRMSE = boundaryRMSE,
                        allowImmediateConfirm = allowImmediateConfirm,
                        factorRMSE_immediate = factorRMSE_immediate,
                        rejectPositiveBp = rejectPositiveBp)              
   } else {
      test_mon <- monitor_mod(test_mefp, data = test_tspp, verbose = FALSE,   # change with monitor_mod()
                      cons = cons, maxTimeSpan = maxTimeSpan, # With 2 more arguments
                      updateMOSUM = updateMOSUM, rejectPositiveBp = rejectPositiveBp)              # UPDATE: added

   }
    
    #****************************************************************
    # Confirmed change
    if(is.na(test_mon$breakpoint)) {                        # Bp at which observation number?
      tbp <- NA
    } else {
      tbp <- test_tspp$time[test_mon$breakpoint]              # corresponds to which observation date?
    }               
                  
    
    # Confirmed change first flagged
    if(is.na(test_mon$breakpoint_firstFlagged)) {                        # Bp at which observation number?
      tbp_firstFlagged <- NA
    } else {
      tbp_firstFlagged <- test_tspp$time[test_mon$breakpoint_firstFlagged]              # corresponds to which observation date?
    }      

    
    if (verbose) {
      cat("\n\n2. Monitoring period\n")
      cat(sprintf("Monitoring starts at: %i(%i)\n", floor(start), 
                  round((start - floor(start)) * freq) + 1))
      if (is.na(tbp)) {
        cat("Break detected at: -- (no break)\n\n")
      }
      else {
        cat(sprintf("Break detected at: %i(%i)\n\n", 
                    floor(tbp), round((tbp - floor(tbp)) * freq) + 
                      1))
      }
    }
  }
  else { 
    test_mon <- NA
    tbp <- NA
  }
  if (ok) {
    # This magnitude calculation looks strange, it's not calculated for window around the change obs, but all obs in monitoring period?
    # Original code
    # test_tspp$prediction <- predict(test_lm, newdata = test_tspp)
    # new_data <- subset(test_tspp, time >= start)
    # magnitude <- median(new_data$response - new_data$prediction, na.rm = TRUE)
    
    # Modified code
    # If there is breakpoint, magnitude calculated from obs in the consecutive window
    # If there is no breakpoint, magnitude calculated from all obs in the monitoring period
    test_tspp$prediction <- predict(test_lm, newdata = test_tspp)   # test_lm should be trend of denoised history
    new_data <- subset(test_tspp, time >= start)
    
    
    if(!is.na(tbp)) {
      if(allowImmediateConfirm) {
        # If allow immediate confirmation, magnitude = residual at the breakpoint (single time) 
        magnitude <- test_mon$dataDf[test_mon$breakpoint, "process_upd"]
      } else { # else the cons window of conditions evaluated
        cons.idx <- test_mon$breakpoint_firstFlagged:test_mon$breakpoint
        if (boundaryRMSE) { # process_upd is residual
          magnitude <- median(test_mon$dataDf[cons.idx, "process_upd"], na.rm = TRUE)
        } else {  # process_upd is MOSUM 
          # new_data idx=1 is after last obs in history
          magnitude <- median(new_data$response[cons.idx-test_mon$histsize] - 
                                new_data$prediction[cons.idx-test_mon$histsize], na.rm = TRUE)
        }
      } 
    } else {  # if no breakpoint, stil calculate magnitude as median of all monitoring obs
      magnitude <- median(new_data$response - new_data$prediction, na.rm = TRUE)
    } 

  } # if ok = FALSE i.e. algorithm failed due to e.g. not enough history obs
  else {
    test_tspp$prediction <- NA
    magnitude <- NA
    tbp_firstFlagged <- NA
  }
  
  # The function returns a list of 
  # - data: a regular ts object
  # - tspp: data subsetted to monitoring period
  # - model: history model fit to historical period i.e. linear model e.g. lm(response ~ trend + harmon)
  # - mefp: output of monitor(). ***Monitor() returns the breakpoint, so need to modify monitor() function!***
  # - history: a vector of start and end dates (decimal) of *historical* period
  # - monitor: a vector of start and end dates (decimal) of *monitoring* period
  # - breakpoint: time of breakpoint
  # - magnitude: change magnitude
  
  #*********************************************************************************************************************************************************
 if(!exists("noiseToNA")) noiseToNA <- NA
  
  
   rval <- list(data = data, tspp = test_tspp, model = test_lm, 
               mefp = test_mon, history = c(head(history_tspp$time, 
                                                 1), tail(history_tspp$time, 1)), 
               monitor = c(start, tail(test_tspp$time, 1)), 
               breakpoint = tbp, breakpoint_firstFlagged = tbp_firstFlagged,
               magnitude = magnitude,
               failedTooFewHistObs = failedTooFewHistObs,
               noiseToNA = noiseToNA)
  #*********************************************************************************************************************************************************
  
  class(rval) <- "bfastmonitor"
  if (plot) 
    plot(rval)
  return(rval)                         # the list returned by the function
}
