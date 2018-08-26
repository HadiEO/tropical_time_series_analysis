source("R/Rfunction/bfmSpatial_mod.R")

# The raster time stack (unique dates, but the end date is till 2017)
NDMI.DG1.unique <- read_rds(str_c(path, "/raster_time_stack/ndmi_rds/ndmi_DG_1_unique.rds"))


# Cut the raster time stack end date
NDMI.DG1.unique <- subsetRasterTS(NDMI.DG1.unique, maxDate = c(2015, 227))

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

write_rds(bfmSpatial.DG1.run27, 
          str_c(path, "/bfmSpatial_results/bfmSpatial_DG1_run27.rds"))

raster::plot(bfmSpatial.DG1.run27$breakpoint)

