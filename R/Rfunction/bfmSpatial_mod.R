# # The input
# # See function arguments
# 
# 
# # The output
# bfm$breakpoint
# bfm$breakpoint_firstFlagged
# bfm$magnitude
# # subset(z$mefp$dataDf, flag == "change_flagged")[1,"response"] # no need
# # subset(z$mefp$dataDf, flag == "change_flagged")[1,"predicted"] # no need
# subset(bfm$mefp$dataDf, flag == "change_flagged")[1,"process_upd"]
# bfm$mefp$histrmse
# 
# 
# # Additonal output
# # (a) Slope, intercept, and rsq of the linear trend model as indicator of noise-impacted historical trend
# coef(bfm$model)[2] # slope
# coef(bfm$model)[1] # intercept
# summary(bfm$model)$adj.r.squared
# 
# # (b) No. of non-NA observation in history, and in monitoring period
# NROW(subset(bfm$mefp$dataDf, time >= start))
# NROW(subset(bfm$mefp$dataDf, time < start))
# 
# # (c) Length of history, and length of monitoring
# diff(bfm$history)
# diff(bfm$monitor)


# Debug                                    # To comment out !!!!!!!!!!!
# x <- NDMI.DG1.unique



# The function
# IMPORTANT NOTICE: Had to disable snap date in bfastbfastmonitor_mod() so the date may have slight mismatch
# But ok if change date aggregated to week/month/year


bfmSpatial_mod <- function(x, 
                           dates = NULL,                
                           start, 
                           historyNoiseRemoved,
                           searchWindow = 1,
                           history = "all",
                           maxTimeSpan = 2,
                           cons,
                           updateMOSUM,
                           boundaryRMSE,
                           factorRMSE,
                           allowImmediateConfirm,
                           factorRMSE_immediate,
                           mc.cores = 1,            # mc.cores > 1 doesn't work in windows
                           returnLayers = c("breakpoint", "breakpoint.firstFlagged", "magnitude", "residual.firstFlagged",
                                            "history.model.RMSE", "history.model.slope", "history.model.intercept", "adj.r.squared",
                                            "history.length.years", "monitor.length.years", "history.no.of.valid.obs", "monitor.no.of.valid.obs", "error"),
                           sensor = NULL, ...) {
  
  if (is.character(x)) {
    x <- brick(x)
  }
  if (is.null(dates)) {
    if (is.null(getZ(x))) {
      if (!.isLandsatSceneID(x)) {
        stop("A date vector must be supplied, either via the date argument, the z dimension of x or comprised in names(x)")
      }
      else {
        dates <- as.Date(getSceneinfo_mod(names(x))$date)
      }
    }
    else {
      dates <- getZ(x)
    }
  }

  if (!is.null(sensor)) {
    if (!.isLandsatSceneID(x)) {
      warning("Cannot subset by sensor if names(x) do not correspond to Landsat sceneID's. Ignoring...\n")
      sensor <- NULL
    }
    else {
      s <- getSceneinfo(names(x))
      s <- s[which(s$sensor %in% sensor), ]
    }
  }
  
  # Function defined to run bfm, the function is called by mc.calc() later
  # fun returns a vector, mc.calc converts the vector into separate raster layers?
  fun <- function(x) {
    
    if (!is.null(sensor)) 
      x <- x[which(s$sensor %in% sensor)]
    
    # Get non-NA date in original (irregular) ts
    # now.dateNoNA <- index(x[!is.na(x)])
    
    # Regularize the ts as required by bfastmonitor
    ts <- bfastts(x, dates = dates, type = "irregular")
    
    if (!all(is.na(ts))) {
      bfm <- try(bfastmonitor_mod(
        ts,                                          
        start = start,
        formula = response~trend,      
        plot = FALSE, 
        h = 0.25, 
        history = history,
        historyNoiseRemoved = historyNoiseRemoved,
        allNoiseRemoved = FALSE,
        searchWindow = searchWindow,
        cons = cons,
        maxTimeSpan = maxTimeSpan,
        updateMOSUM = updateMOSUM,
        boundaryRMSE = boundaryRMSE,
        factorRMSE = factorRMSE,
        originalDateNoNA = NULL,                              # Had to disable snap date        
        allowImmediateConfirm = allowImmediateConfirm,
        factorRMSE_immediate = factorRMSE_immediate
      ), silent = FALSE)                                      # silent = TRUE
      if (class(bfm) == "try-error") {
        bkpt <- NA
        bkpt.firstFlagged <- NA
        magn <- NA
        resid.firstFlagged <- NA
        histRMSE <- NA
        mod.slope <- NA
        mod.intercept <- NA
        adj.r2 <- NA
        len.history <- NA
        len.monitor <- NA
        nobs.history <- NA
        nobs.monitor <-NA
        err <- 1
      }
      else {
        bkpt <- bfm$breakpoint
        bkpt.firstFlagged <- bfm$breakpoint_firstFlagged
        magn <- bfm$magnitude
        resid.firstFlagged <- subset(bfm$mefp$dataDf, flag == "change_flagged")[1,"process_upd"]
        histRMSE <- bfm$mefp$histrmse
        mod.slope <- coef(bfm$model)[2] 
        mod.intercept <- coef(bfm$model)[1] 
        adj.r2 <- summary(bfm$model)$adj.r.squared
        len.history <- diff(bfm$history)
        len.monitor <- diff(bfm$monitor)
        nobs.history <- NROW(subset(bfm$mefp$dataDf, time < start))
        nobs.monitor <- NROW(subset(bfm$mefp$dataDf, time >= start))
        err <- NA
      }
    }
    else {
      bkpt <- NA
      bkpt.firstFlagged <- NA
      magn <- NA
      resid.firstFlagged <- NA
      histRMSE <- NA
      mod.slope <- NA
      mod.intercept <- NA
      adj.r2 <- NA
      len.history <- NA
      len.monitor <- NA
      nobs.history <- NA
      nobs.monitor <-NA
      err <- NA
    }
    
    res <- c(bkpt, bkpt.firstFlagged, magn, resid.firstFlagged, 
             histRMSE, mod.slope, mod.intercept, adj.r2, 
             len.history, len.monitor, nobs.history, nobs.monitor, err) 
    
    names(res) <- c("breakpoint", "breakpoint.firstFlagged", "magnitude", "residual.firstFlagged",
                    "history.model.RMSE", "history.model.slope", "history.model.intercept", "adj.r.squared",
                    "history.length.years", "monitor.length.years", "history.no.of.valid.obs", "monitor.no.of.valid.obs", "error")
    
    res <- res[which(names(res) %in% returnLayers)]

    return(res)
  }
  
  out <- bfastSpatial::mc.calc(x = x, fun = fun, mc.cores = mc.cores, ...)
  
}


