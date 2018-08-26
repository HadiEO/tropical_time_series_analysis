# Debug                                                          # to comment out!!
# extrNDMI = extrNDMIsub.SC1
# samples = refPixels.SC1
# start = c(2000,1) # ref.firstDate$SC1
# bfmOutName = str_c(path, "/bfm_results/debug.rds")
# outSamplesName = str_c(path, "/accuracy_results/debug.rds")
# historyNoiseRemoved = historyNoiseRemoved
# allNoiseRemoved = FALSE
# cons = cons
# maxTimeSpan = maxTimeSpan
# updateMOSUM = updateMOSUM
# boundaryRMSE = boundaryRMSE
# factorRMSE = factorRMSE


# Criteria 
# cons <- 4   # Required no. of consecutive flagged change to confirm change. 
# If set to 1, consecutive criterion not applied. 
# maxTimeSpan <- 2 # Required maximum time span between the consecutive flagged change [decimal years]
# bfm.ls$`1131`$mefp has: histrmse, factrmse
# bfm.ls$`1131`$mefp$dataDf has: time, prediction, boundary, process, response_upd, process_upd, flag
# bfm.ls$`1131` has: magnitude, mefp, breakpoint, breakpoint_firstFlagged, failedTooFewHistObs
# Leave calculations related to accuracy assessment outside the function!


# Currently using sp object and attach the change information to the sp object's data frame.
# Todo: implement with sf object for much simpler tidyverse-based code


attachBfmFlagToSp <- function(extrNDMI, samples, start, bfmOutName, outSamplesName, oldFlagOutName, history = "all",
                              historyNoiseRemoved, allNoiseRemoved = FALSE, searchWindow, cons, maxTimeSpan, updateMOSUM,
                              boundaryRMSE = FALSE, factorRMSE = NULL,
                              allowImmediateConfirm = FALSE, factorRMSE_immediate = NULL, 
                              rejectPositiveBp = FALSE, level = 0.05) {
  samples$Id <- as.character(samples$Id)
  # Create gap-less time series
  extrNDMI.ls <- as.list(extrNDMI)
  bts.ls <- lapply(extrNDMI.ls, FUN = function(z) bfastts(z, dates = index(z), type = "irregular"))
  # Store the original obs date of non-NA obs
  extrNDMI.dateNoNA.ls <- lapply(extrNDMI.ls, 
                        FUN = function(z) index(z[!is.na(z)]))
  
  # Run BFAST Monitor
  bfm.ls <- list()
  for(i in 1:length(bts.ls)) {               # Todo: map2 or pmap
    bfm.ls[[i]] <- bfastmonitor_mod(
                      bts.ls[[i]], # 
                      start = start,
                      formula = response~trend,       # Formula!! **********    
                      plot = FALSE, 
                      h = 0.25, 
                      history = history,
                      historyNoiseRemoved = historyNoiseRemoved,
                      allNoiseRemoved = allNoiseRemoved,
                      searchWindow = searchWindow,
                      cons = cons,
                      maxTimeSpan = maxTimeSpan,
                      updateMOSUM = updateMOSUM,
                      boundaryRMSE = boundaryRMSE,
                      factorRMSE = factorRMSE,
                      originalDateNoNA = extrNDMI.dateNoNA.ls[[i]], #
                      allowImmediateConfirm = allowImmediateConfirm,
                      factorRMSE_immediate = factorRMSE_immediate,
                      rejectPositiveBp = rejectPositiveBp,
                      level = level
    )
  }
  names(bfm.ls) <- names(bts.ls)
  
  
  # Save bfm result
  write_rds(bfm.ls, bfmOutName)
  
  # Any sample which bfm failed due to too few hist obs? If history = "all" (not "ROC") in our case none should fail
  # bfm.failed.ls <- lapply(bfm.ls, FUN = function(z) z$failedTooFewHistObs)
  
  # Reference change
  samples$ref.detection <- samples$Disturbed
  # Tell sample if BFAST detects DISTURBANCE (1) or NON-DISTURBANCE (0)
  bfm.magn.ls <- lapply(bfm.ls, FUN = function(z) z$magnitude)
  # Disturbance event
  bfm.dist.ls <- lapply(bfm.ls, FUN = function(z) ifelse(!is.na(z$breakpoint), 1, 0))
  # Disturbance event also only if breakpoint has negative magnitude
  bfm.dist.ls.negMagn <- lapply(bfm.ls, FUN = function(z) ifelse((!is.na(z$breakpoint)) & (z$magnitude < 0), 1, 0))

  # Record the breakpoint date. 
  bfm.dateConfirmed.ls <- lapply(bfm.ls, FUN = function(z) z$breakpoint)
  # FirstFlagged here means first of the consecutive flags of a confirmed change
  bfm.dateFirstFlagged.ls <- lapply(bfm.ls, FUN = function(z) z$breakpoint_firstFlagged)
  # Observed and predicted values at breakpoint_firstFlagged (hence the [1,])
  bfm.obs.firstFlagged.ls <- lapply(bfm.ls, FUN = function(z) subset(z$mefp$dataDf, flag == "change_flagged")[1,"response"])
  bfm.pred.firstFlagged.ls <- lapply(bfm.ls, FUN = function(z) subset(z$mefp$dataDf, flag == "change_flagged")[1,"predicted"])
  # Residual = obs - pred. This is the same as process_upd
  bfm.resid.firstFlagged.ls <- lapply(bfm.ls, FUN = function(z) subset(z$mefp$dataDf, flag == "change_flagged")[1,"process_upd"])
  # bfm.resid.firstFlagged.ls <- mapply('-', bfm.obs.firstFlagged.ls, bfm.pred.firstFlagged.ls, SIMPLIFY = FALSE)
  
  # Check if there is noise replaced as NA
  bfm.noiseToNA.ls <- lapply(bfm.ls, FUN = function(z) z$noiseToNA)
  
  
  # Add the above info to samples data frame, matching the pixel Id
  # names() of all the lapply(bfm.ls) results above are identical
  for(i in 1:length(names(bfm.dist.ls))) {
    samples[which(samples$Id == names(bfm.dist.ls)[i]), "bfm.obs.firstFlagged"] <- bfm.obs.firstFlagged.ls[[i]]
    samples[which(samples$Id == names(bfm.dist.ls)[i]), "bfm.pred.firstFlagged"] <- bfm.pred.firstFlagged.ls[[i]]
    samples[which(samples$Id == names(bfm.dist.ls)[i]), "bfm.resid.firstFlagged"] <- bfm.resid.firstFlagged.ls[[i]]
    
    samples[which(samples$Id == names(bfm.dist.ls)[i]), "bfm.magn"] <- bfm.magn.ls[[i]]
    samples[which(samples$Id == names(bfm.dist.ls)[i]), "bfm.detection"] <- bfm.dist.ls[[i]]
    samples[which(samples$Id == names(bfm.dist.ls)[i]), "bfm.detection.negMagn"] <- bfm.dist.ls.negMagn[[i]]
    
    samples[which(samples$Id == names(bfm.dist.ls)[i]), "bfm.date.firstFlagged"] <- bfm.dateFirstFlagged.ls[[i]]
    samples[which(samples$Id == names(bfm.dist.ls)[i]), "bfm.date.confirmed"] <- bfm.dateConfirmed.ls[[i]]
    
    samples[which(samples$Id == names(bfm.dist.ls)[i]), "noiseToNA"] <- bfm.noiseToNA.ls[[i]]
  } 
  # "Date" in samples is reference change date.
  samples$ref.date <- as.Date(samples$Date)     
    
  # "Date_adj" in samples is adjusted reference change date = (Tref - Tprev) / 2
  samples$ref.date.adj <- as.Date(samples$Date_adj)

  # Convert date to Date format so can substract to get days
  samples$bfm.date.firstFlagged <- dec2date(samples$bfm.date.firstFlagged)
  samples$bfm.date.confirmed <- dec2date(samples$bfm.date.confirmed)
  # Temporal accuracy calculation to be done outside this function
  
  # Snap bfm dates to time series dates (possible bug in bfastts causes missing or duplicate dates in regularized ts (daily), maybe because all years are treated 365 days)
  # This not needed anymore, I have fixed the date mismatch issue, in bfastmonitor_mod()
  # No, there is still difference of 1-day not sure why, so let's snap it.
  for(i in 1:length(names(extrNDMI.ls))) {
    # The date in original ts
    now.extrNDMI.date <- index(extrNDMI.ls[[i]][!is.na(extrNDMI.ls[[i]])])  # no NA
    # Reference, need index of obs at ref date (not.NA)
    now.date.ref <- samples@data[which(samples@data$Id == names(extrNDMI.ls)[i]), "ref.date"]
    ref.closest.extrNDMI.idx <- which.min(abs(now.extrNDMI.date - now.date.ref)) #
    
    if(!is.na(now.date.ref)) {
      # First flagged, requires 
      now.date.firstFlagged <- samples@data[which(samples@data$Id == names(extrNDMI.ls)[i]), "bfm.date.firstFlagged"]
      if(!is.na(now.date.firstFlagged)) {
        firstFlagged.closest.extrNDMI.idx <- which.min(abs(now.extrNDMI.date - now.date.firstFlagged)) #
        firstFlagged.closest.extrNDMI.date <- now.extrNDMI.date[firstFlagged.closest.extrNDMI.idx]
        samples[which(samples$Id == names(extrNDMI.ls)[i]), "bfm.date.firstFlagged"] <- firstFlagged.closest.extrNDMI.date
        # Store temporal differences in terms of no. of obs (non-NA)
        # between bfm date first flagged and ref.date (with ref.adj is + 0.5 obs)
        samples[which(samples$Id == names(extrNDMI.ls)[i]), "lag.obs.firstFlagged"] <- 
          firstFlagged.closest.extrNDMI.idx - ref.closest.extrNDMI.idx
      } else {
        samples[which(samples$Id == names(extrNDMI.ls)[i]), "bfm.date.firstFlagged"] <- NA
        samples[which(samples$Id == names(extrNDMI.ls)[i]), "lag.obs.firstFlagged"] <- NA
      }
      
      
      # Confirmed
      now.date.confirmed <- samples@data[which(samples@data$Id == names(extrNDMI.ls)[i]), "bfm.date.confirmed"]
      if(!is.na(now.date.confirmed)) {
        confirmed.closest.extrNDMI.idx <- which.min(abs(now.extrNDMI.date - now.date.confirmed)) #
        confirmed.closest.extrNDMI.date <- now.extrNDMI.date[confirmed.closest.extrNDMI.idx]
        samples[which(samples$Id == names(extrNDMI.ls)[i]), "bfm.date.confirmed"] <- confirmed.closest.extrNDMI.date
        # Store temporal differences in terms of no. of obs (non-NA)
        # between bfm date confirmed and ref.date (with ref.adj is + 0.5 obs)
        samples[which(samples$Id == names(extrNDMI.ls)[i]), "lag.obs.confirmed"] <- 
          confirmed.closest.extrNDMI.idx - ref.closest.extrNDMI.idx
      } else {
        samples[which(samples$Id == names(extrNDMI.ls)[i]), "bfm.date.confirmed"] <- NA
        samples[which(samples$Id == names(extrNDMI.ls)[i]), "lag.obs.confirmed"] <- NA
      }
    } else {
      samples[which(samples$Id == names(extrNDMI.ls)[i]), "bfm.date.firstFlagged"] <- NA
      samples[which(samples$Id == names(extrNDMI.ls)[i]), "lag.obs.firstFlagged"] <- NA
      samples[which(samples$Id == names(extrNDMI.ls)[i]), "bfm.date.confirmed"] <- NA
      samples[which(samples$Id == names(extrNDMI.ls)[i]), "lag.obs.confirmed"] <- NA
    }

  }
  
  # Add histRMSE
  if(boundaryRMSE) {
    bfm.histRMSE.ls <- lapply(bfm.ls, FUN = function(z) z$mefp$histrmse)
    for(i in 1:length(names(bfm.dist.ls))) {
      samples[which(samples$Id == names(bfm.dist.ls)[i]), "bfm.histRMSE"] <- bfm.histRMSE.ls[[i]]
    }
  }
  
  # Save samples with added columns of bfm results
  write_rds(samples, outSamplesName)
  
  # Save oldFlag values in separate .rds
  bfm.obs.oldFlag.ls <- lapply(bfm.ls, FUN = function(z) subset(z$mefp$dataDf, flag == "old_flag")[,"response"])
  bfm.pred.oldFlag.ls <- lapply(bfm.ls, FUN = function(z) subset(z$mefp$dataDf, flag == "old_flag")[,"predicted"])
  bfm.resid.oldFlag.ls <- lapply(bfm.ls, FUN = function(z) subset(z$mefp$dataDf, flag == "old_flag")[,"process_upd"])
  # oldFlag values in terms of histRMSE
  if(boundaryRMSE) {
    bfm.residDivHistRMSE.oldFlag.ls <-
      lapply(bfm.ls, FUN = function(z) subset(z$mefp$dataDf, flag == "old_flag")[,"process_upd"] /
                                       z$mefp$histrmse)
  }
  
  # List them together
  if(boundaryRMSE) {
    bfm.values.oldFlag.ls <- list(bfm.obs.oldFlag.ls = bfm.obs.oldFlag.ls,
                                  bfm.pred.oldFlag.ls = bfm.pred.oldFlag.ls,
                                  bfm.resid.oldFlag.ls = bfm.resid.oldFlag.ls,
                                  bfm.residDivHistRMSE.oldFlag.ls = bfm.residDivHistRMSE.oldFlag.ls)
  } else {
    bfm.values.oldFlag.ls <- list(bfm.obs.oldFlag.ls = bfm.obs.oldFlag.ls,
                                  bfm.pred.oldFlag.ls = bfm.pred.oldFlag.ls,
                                  bfm.resid.oldFlag.ls = bfm.resid.oldFlag.ls)
  }
  
  write_rds(bfm.values.oldFlag.ls, oldFlagOutName)
  
  # Object directly returned by function (note some objects are written to disk in the function)
  return(samples)
}
