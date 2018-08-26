# Extracted zoo ts
extrNDMI <- read_rds(str_c(path, "/extracted_time_series/FINALLY_USED/extrNDMIsub_DG1.rds"))
extrNDMI.ls <- as.list(extrNDMI)
demo.bts.ls <- lapply(extrNDMI.ls, FUN = function(z) bfastts(z, dates = time(z), type = "irregular"))

# Store the original obs date of non-NA obs
extrNDMI.dateNoNA.ls <- lapply(extrNDMI.ls, 
                               FUN = function(z) index(z[!is.na(z)]))

# Reference date
ref.date.all <- read_rds(str_c(path, "/from_shiny/", "all_refChangeDate_final_adj_intactNoDate.rds"))


# ********************************************************************
# Which time series Id ? 
# DG1 (677, 904, 908, 1131, 725, 603)
# `677` used in manuscript 
# ********************************************************************
now.ts <- demo.bts.ls$`603`                                 
now.dateNoNA <- extrNDMI.dateNoNA.ls$`603` 
now.refDate <- ref.date.all %>% 
  filter(Scene == "DG1", Id == "603") %>% 
  .[["Date"]]

now.ts.raw <- extrNDMI.ls$'603'

# The coordinate
shp.folder <- paste(path, "/vector_data/FINALLY_USED", sep = "")
refPixels.DG1 <- readOGR(dsn = shp.folder, layer = "meshSelect_prevDG1")
selPixel <- refPixels.DG1[refPixels.DG1$Id == "603",]
coordinates(selPixel)

selPixel <- st_as_sf(selPixel) %>% st_transform(4326)
st_coordinates(selPixel)
st_centroid(selPixel)   # 118.0328 2.304912





# ********************************************************************
# Scenarios for comparison
# RUN THE EACH RUN ARGUMENTS BELOW, THEN THE BFASTMONITOR CALL IN THE NEXT SECTION! ************************
# ********************************************************************
# Fixed setting
searchWindow <- 1
maxTimeSpan <- 2
start <- c(2000,1)
history = "all"


# Run 1: Original bfastmonitor *without* history noise removal
run <- "run1"
historyNoiseRemoved <- FALSE
allNoiseRemoved = FALSE
boundaryRMSE <- FALSE
factorRMSE <- NA
cons <- 1
updateMOSUM <- FALSE    
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE
rejectPositiveBp <- FALSE
level <- 0.05

# Run 5: Modified bfastmonitor *without* history noise removal, cons = 3, updateMOSUM = TRUE
run <- "run5"
historyNoiseRemoved <- FALSE
allNoiseRemoved = FALSE
boundaryRMSE <- FALSE
factorRMSE <- NA
cons <- 3 
updateMOSUM <- TRUE    
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE
rejectPositiveBp <- FALSE
level <- 0.05

# Run 6: Modified bfastmonitor *without* history noise removal, cons = 3, updateMOSUM = FALSE
run <- "run6"
historyNoiseRemoved <- FALSE
allNoiseRemoved = FALSE
boundaryRMSE <- FALSE
factorRMSE <- NA
cons <- 3 
updateMOSUM <- FALSE    
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE
rejectPositiveBp <- FALSE
level <- 0.05

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
rejectPositiveBp <- FALSE
level <- 0.05

# **********************************************************************
# rejectPositiveBp = TRUE, alpha = 0.05 (default)
# **********************************************************************
# Run 1b: Original bfastmonitor *without* history noise removal
run <- "run1b"
historyNoiseRemoved <- FALSE
allNoiseRemoved = FALSE
boundaryRMSE <- FALSE
factorRMSE <- NA
cons <- 1
updateMOSUM <- FALSE    
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE
rejectPositiveBp <- TRUE
level <- 0.05

# Run 5b: Modified bfastmonitor *without* history noise removal, cons = 3, updateMOSUM = TRUE
run <- "run5b"
historyNoiseRemoved <- FALSE
allNoiseRemoved = FALSE
boundaryRMSE <- FALSE
factorRMSE <- NA
cons <- 3 
updateMOSUM <- TRUE    
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE
rejectPositiveBp <- TRUE
level <- 0.05

# Run 6b: Modified bfastmonitor *without* history noise removal, cons = 3, updateMOSUM = FALSE
run <- "run6b"
historyNoiseRemoved <- FALSE
allNoiseRemoved = FALSE
boundaryRMSE <- FALSE
factorRMSE <- NA
cons <- 3 
updateMOSUM <- FALSE    
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE
rejectPositiveBp <- TRUE
level <- 0.05

# Run 27b: boundary 4 * histRMSE, *without* history noise removal, cons = 3
run <- "run27b"
historyNoiseRemoved <- FALSE
allNoiseRemoved = FALSE
boundaryRMSE <- TRUE
factorRMSE <- 4
cons <- 3 
updateMOSUM <- FALSE    
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE
rejectPositiveBp <- TRUE
level <- 0.05


# ********************************************************************
# Run bfastmonitor for different scenarios
# "x" refers to "a", "b", ... i.e. run 1a, 1b, ... based on above setting (make sure to pre-run the correct run arguments!)
# ********************************************************************

# ********************************************************************
# Run 1x -------------------------------------------------------------------
# ********************************************************************
run1x <- bfastmonitor_mod(
  now.ts, # 
  start = start,
  formula = response~trend,      
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
  originalDateNoNA = now.dateNoNA, #
  allowImmediateConfirm = allowImmediateConfirm,
  factorRMSE_immediate = factorRMSE_immediate,
  rejectPositiveBp = rejectPositiveBp,
  level = level
)

# ********************************************************************
# Run 5x -------------------------------------------------------------------
# ********************************************************************
run5x <- bfastmonitor_mod(
  now.ts, # 
  start = start,
  formula = response~trend,      
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
  originalDateNoNA = now.dateNoNA, #
  allowImmediateConfirm = allowImmediateConfirm,
  factorRMSE_immediate = factorRMSE_immediate,
  rejectPositiveBp = rejectPositiveBp,
  level = level
)

# ********************************************************************
# Run 6x -------------------------------------------------------------------
# ********************************************************************
run6x <- bfastmonitor_mod(
  now.ts, # 
  start = start,
  formula = response~trend,      
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
  originalDateNoNA = now.dateNoNA, #
  allowImmediateConfirm = allowImmediateConfirm,
  factorRMSE_immediate = factorRMSE_immediate,
  rejectPositiveBp = rejectPositiveBp,
  level = level
)

# ********************************************************************
# Run 27x -------------------------------------------------------------------
# ********************************************************************
run27x <- bfastmonitor_mod(
  now.ts, # 
  start = start,
  formula = response~trend,      
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
  originalDateNoNA = now.dateNoNA, #
  allowImmediateConfirm = allowImmediateConfirm,
  factorRMSE_immediate = factorRMSE_immediate,
  rejectPositiveBp = rejectPositiveBp,
  level = level
)


# ********************************************************************
# bfm plot -------------------------------------------------------------------
# ********************************************************************
# run1, run5, run6, run27
source("R/Rfunction/bfmPlot_mod.R")
source("R/Rfunction/MOSUM_plot.R")






# ********************************************************************
# run 1x
# ********************************************************************
plot.run1x <- bfmPlot_mod(run1x, plotlabs = "Run 1x",
                     ncols = 1, displayMagn = FALSE, displayResiduals = 'monperiod', displayOldFlag = TRUE,
                     circleVersion = TRUE, displayRefDate = TRUE, refDate = now.refDate) +
  theme_bw() + labs(y = "NDMI", x = "Date") + scale_y_continuous(limits = c(-0.2, 0.6)) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title.x = element_blank(),
          strip.background = element_blank(),
          strip.text.x = element_blank()
        ) +
  annotate("text", label = "(a)", x = as.Date("1989-01-01"), y = -0.15)

# ********************************************************************
# run 5
# ********************************************************************
plot.run5x <- bfmPlot_mod(run5x, plotlabs = "Run 5x",
                         ncols = 1, displayMagn = FALSE, displayResiduals = 'monperiod', displayOldFlag = TRUE,
                         circleVersion = TRUE, displayRefDate = TRUE, refDate = now.refDate) +
  theme_bw() + labs(y = "NDMI", x = "Date") + scale_y_continuous(limits = c(-0.2, 0.6)) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title.x = element_blank(),
        strip.background = element_blank(),
        strip.text.x = element_blank()) +
  annotate("text", label = "(b)", x = as.Date("1989-01-01"), y = -0.15)

# ********************************************************************
# run 6
# ********************************************************************
plot.run6x <- bfmPlot_mod(run6x, plotlabs = "Run 6x",
                         ncols = 1, displayMagn = FALSE, displayResiduals = 'monperiod', displayOldFlag = TRUE,
                         circleVersion = TRUE, displayRefDate = TRUE, refDate = now.refDate) +
  theme_bw() + labs(y = "NDMI", x = "Date") + scale_y_continuous(limits = c(-0.2, 0.6)) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title.x = element_blank(),
        strip.background = element_blank(),
        strip.text.x = element_blank())

# ********************************************************************
# run 27
# ********************************************************************
plot.run27x <- bfmPlot_mod(run27x, plotlabs = "Run 27x",
                         ncols = 1, displayMagn = FALSE, displayResiduals = 'monperiod', displayOldFlag = TRUE,
                         circleVersion = TRUE, displayRefDate = TRUE, refDate = now.refDate) +
  theme_bw() + labs(y = "NDMI", x = "Date") + scale_y_continuous(limits = c(-0.2, 0.6)) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title.x = element_blank(),
        strip.background = element_blank(),
        strip.text.x = element_blank())



# ********************************************************************
# run 5 MOSUM
# ********************************************************************
plot.run5x.process <- plotMOSUM(run5x, plotlabs = "Run 5x",
                         ncols = 1, displayMagn = FALSE, displayResiduals = 'monperiod', displayOldFlag = TRUE,
                         circleVersion = TRUE, displayRefDate = TRUE, refDate = now.refDate) +
  theme_bw() + labs(y = "|MOSUM|", x = "Date") + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title.x = element_blank(),
        strip.background = element_blank(),
        strip.text.x = element_blank(),
        axis.title.y = element_text(margin = margin(t = 0, r = 15, b = 0, l = 0))) +
  annotate("text", label = "(c)", x = as.Date("1989-01-01"), y = 0.5)

# ********************************************************************
# run 27 boundary RMSE, k = 1 and k = factRMSE
# ********************************************************************
plot.run27x.boundaryRMSE <- bfmPlot_mod(run27x, plotlabs = "Run 27x",
                          ncols = 1, displayMagn = FALSE, displayResiduals = 'monperiod', displayOldFlag = TRUE,
                          circleVersion = TRUE, displayRefDate = TRUE, refDate = now.refDate,
                          displayBoundaryRMSE = TRUE) +
  theme_bw() + labs(y = "NDMI", x = "Observation date") + scale_y_continuous(limits = c(-0.2, 0.6)) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        strip.background = element_blank(),
        strip.text.x = element_blank()) +
  annotate("text", label = "(d)", x = as.Date("1989-01-01"), y = -0.15)





# ********************************************************************
# Print the plot
# ********************************************************************
plot.run1x
plot.run5x
plot.run5x.process
plot.run27x
plot.run27x.boundaryRMSE


# pdf(str_c(final.fig.path, "demo_algorithm_comparison_runXb.pdf"), 
#     width = 7, height = 7.5, pointsize = 12)
# multiplot(plot.run1x,
#           plot.run5x,
#           plot.run5x.process,
#           plot.run27x.boundaryRMSE,
#           cols = 1)
# dev.off()



# **************************************************************************
# For FORESTS -------------------------------------------------------------
# **************************************************************************
# Run 27k4: boundary 4 * histRMSE, *without* history noise removal, cons = 3
run <- "run27k4"
historyNoiseRemoved <- FALSE
allNoiseRemoved = FALSE
boundaryRMSE <- TRUE
factorRMSE <- 4
cons <- 3 
updateMOSUM <- FALSE    
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE
rejectPositiveBp <- FALSE
level <- 0.05

# Run 27k2: boundary 2 * histRMSE, *without* history noise removal, cons = 3
run <- "run27k2"
historyNoiseRemoved <- FALSE
allNoiseRemoved = FALSE
boundaryRMSE <- TRUE
factorRMSE <- 2
cons <- 3 
updateMOSUM <- FALSE    
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE
rejectPositiveBp <- FALSE
level <- 0.05

# ********************************************************************
# Run algorithm
# ********************************************************************
run27k4 <- bfastmonitor_mod(
  now.ts, # 
  start = start,
  formula = response~trend,      
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
  originalDateNoNA = now.dateNoNA, #
  allowImmediateConfirm = allowImmediateConfirm,
  factorRMSE_immediate = factorRMSE_immediate,
  rejectPositiveBp = rejectPositiveBp,
  level = level
)

run27k2 <- bfastmonitor_mod(
  now.ts, # 
  start = start,
  formula = response~trend,      
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
  originalDateNoNA = now.dateNoNA, #
  allowImmediateConfirm = allowImmediateConfirm,
  factorRMSE_immediate = factorRMSE_immediate,
  rejectPositiveBp = rejectPositiveBp,
  level = level
)

# ********************************************************************
# Plot
# ********************************************************************
plot.run27k2.boundaryRMSE <- bfmPlot_mod(run27k2, plotlabs = "Run 27k2",
                                         ncols = 1, displayMagn = FALSE, displayResiduals = 'monperiod', displayOldFlag = TRUE,
                                         circleVersion = TRUE, displayRefDate = TRUE, refDate = now.refDate,
                                         displayBoundaryRMSE = TRUE) +
  theme_bw() + labs(y = "NDMI", x = "Observation date") + scale_y_continuous(limits = c(-0.2, 0.6)) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        strip.background = element_blank(),
        strip.text.x = element_blank()) +
  annotate("text", label = "(a)", x = as.Date("1989-01-01"), y = -0.15)

plot.run27k4.boundaryRMSE <- bfmPlot_mod(run27k4, plotlabs = "Run 27k4",
                                         ncols = 1, displayMagn = FALSE, displayResiduals = 'monperiod', displayOldFlag = TRUE,
                                         circleVersion = TRUE, displayRefDate = TRUE, refDate = now.refDate,
                                         displayBoundaryRMSE = TRUE) +
  theme_bw() + labs(y = "NDMI", x = "Observation date") + scale_y_continuous(limits = c(-0.2, 0.6)) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        strip.background = element_blank(),
        strip.text.x = element_blank()) +
  annotate("text", label = "(b)", x = as.Date("1989-01-01"), y = -0.15)

# ********************************************************************
# Save plot
# ********************************************************************
pdf(str_c(final.fig.path, "/for_FORESTS/demo_algorithm_comparison_603.pdf"), 
    width = 6, height = 3.5, pointsize = 12)
multiplot(plot.run27k2.boundaryRMSE,
          plot.run27k4.boundaryRMSE,
          cols = 1)
dev.off()

