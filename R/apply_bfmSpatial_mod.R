source("R/Rfunction/bfmSpatial_mod.R")
# Had to disable snap date in bfastbfastmonitor_mod() so the date may have slight mismatch
# Round it to month

# The raster time stack (unique dates, but the end date is till 2017)
NDMI.DG1.unique <- read_rds(str_c(path, "/raster_time_stack/ndmi_rds/ndmi_DG_1_unique.rds"))
NDMI.DG2.unique <- read_rds(str_c(path, "/raster_time_stack/ndmi_rds/ndmi_DG_2_unique.rds"))
NDMI.SC1.unique <- read_rds(str_c(path, "/raster_time_stack/ndmi_rds/ndmi_SC_1_unique.rds"))
NDMI.SQ9.unique <- read_rds(str_c(path, "/raster_time_stack/ndmi_rds/ndmi_sq_9_unique.rds"))
NDMI.SQ11.unique <- read_rds(str_c(path, "/raster_time_stack/ndmi_rds/ndmi_sq_11_unique.rds"))
NDMI.SQ13.unique <- read_rds(str_c(path, "/raster_time_stack/ndmi_rds/ndmi_sq_13_unique.rds"))

# Make sure the end date is ok
# (a) The last date of VHSR
ref.lastDate <- list(DG1 = as.Date("2015-08-15"), DG2 = as.Date("2015-08-08"),
                     SC1 = as.Date("2014-02-04"), SQ9 = as.Date("2014-05-13"), 
                     SQ11 = as.Date("2014-02-04"), SQ13 = as.Date("2014-05-13"))

# SC1 end date extended to allow change detection to be confirmable
ref.lastDate$SC1 <- ref.lastDate$SC1 + 365

# Update: test SC1 until the end of latest VHSR year
ref.lastDate$SC1 <- as.Date("2014-12-31")

# Update: test all scenes until the end of the latest VHSR year, to compare with Hansen
ref.lastDate <- list(DG1 = as.Date("2015-12-31"), DG2 = as.Date("2015-12-31"),
                     SC1 = as.Date("2014-12-31"), SQ9 = as.Date("2014-12-31"), 
                     SQ11 = as.Date("2014-12-31"), SQ13 = as.Date("2014-12-31"))



# (b) Need these dates in c(year, jday) 
source("R/Rfunction/dateToYearJday.R")
ref.lastDate <- lapply(ref.lastDate, dateToYearJday)

# (c) Cut the raster time stack end date
NDMI.DG1.unique <- subsetRasterTS(NDMI.DG1.unique, maxDate = ref.lastDate$DG1)
NDMI.DG2.unique <- subsetRasterTS(NDMI.DG2.unique, maxDate = ref.lastDate$DG2)
NDMI.SC1.unique <- subsetRasterTS(NDMI.SC1.unique, maxDate = ref.lastDate$SC1)
NDMI.SQ9.unique <- subsetRasterTS(NDMI.SQ9.unique, maxDate = ref.lastDate$SQ9)
NDMI.SQ11.unique <- subsetRasterTS(NDMI.SQ11.unique, maxDate = ref.lastDate$SQ11)
NDMI.SQ13.unique <- subsetRasterTS(NDMI.SQ13.unique, maxDate = ref.lastDate$SQ13)


# ***************************************************************************
# Run bfmSpatial_mod
# ***************************************************************************
# Fixed setting
searchWindow <- 1
maxTimeSpan <- 2
start <- c(2000,1)
history = "all"


# Run 27: boundary 4 * histRMSE, *without* history noise removal, cons = 3
run <- "run27"
historyNoiseRemoved <- FALSE
allNoiseRemoved = FALSE
boundaryRMSE <- TRUE
factorRMSE <- 4
cons <- 3 
updateMOSUM <- FALSE    
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE


# ***************************************************************************
# DG1
# ***************************************************************************
time.bfmSpatial.run27 <- system.time(
  bfmSpatial.DG1.run27 <- 
    bfmSpatial_mod(x = NDMI.DG1.unique, 
                   dates = NULL,           
                   start, 
                   historyNoiseRemoved,
                   searchWindow,
                   history, 
                   maxTimeSpan,
                   cons,
                   updateMOSUM,
                   boundaryRMSE,
                   factorRMSE,
                   allowImmediateConfirm,
                   factorRMSE_immediate,
                   mc.cores = 1, 
                   returnLayers = c("breakpoint", "breakpoint.firstFlagged", "magnitude", "residual.firstFlagged",
                                    "history.model.RMSE", "history.model.slope", "history.model.intercept", "adj.r.squared",
                                    "history.length.years", "monitor.length.years", "history.no.of.valid.obs", "monitor.no.of.valid.obs", "error"),
                   sensor = NULL)
  
)

# write_rds(bfmSpatial.DG1.run27, 
#           str_c(path, "/bfmSpatial_results/bfmSpatial_DG1_run27.rds"))

write_rds(bfmSpatial.DG1.run27, 
          str_c(path, "/bfmSpatial_results/bfmSpatial_DG1_run27_untilEndOfVHSRYear.rds"))

raster::plot(bfmSpatial.DG1.run27$breakpoint)







# ***************************************************************************
# DG2
# ***************************************************************************
time.bfmSpatial.DG2.run27 <- system.time(
  bfmSpatial.DG2.run27 <- 
    bfmSpatial_mod(x = NDMI.DG2.unique, 
                   dates = NULL,           
                   start, 
                   historyNoiseRemoved,
                   searchWindow,
                   history, 
                   maxTimeSpan,
                   cons,
                   updateMOSUM,
                   boundaryRMSE,
                   factorRMSE,
                   allowImmediateConfirm,
                   factorRMSE_immediate,
                   mc.cores = 1, 
                   returnLayers = c("breakpoint", "breakpoint.firstFlagged", "magnitude", "residual.firstFlagged",
                                    "history.model.RMSE", "history.model.slope", "history.model.intercept", "adj.r.squared",
                                    "history.length.years", "monitor.length.years", "history.no.of.valid.obs", "monitor.no.of.valid.obs", "error"),
                   sensor = NULL)
  
)


# write_rds(bfmSpatial.DG2.run27, 
#           str_c(path, "/bfmSpatial_results/bfmSpatial_DG2_run27.rds"))

write_rds(bfmSpatial.DG2.run27, 
          str_c(path, "/bfmSpatial_results/bfmSpatial_DG2_run27_untilEndOfVHSRYear.rds"))
raster::plot(bfmSpatial.DG2.run27$breakpoint)

# ***************************************************************************
# SC1
# ***************************************************************************
# time.bfmSpatial.SC1.run27 <- system.time(
#   bfmSpatial.SC1.run27 <- 
#     bfmSpatial_mod(x = NDMI.SC1.unique, 
#                    dates = NULL,           
#                    start, 
#                    historyNoiseRemoved,
#                    searchWindow,
#                    history, 
#                    maxTimeSpan,
#                    cons,
#                    updateMOSUM,
#                    boundaryRMSE,
#                    factorRMSE,
#                    allowImmediateConfirm,
#                    factorRMSE_immediate,
#                    mc.cores = 1, 
#                    returnLayers = c("breakpoint", "breakpoint.firstFlagged", "magnitude", "residual.firstFlagged",
#                                     "history.model.RMSE", "history.model.slope", "history.model.intercept", "adj.r.squared",
#                                     "history.length.years", "monitor.length.years", "history.no.of.valid.obs", "monitor.no.of.valid.obs", "error"),
#                    sensor = NULL)
#   
# )


# write_rds(bfmSpatial.SC1.run27, 
#           str_c(path, "/bfmSpatial_results/bfmSpatial_SC1_run27.rds"))
# raster::plot(bfmSpatial.SC1.run27$breakpoint)

# write_rds(bfmSpatial.SC1.run27, 
#           str_c(path, "/bfmSpatial_results/bfmSpatial_SC1_run27_notAdd1Year.rds"))
# raster::plot(bfmSpatial.SC1.run27$breakpoint)

write_rds(bfmSpatial.SC1.run27, 
          str_c(path, "/bfmSpatial_results/bfmSpatial_SC1_run27_untilEndOfVHSRYear.rds"))
raster::plot(bfmSpatial.SC1.run27$breakpoint)



# ***************************************************************************
# SQ9
# ***************************************************************************
time.bfmSpatial.SQ9.run27 <- system.time(
  bfmSpatial.SQ9.run27 <- 
    bfmSpatial_mod(x = NDMI.SQ9.unique, 
                   dates = NULL,           
                   start, 
                   historyNoiseRemoved,
                   searchWindow,
                   history, 
                   maxTimeSpan,
                   cons,
                   updateMOSUM,
                   boundaryRMSE,
                   factorRMSE,
                   allowImmediateConfirm,
                   factorRMSE_immediate,
                   mc.cores = 1, 
                   returnLayers = c("breakpoint", "breakpoint.firstFlagged", "magnitude", "residual.firstFlagged",
                                    "history.model.RMSE", "history.model.slope", "history.model.intercept", "adj.r.squared",
                                    "history.length.years", "monitor.length.years", "history.no.of.valid.obs", "monitor.no.of.valid.obs", "error"),
                   sensor = NULL)
  
)

# write_rds(bfmSpatial.SQ9.run27, 
#           str_c(path, "/bfmSpatial_results/bfmSpatial_SQ9_run27.rds"))

write_rds(bfmSpatial.SQ9.run27, 
          str_c(path, "/bfmSpatial_results/bfmSpatial_SQ9_run27_untilEndOfVHSRYear.rds"))
raster::plot(bfmSpatial.SQ9.run27$breakpoint)


# ***************************************************************************
# SQ11
# ***************************************************************************
time.bfmSpatial.SQ11.run27 <- system.time(
  bfmSpatial.SQ11.run27 <- 
    bfmSpatial_mod(x = NDMI.SQ11.unique, 
                   dates = NULL,           
                   start, 
                   historyNoiseRemoved,
                   searchWindow,
                   history, 
                   maxTimeSpan,
                   cons,
                   updateMOSUM,
                   boundaryRMSE,
                   factorRMSE,
                   allowImmediateConfirm,
                   factorRMSE_immediate,
                   mc.cores = 1, 
                   returnLayers = c("breakpoint", "breakpoint.firstFlagged", "magnitude", "residual.firstFlagged",
                                    "history.model.RMSE", "history.model.slope", "history.model.intercept", "adj.r.squared",
                                    "history.length.years", "monitor.length.years", "history.no.of.valid.obs", "monitor.no.of.valid.obs", "error"),
                   sensor = NULL)
  
)

# write_rds(bfmSpatial.SQ11.run27, 
#           str_c(path, "/bfmSpatial_results/bfmSpatial_SQ11_run27.rds"))
write_rds(bfmSpatial.SQ11.run27, 
          str_c(path, "/bfmSpatial_results/bfmSpatial_SQ11_run27_untilEndOfVHSRYear.rds"))

# ***************************************************************************
# SQ13
# ***************************************************************************
time.bfmSpatial.SQ13.run27 <- system.time(
  bfmSpatial.SQ13.run27 <- 
    bfmSpatial_mod(x = NDMI.SQ13.unique, 
                   dates = NULL,           
                   start, 
                   historyNoiseRemoved,
                   searchWindow,
                   history, 
                   maxTimeSpan,
                   cons,
                   updateMOSUM,
                   boundaryRMSE,
                   factorRMSE,
                   allowImmediateConfirm,
                   factorRMSE_immediate,
                   mc.cores = 1, 
                   returnLayers = c("breakpoint", "breakpoint.firstFlagged", "magnitude", "residual.firstFlagged",
                                    "history.model.RMSE", "history.model.slope", "history.model.intercept", "adj.r.squared",
                                    "history.length.years", "monitor.length.years", "history.no.of.valid.obs", "monitor.no.of.valid.obs", "error"),
                   sensor = NULL)
  
)

# write_rds(bfmSpatial.SQ13.run27, 
#           str_c(path, "/bfmSpatial_results/bfmSpatial_SQ13_run27.rds"))
  
write_rds(bfmSpatial.SQ13.run27, 
          str_c(path, "/bfmSpatial_results/bfmSpatial_SQ13_run27_untilEndOfVHSRYear.rds"))


