# Original code source: strucchange::monitor()

# ******************************************************************************
# Consider:
# (1) When an observation is flagged, it is removed when calculating MOSUM value at subsequent dates
# (2) Or, increase number of consecutive anomaly. 
#     Note in CCDC v13.07 the number was revised to 6 (https://github.com/prs021/ccdc) on 10/01/2015 (mm/dd/yyyy)
#     See section 3.2.2 in doi.org/10.1016/j.rse.2015.02.009 
# (3) Maybe we need to arbitrarily change the boundary values. In CCDC the threshold is 2*RMSE.
# (4) Use LASSO fit in place of OLS.
# (5) Use robust regression fit. We found presence of noise outliers in the studied region strongly influences 
#     the trend. There are some ways to deal with it e.g. (1) Remove dips etc. 
#     but we attempted Robust Iteratively Reweighted LS as in http://dx.doi.org/10.1016/j.rse.2014.01.011
#     Update: ok, not that easy to implement in breakpoints(), see https://stat.ethz.ch/pipermail/r-help/2008-May/161624.html
# (6) Temporally-adjusted threshold / RMSE. This is the same as MOSUM process?
# ******************************************************************************


# Data for debug *****
# obj = test_mefp                     # To comment out ***********************************
# data = test_tspp
# *******************

# Criteria 
# cons <- 4   # Required no. of consecutive flagged change to confirm change 
# maxTimeSpan <- 2 # Required maximum time span between the consecutive flagged change [decimal years]


monitor_mod <- function (obj,       # obj is a list of things that will be populated, and returned from the function
                         data,      
                         verbose = TRUE,
                         cons = NULL,
                         maxTimeSpan = NULL,
                         updateMOSUM,
                         histRMSE = NULL, factorRMSE = NULL,
                         boundaryRMSE = FALSE,
                         allowImmediateConfirm = FALSE,
                         factorRMSE_immediate = NULL,
                         rejectPositiveBp = FALSE) 
{
  if (!is.na(obj$breakpoint)) 
    return(TRUE)
  if (missing(data)) {
    if (is.null(obj$data)) {
      data <- list()
    }
    else {
      data <- get(obj$data)     
    }
  }
  
  mf <- model.frame(obj$formula, data = data)  # mf has columns: response trend   
  y <- as.matrix(model.response(mf))           # y is reponse as matrix (N x 1)
  modelterms <- terms(obj$formula, data = data)
  x <- model.matrix(modelterms, data = data)   # x has columns: (Intercept) trend   
  
  if (nrow(x) <= obj$last) 
    return(obj)
  if (nrow(x) != nrow(y)) 
    stop("response and regressors must have the same number of rows")
  if (ncol(y) != 1) 
    stop("multivariate response not implemented yet")
  foundBreak <- FALSE 
  
  # Implemented "OLS-MOSUM" or "OLS-CUSUM"
  if ((obj$type == "OLS-MOSUM") | (obj$type == "OLS-CUSUM")) {
    if (obj$type == "OLS-CUSUM") {  # see else
      obj$process <- obj$computeEmpProc(x, y)[-(1:obj$histsize)]     # computeEmpProc(x, y) is a function?
    } else {   # else (obj$type == "OLS-MOSUM")
     # *****************************************************************
      obj$process <- obj$computeEmpProc(x, y)[-(1:length(obj$efpprocess))]     # What is the ( ) indexing? Aha, just running a function with arguments in parentheses
     # *****************************************************************
    }
  } else {
    stop("Only OLS-MOSUM or OLS-CUSUM are implemented type")
  }
    # ************************************************
    boundary <- obj$border((obj$histsize + 1):nrow(x))                  # boundary; border() is a function? Yes border <- function(k) critval * sqrt(2 * logPlus(k/histsize))
    obj$statistic <- max(abs(obj$process))
    # ************************************************
    
    # ************************************************
    # Below is original code:
    # ************************************************
    #   if (!foundBreak & any(abs(obj$process) > boundary)) {    # process > boundary. 
  #     foundBreak <- TRUE
  #     obj$breakpoint <- min(which(abs(obj$process) > boundary)) +  # min() so the earliest date when process > boundary?
  #       obj$histsize
  #     if (verbose) 
  #       cat("Break detected at observation #", obj$breakpoint, 
  #           "\n")
  #   }
  #   obj$lastcoef <- NULL  
  # }
  
    # ************************************************
    # Below is modified code:
    # ************************************************
    # Create a df in mefp obj to store flag information
    obj$dataDf <- data         # Not subset to monitoring period, cause the first obs in monitoring period requires previous obs in calculating MOSUM
   
    # MOSUM time (yes this is correct, the window is backward based on Eq.2 in j.rse.2015.08.020)
    mosTime_idx <- (obj$histsize+1):length(data$time)
    # above same as mosTime_idx <- which(data$time >= start)
    mosTime <- data$time[mosTime_idx]
    
    # Add predicted NDMI column
    obj$dataDf$predicted <- x %*% obj$histcoef  
    obj$dataDf$predicted <- as.numeric(obj$dataDf$predicted)
       
    # ******************************************************************
    # Update 2018-02-19: option RMSE as boundary
    # ******************************************************************
    # Add process and boundary values at the corresponding MOSUM time
    if(boundaryRMSE) {
      obj$dataDf[mosTime_idx, "boundary"] <- factorRMSE * histRMSE        # alternative boundary defined here
      obj$dataDf[mosTime_idx, "process"] <- NA
    } else {
      obj$dataDf[mosTime_idx, "process"] <- obj$process                    # process here is updatable!
      obj$dataDf[mosTime_idx, "boundary"] <- boundary
    }
    # ******************************************************************
    
    # For comparison, add columns of updated values
    obj$dataDf[mosTime_idx, "response_upd"] <- obj$dataDf[mosTime_idx, "response"]
    obj$dataDf[mosTime_idx, "process_upd"] <- obj$dataDf[mosTime_idx, "process"]
    
    # Add initialized flag
    obj$dataDf$flag <- NA

    # Replace  (not needed if doesn't recompute process)
    obj$computeEmpProc_mod <- computeEmpProc_mod
    environment(obj$computeEmpProc_mod) <- environment(obj$computeEmpProc)
    
    # Add breakpoint_firstFlagged storage
    obj$breakpoint_firstFlagged <- NA
    
    # Store histRMSE (same for all rows in one ts) to ease access later
    
    
    
    if (!foundBreak) {
      # obj$process needs to be re-computed when an obs is unflagged
      # Update: NO, if MOSUM window doesn't look backward!
      # Update: from the code it seems the window is forward, but I'm not 100% sure.
      # So, just omit the unflagged obs, thus need to re-compute process.
      # Update: Eq.(2) in DeVries et al. (2015) [j.rse.2015.08.020] shows it's indeed backward!! ***
      # So, MUST omit the unflagged obs, thus need to re-compute process.
       
      # Consecutive anomaly detection can be done by two code approaches:
      # (1) Run length encoding (rle()), which evaluated whole time series (e.g. rgrowth::tsreg())
      # (2) Emulate NRT, thus evaluate new obs as it comes, iteratively
      # Here we attempt (2) to better emulate NRT scenario
      
      for(i in mosTime_idx[1:(length(mosTime_idx)-cons+1)]) {
        nowIdx <- i:(i+cons-1)
        # **********************************************************
        if(boundaryRMSE) {  # process is residual to be compared against histRMSE * factorRMSE
          # Update 2018-03-06: if residual is large enough, confirm immediately
          if(allowImmediateConfirm) {
            # Evaluate obs i only
            iPred <- obj$dataDf$predicted[i]
            iObs <- obj$dataDf$response_upd[i]
            iResid <- iObs - iPred
            iResidAsHistRMSE <- abs(iResid) / histRMSE
            if(iResidAsHistRMSE > factorRMSE_immediate) {
              obj$dataDf$flag[i] <- "change_confirmed"   
              foundBreak <- TRUE
              obj$breakpoint <- i      
              if (verbose) 
                cat("Break detected at observation #", obj$breakpoint, 
                    "\n")
              break
            }
          }
          
          # Predicted using historical model
          nowPred <- obj$dataDf$predicted[nowIdx]
          # Observed
          nowObs <- obj$dataDf$response_upd[nowIdx]
          # Residual
          nowProcess <- nowObs - nowPred
          obj$dataDf$process_upd[nowIdx] <- nowProcess
          # **********************************************************
        } else {
          nowProcess <- obj$dataDf$process_upd[nowIdx]
        }  
        # the boundary here already given before as either statistical boundary or (factorRMSE * histRMSE)
        nowBoundary <- obj$dataDf$boundary[nowIdx] 
        
        # Update 2018-04-26: reject positive breakpoint
        # Previous code: nowCond <- abs(nowProcess) > nowBoundary
        if(rejectPositiveBp) {                                                   # rejectPositiveBp *******
          nowCond <- (abs(nowProcess) > nowBoundary) & (nowProcess < 0)
        } else {
          nowCond <- abs(nowProcess) > nowBoundary
        }
        
        # Confirm change if all consecutive obs are anomalies
        if(all(nowCond) == TRUE) {  # same as if(all(nowCond))
          timeSpan <- (obj$dataDf$time[nowIdx[length(nowIdx)]]) - (obj$dataDf$time[nowIdx[1]])
          if(timeSpan <= maxTimeSpan) {
            obj$dataDf$flag[nowIdx[1:(length(nowIdx)-1)]] <- "change_flagged"   
            obj$dataDf$flag[nowIdx[length(nowIdx)]] <- "change_confirmed"   
            foundBreak <- TRUE
            obj$breakpoint_firstFlagged <- nowIdx[1]      # change at time i i.e. earliest change flag OR
            obj$breakpoint <- nowIdx[length(nowIdx)]      # change at time (i+cons-1) i.e. when change is confirmed
            if (verbose) 
              cat("Break detected at observation #", obj$breakpoint, 
                  "\n")
            break                                                    # detect one earliest event only
          }
        }
        
        # Mark as "olfFlag" if obs i (first in current window) is anomaly but the consecutive ones are not anomalies (else to above if)
        if(nowCond[1] == TRUE) {
          obj$dataDf$flag[i] <- "old_flag"
          # Omit the oldFlag, recompute process. See R/Rfunction/computeEmpProc_mod.R for more details.
          # Update: tried the above, due to rolling MOSUM window it significantly reduces process values for many subsequent obs leading to no process > boundary
          # Without recomputing process however, cons = 3 can still cause false positive
          if(boundaryRMSE) updateMOSUM <- FALSE     # If use RMSE as boundary, MOSUM not used
          if(updateMOSUM) {
            y[i] <- NA  # y is used in computeEmpProc_mod()
            obj$dataDf$response_upd[i] <- NA
            obj$dataDf$process_upd[mosTime_idx] <- obj$computeEmpProc_mod(x, y)[-(1:length(obj$efpprocess))]
          }
        }
      } # end for(i) loop
    }
    
  obj$lastcoef <- NULL              # Not sure what's this for
  obj$last <- nrow(x)
  obj$call <- match.call()
  # HH added
  if(boundaryRMSE) {
    obj$histrmse <- histRMSE
    obj$factrmse <- factorRMSE
  }
  
  return(obj)
}
  
# Check the flag assignment in Viewer panel              # To comment out *******************
# datatable(obj$dataDf)

# Visualize MOSUM                                         # To comment out ******************************************
# default_op <- par()
# lo <- matrix(c(1:2), nr=2, nc=1)
# layout(lo)
# op <- par(mar = c(0, 5, 0, 5), oma = c(3, 3, 3, 3))
#   
# mosTime_idx <- (obj$histsize+1):nrow(data)  
# plot(data[mosTime_idx, "time"], abs(obj$process), pch = 19, cex = 1, col = "blue", type = "b",
#      xlim = c(1999, 2016), xlab = '', xaxt = 'n', xaxp = c(1999, 2016, 17))
# abline(v = seq(1999, 2016, 1), h = seq(0, 20, 2.5), col = "grey", lty = 2)
# points(data[mosTime_idx,"time"], boundary, col = "red", cex = 1, pch = 19, type = "b")
# plot(data[mosTime_idx,"time"], data[mosTime_idx, "response"], cex = 1, pch = 19, col = "dark green", type = "b", 
#      xlim = c(1999, 2016), ylim = c(-0.2, 0.6), xaxp = c(1999, 2016, 17))   
# abline(v = seq(1999, 2016, 1), h = seq(-0.2, 0.6, 0.1), col = "grey", lty = 2)
# layout(1)
# par(default_op)
  
