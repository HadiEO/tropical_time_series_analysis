# Read extracted NDMI pixel time series ----------------------------------------------------
(path)
path2 <- "/extracted_time_series/FINALLY_USED/"
extrNDMIsub.DG1 <- read_rds(str_c(path, path2, "extrNDMIsub_DG1.rds"))        # Checked these are unique dates
extrNDMIsub.DG2 <- read_rds(str_c(path, path2, "extrNDMIsub_DG2.rds"))
extrNDMIsub.SC1 <- read_rds(str_c(path, path2, "extrNDMIsub_SC1.rds"))
extrNDMIsub.sq9 <- read_rds(str_c(path, path2, "extrNDMIsub_sq9.rds"))
extrNDMIsub.sq11 <- read_rds(str_c(path, path2, "extrNDMIsub_sq11.rds"))
extrNDMIsub.sq13 <- read_rds(str_c(path, path2, "extrNDMIsub_sq13.rds"))


# Update: extracted NDMI up to the year BEFORE the latest VHSR year, to compare with Hansen's accuracy against reference data
(path)
path2 <- "/extracted_time_series/FINALLY_USED/upToBeforeLatestVHSRYear/"
extrNDMIsub.DG1 <- read_rds(str_c(path, path2, "extr_NDMI_sub_DG1.rds"))        # Checked these are unique dates
extrNDMIsub.DG2 <- read_rds(str_c(path, path2, "extr_NDMI_sub_DG2.rds"))
extrNDMIsub.SC1 <- read_rds(str_c(path, path2, "extr_NDMI_sub_SC1.rds"))
extrNDMIsub.sq9 <- read_rds(str_c(path, path2, "extr_NDMI_sub_sq9.rds"))
extrNDMIsub.sq11 <- read_rds(str_c(path, path2, "extr_NDMI_sub_sq11.rds"))
extrNDMIsub.sq13 <- read_rds(str_c(path, path2, "extr_NDMI_sub_sq13.rds"))





# Now read the selected mesh points (= pixels) --------
# to extract the spectral time series
shp.folder <- paste(path, "/vector_data/FINALLY_USED", sep = "")
refPixels.DG1 <- readOGR(dsn = shp.folder, layer = "meshSelect_prevDG1")
refPixels.DG2 <- readOGR(dsn = shp.folder, layer = "meshSelect_prevDG2")    
refPixels.SC1 <- readOGR(dsn = shp.folder, layer = "meshSelect_SC_1")
refPixels.sq9 <- readOGR(dsn = shp.folder, layer = "meshSelect_sq_9")
refPixels.sq11 <- readOGR(dsn = shp.folder, layer = "meshSelect_sq_11")
refPixels.sq13 <- readOGR(dsn = shp.folder, layer = "meshSelect_sq_13")
# Attributes: "Id"        "Visual"    "X1"        "Date"      "Comment"   "Scene"     "Disturbed" "Date_adj" 


# First and last date of VHSR ---------------------------------------------
ref.firstDate <- list(DG1 = as.Date("2002-09-29"), DG2 = as.Date("2002-09-29"),
                      sq9 = as.Date("2002-08-18"), sq10 = as.Date("2005-07-26"),
                      sq11 = as.Date("2005-07-26"), sq13 = as.Date("2002-08-18"),
                      SC1 = as.Date("2005-07-26"))

ref.lastDate <- list(DG1 = as.Date("2015-08-15"), DG2 = as.Date("2015-08-08"),
                     sq9 = as.Date("2014-05-13"), sq10 = as.Date("2015-08-17"),
                     sq11 = as.Date("2014-02-04"), sq13 = as.Date("2014-05-13"),
                     SC1 = as.Date("2014-02-04"))


# Need these dates in c(year, jday) !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
source("R/Rfunction/dateToYearJday.R")
ref.firstDate <- lapply(ref.firstDate, dateToYearJday)
ref.lastDate <- lapply(ref.lastDate, dateToYearJday)



# Extract the NDMI at select Landsat pixels and run BFAST Monitor --------------------------------

# ****************************************************************************
source("R/Rfunction/attachBfmFlagToSp.R")
# ****************************************************************************

# ****************************************************************************
# Configure bfastmonitor, execute one run by one 
# Fixed setting:
# [1] removedips_mod(data, updateX = TRUE, searchWindow = 1) i.e. 
# temporally interpolate (average) outlier if the temporal neighbours are not > 1 year apart
searchWindow <- 1

# [2] maxTimeSpan = 2 in monitor_mod(), called in bfastmonitor_mod() i.e.
# consecutive anomalies are required to occur within not > 2 years period, based on our
# observation that the signal returns to stability (can be near the pre-disturbance level)
# after 2 years since visible disturbance signal.
maxTimeSpan <- 2

# [3] history = "all" hard-coded as history = "ROC" results in spurious cut of the history
# that causes too few obs to robustly fit the historical model

# ****************************************************************************
# Update 2018.04.26:
# Common in previous experiments before RS revision
rejectPositiveBp <- FALSE
level <- 0.05
# *****************************************************************************



# Run 1: Original bfastmonitor *without* history noise removal
run <- "run1"
historyNoiseRemoved <- FALSE
boundaryRMSE <- FALSE
factorRMSE <- NA
cons <- 1
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE

# Run 2: Original bfastmonitor *with* history noise removal
run <- "run2"
historyNoiseRemoved <- TRUE #
boundaryRMSE <- FALSE
factorRMSE <- NA
cons <- 1
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE

# Run 3: Modified bfastmonitor *with* history noise removal, cons = 3, updateMOSUM = FALSE
run <- "run3"
historyNoiseRemoved <- TRUE
boundaryRMSE <- FALSE
factorRMSE <- NA
cons <- 3 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE

# Run 4: Modified bfastmonitor *with* history noise removal, cons = 3, updateMOSUM = TRUE
run <- "run4"
historyNoiseRemoved <- TRUE
boundaryRMSE <- FALSE
factorRMSE <- NA
cons <- 3 
updateMOSUM <- TRUE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE

# Run 5: Modified bfastmonitor *without* history noise removal, cons = 3, updateMOSUM = TRUE
run <- "run5"
historyNoiseRemoved <- FALSE
boundaryRMSE <- FALSE
factorRMSE <- NA
cons <- 3 
updateMOSUM <- TRUE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE

# Run 6: Modified bfastmonitor *without* history noise removal, cons = 3, updateMOSUM = FALSE
run <- "run6"
historyNoiseRemoved <- FALSE
boundaryRMSE <- FALSE
factorRMSE <- NA
cons <- 3 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE

# Run 7: boundary 3 * histRMSE, *without* history noise removal, cons=3
run <- "run7"
historyNoiseRemoved <- FALSE
boundaryRMSE <- TRUE
factorRMSE <- 3
cons <- 3 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE


# Run 8: boundary 3 * histRMSE, *with* history noise removal, cons=3
run <- "run8"
historyNoiseRemoved <- TRUE
boundaryRMSE <- TRUE
factorRMSE <- 3
cons <- 3 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE


# Run 9: boundary 3 * histRMSE, *without* history noise removal, cons = 2
run <- "run9"
historyNoiseRemoved <- FALSE
boundaryRMSE <- TRUE
factorRMSE <- 3
cons <- 2 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE

# Run 10: boundary 5 * histRMSE, *without* history noise removal, cons = 1
run <- "run10"
historyNoiseRemoved <- FALSE
boundaryRMSE <- TRUE
factorRMSE <- 5
cons <- 1 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE

# Run 11: boundary 10 * histRMSE, *without* history noise removal, cons = 1
run <- "run11"
historyNoiseRemoved <- FALSE
boundaryRMSE <- TRUE
factorRMSE <- 10
cons <- 1 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE

# Run 12: boundary 12 * histRMSE, *without* history noise removal, cons = 1
run <- "run12"
historyNoiseRemoved <- FALSE
boundaryRMSE <- TRUE
factorRMSE <- 12
cons <- 1 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE

# Run 13: boundary 8 * histRMSE, *without* history noise removal, cons = 1
run <- "run13"
historyNoiseRemoved <- FALSE
boundaryRMSE <- TRUE
factorRMSE <- 8
cons <- 1 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE

# Run 14: boundary 12 * histRMSE, *with* history noise removal, cons = 1
run <- "run14"
historyNoiseRemoved <- TRUE
boundaryRMSE <- TRUE
factorRMSE <- 12
cons <- 1 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE

# Run 15: boundary 5 * histRMSE, *without* history noise removal, cons = 2
run <- "run15"
historyNoiseRemoved <- FALSE
boundaryRMSE <- TRUE
factorRMSE <- 5
cons <- 2 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE

# Run 16: boundary 10 * histRMSE, *without* history noise removal, cons = 2
run <- "run16"
historyNoiseRemoved <- FALSE
boundaryRMSE <- TRUE
factorRMSE <- 10
cons <- 2 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE

# Run 17: boundary 4 * histRMSE, *without* history noise removal, cons = 2
run <- "run17"
historyNoiseRemoved <- FALSE
boundaryRMSE <- TRUE
factorRMSE <- 4
cons <- 2 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE

# Run 18: boundary 6 * histRMSE, *without* history noise removal, cons = 2
run <- "run18"
historyNoiseRemoved <- FALSE
boundaryRMSE <- TRUE
factorRMSE <- 6
cons <- 2 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE

# Run 19: boundary 7 * histRMSE, *without* history noise removal, cons = 2
run <- "run19"
historyNoiseRemoved <- FALSE
boundaryRMSE <- TRUE
factorRMSE <- 7
cons <- 2 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE

# Run 20: boundary 8 * histRMSE, *without* history noise removal, cons = 2
run <- "run20"
historyNoiseRemoved <- FALSE
boundaryRMSE <- TRUE
factorRMSE <- 8
cons <- 2 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE

# Run 21: boundary 9 * histRMSE, *without* history noise removal, cons = 2
run <- "run21"
historyNoiseRemoved <- FALSE
boundaryRMSE <- TRUE
factorRMSE <- 9
cons <- 2 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE

# Run 22: boundary 3 * histRMSE, *without* history noise removal, cons = 1
run <- "run22"
historyNoiseRemoved <- FALSE
boundaryRMSE <- TRUE
factorRMSE <- 3
cons <- 1 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE

# Run 23: boundary 4 * histRMSE, *without* history noise removal, cons = 1
run <- "run23"
historyNoiseRemoved <- FALSE
boundaryRMSE <- TRUE
factorRMSE <- 4
cons <- 1 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE

# Run 24: boundary 6 * histRMSE, *without* history noise removal, cons = 1
run <- "run24"
historyNoiseRemoved <- FALSE
boundaryRMSE <- TRUE
factorRMSE <- 6
cons <- 1 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE


# Run 25: boundary 7 * histRMSE, *without* history noise removal, cons = 1
run <- "run25"
historyNoiseRemoved <- FALSE
boundaryRMSE <- TRUE
factorRMSE <- 7
cons <- 1 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE

# Run 26: boundary 9 * histRMSE, *without* history noise removal, cons = 1
run <- "run26"
historyNoiseRemoved <- FALSE
boundaryRMSE <- TRUE
factorRMSE <- 9
cons <- 1 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE


# Run 27: boundary 4 * histRMSE, *without* history noise removal, cons = 3
run <- "run27"
historyNoiseRemoved <- FALSE
boundaryRMSE <- TRUE
factorRMSE <- 4
cons <- 3 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE

# Run 27 upToBeforeLatestVHSRYear: boundary 4 * histRMSE, *without* history noise removal, cons = 3
run <- "run27_upToBeforeLatestVHSRYear"
historyNoiseRemoved <- FALSE
boundaryRMSE <- TRUE
factorRMSE <- 4
cons <- 3 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE

# Run 28: boundary 5 * histRMSE, *without* history noise removal, cons = 3
run <- "run28"
historyNoiseRemoved <- FALSE
boundaryRMSE <- TRUE
factorRMSE <- 5
cons <- 3 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE

# Run 29: boundary 6 * histRMSE, *without* history noise removal, cons = 3
run <- "run29"
historyNoiseRemoved <- FALSE
boundaryRMSE <- TRUE
factorRMSE <- 6
cons <- 3 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE

# Run 30: boundary 7 * histRMSE, *without* history noise removal, cons = 3
run <- "run30"
historyNoiseRemoved <- FALSE
boundaryRMSE <- TRUE
factorRMSE <- 7
cons <- 3 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE


# Run 31: boundary 8 * histRMSE, *without* history noise removal, cons = 3
run <- "run31"
historyNoiseRemoved <- FALSE
boundaryRMSE <- TRUE
factorRMSE <- 8
cons <- 3 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE


# Run 32: boundary 9 * histRMSE, *without* history noise removal, cons = 3
run <- "run32"
historyNoiseRemoved <- FALSE
boundaryRMSE <- TRUE
factorRMSE <- 9
cons <- 3 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE



# Run 33: boundary 10 * histRMSE, *without* history noise removal, cons = 3
run <- "run33"
historyNoiseRemoved <- FALSE
boundaryRMSE <- TRUE
factorRMSE <- 10
cons <- 3 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE


# Run 34: boundary 4 * histRMSE, *with* history noise removal, cons = 3
run <- "run34"
historyNoiseRemoved <- TRUE
boundaryRMSE <- TRUE
factorRMSE <- 4
cons <- 3 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE


# Run 35: boundary 5.5 * histRMSE, *without* history noise removal, cons = 2
run <- "run35"
historyNoiseRemoved <- FALSE
boundaryRMSE <- TRUE
factorRMSE <- 5.5
cons <- 2 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE


# Run 36: boundary 5.5 * histRMSE, *with* history noise removal, cons = 2
run <- "run36"
historyNoiseRemoved <- TRUE
boundaryRMSE <- TRUE
factorRMSE <- 5.5
cons <- 2 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE


# Run 37: boundary 9.3 * histRMSE, *without* history noise removal, cons = 1
run <- "run37"
historyNoiseRemoved <- FALSE
boundaryRMSE <- TRUE
factorRMSE <- 9.3
cons <- 1 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE
rejectPositiveBp <- FALSE
level <- 0.05


# ****************************************************************************
# Scenarios based on reviewer's comment
# ****************************************************************************
# (i) Test probability levels 0.01, 0.02, 0.03, 0.04                <- added argument "level" by default 0.05
# (ii) Fit only intercept model                                     <- this is not easy to implement in the current code as bfastpp() did not return intercept
#                                                                   <- alternatively just take mean of historical observations, replace the trend column with the mean
#                                                                   <- however note that we did try history noise removal which would prevent too strong of a trend, and this increases commission errors!
# (iii) Internally reject positive breakpoint, continue monitoring  <- added argument "rejectPositiveBp" by default FALSE


# ***********************************************************************
# Run Xb: alpha = 0.05 ----------------------------------------------------
# ***********************************************************************
# Run 1b: run 1, but rejectPositiveBp = TRUE, alpha = 0.05 (default)
run <- "run1b"
historyNoiseRemoved <- FALSE
boundaryRMSE <- FALSE
factorRMSE <- NA
cons <- 1
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE
rejectPositiveBp <- TRUE
level <- 0.05

# Run 2b: run 2, but rejectPositiveBp = TRUE, alpha = 0.05 (default)
run <- "run2b"
historyNoiseRemoved <- TRUE #
boundaryRMSE <- FALSE
factorRMSE <- NA
cons <- 1
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE
rejectPositiveBp <- TRUE
level <- 0.05

# Run 3b: run 3, but rejectPositiveBp = TRUE, alpha = 0.05 (default)
run <- "run3b"
historyNoiseRemoved <- TRUE
boundaryRMSE <- FALSE
factorRMSE <- NA
cons <- 3 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE
rejectPositiveBp <- TRUE
level <- 0.05

# Run 4b: run 4, but rejectPositiveBp = TRUE, alpha = 0.05 (default)
run <- "run4b"
historyNoiseRemoved <- TRUE
boundaryRMSE <- FALSE
factorRMSE <- NA
cons <- 3 
updateMOSUM <- TRUE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE
rejectPositiveBp <- TRUE
level <- 0.05

# Run 5b: run 5, but rejectPositiveBp = TRUE, alpha = 0.05 (default)
run <- "run5b"
historyNoiseRemoved <- FALSE
boundaryRMSE <- FALSE
factorRMSE <- NA
cons <- 3 
updateMOSUM <- TRUE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE
rejectPositiveBp <- TRUE
level <- 0.05

# Run 6b: run 6, but rejectPositiveBp = TRUE, alpha = 0.05 (default)
run <- "run6b"
historyNoiseRemoved <- FALSE
boundaryRMSE <- FALSE
factorRMSE <- NA
cons <- 3 
updateMOSUM <- FALSE    
bfmOutName <- str_c(path, "/bfm_results/bfm_", run)
outSamplesName <- str_c(path, "/accuracy_results/accuracy_", run)
oldFlagOutName <- str_c(path, "/bfm_results/oldFlag_bfm_", run)
factorRMSE_immediate <- NULL
allowImmediateConfirm <- FALSE
rejectPositiveBp <- TRUE
level <- 0.05




# ****************************************************************************
# Run bfastmonitor
# ****************************************************************************
# Todo: Consider start 2000 for all cases

DG1.bfmFlag <- attachBfmFlagToSp(extrNDMIsub.DG1, refPixels.DG1, c(2000,1), # ref.firstDate$DG1, 
                                 bfmOutName = str_c(bfmOutName, "_DG1.rds"),
                                 outSamplesName = str_c(outSamplesName, "_DG1.rds"),
                                 oldFlagOutName = str_c(oldFlagOutName, "_DG1.rds"),
                                 historyNoiseRemoved = historyNoiseRemoved,
                                 searchWindow = searchWindow,
                                 cons = cons, 
                                 maxTimeSpan = maxTimeSpan,
                                 updateMOSUM = updateMOSUM,
                                 boundaryRMSE = boundaryRMSE,
                                 factorRMSE = factorRMSE,
                                 allowImmediateConfirm = allowImmediateConfirm,
                                 factorRMSE_immediate = factorRMSE_immediate,
                                 rejectPositiveBp = rejectPositiveBp,
                                 level = level)

DG2.bfmFlag <- attachBfmFlagToSp(extrNDMIsub.DG2, refPixels.DG2, c(2000,1), # ref.firstDate$DG2, 
                                 bfmOutName = str_c(bfmOutName, "_DG2.rds"),
                                 outSamplesName = str_c(outSamplesName, "_DG2.rds"),
                                 oldFlagOutName = str_c(oldFlagOutName, "_DG2.rds"),
                                 historyNoiseRemoved = historyNoiseRemoved, 
                                 searchWindow = searchWindow,
                                 cons = cons, 
                                 maxTimeSpan = maxTimeSpan,
                                 updateMOSUM = updateMOSUM,
                                 boundaryRMSE = boundaryRMSE,
                                 factorRMSE = factorRMSE,
                                 allowImmediateConfirm = allowImmediateConfirm,
                                 factorRMSE_immediate = factorRMSE_immediate,
                                 rejectPositiveBp = rejectPositiveBp,
                                 level = level)

SC1.bfmFlag <- attachBfmFlagToSp(extrNDMIsub.SC1, refPixels.SC1, c(2000,1), # ref.firstDate$SC1, 
                                 bfmOutName = str_c(bfmOutName, "_SC1.rds"),
                                 outSamplesName = str_c(outSamplesName, "_SC1.rds"),
                                 oldFlagOutName = str_c(oldFlagOutName, "_SC1.rds"),
                                 historyNoiseRemoved = historyNoiseRemoved,
                                 searchWindow = searchWindow,
                                 cons = cons, 
                                 maxTimeSpan = maxTimeSpan,
                                 updateMOSUM = updateMOSUM,
                                 boundaryRMSE = boundaryRMSE,
                                 factorRMSE = factorRMSE,
                                 allowImmediateConfirm = allowImmediateConfirm,
                                 factorRMSE_immediate = factorRMSE_immediate,
                                 rejectPositiveBp = rejectPositiveBp,
                                 level = level)

sq9.bfmFlag <- attachBfmFlagToSp(extrNDMIsub.sq9, refPixels.sq9, c(2000,1), # ref.firstDate$sq9, 
                                 bfmOutName = str_c(bfmOutName, "_sq9.rds"),
                                 outSamplesName = str_c(outSamplesName, "_sq9.rds"),
                                 oldFlagOutName = str_c(oldFlagOutName, "_sq9.rds"),
                                 historyNoiseRemoved = historyNoiseRemoved,
                                 searchWindow = searchWindow,
                                 cons = cons, 
                                 maxTimeSpan = maxTimeSpan,
                                 updateMOSUM = updateMOSUM,
                                 boundaryRMSE = boundaryRMSE,
                                 factorRMSE = factorRMSE,
                                 allowImmediateConfirm = allowImmediateConfirm,
                                 factorRMSE_immediate = factorRMSE_immediate,
                                 rejectPositiveBp = rejectPositiveBp,
                                 level = level)

sq11.bfmFlag <- attachBfmFlagToSp(extrNDMIsub.sq11, refPixels.sq11, c(2000,1), # ref.firstDate$sq11,
                                  bfmOutName = str_c(bfmOutName, "_sq11.rds"),
                                  outSamplesName = str_c(outSamplesName, "_sq11.rds"),
                                  oldFlagOutName = str_c(oldFlagOutName, "_sq11.rds"),
                                  historyNoiseRemoved = historyNoiseRemoved, 
                                  searchWindow = searchWindow,
                                  cons = cons, 
                                  maxTimeSpan = maxTimeSpan,
                                  updateMOSUM = updateMOSUM,
                                  boundaryRMSE = boundaryRMSE,
                                  factorRMSE = factorRMSE,
                                  allowImmediateConfirm = allowImmediateConfirm,
                                  factorRMSE_immediate = factorRMSE_immediate,
                                  rejectPositiveBp = rejectPositiveBp,
                                  level = level)

sq13.bfmFlag <- attachBfmFlagToSp(extrNDMIsub.sq13, refPixels.sq13, c(2000,1), # ref.firstDate$sq13,
                                  bfmOutName = str_c(bfmOutName, "_sq13.rds"),
                                  outSamplesName = str_c(outSamplesName, "_sq13.rds"),
                                  oldFlagOutName = str_c(oldFlagOutName, "_sq13.rds"),
                                  historyNoiseRemoved = historyNoiseRemoved, 
                                  searchWindow = searchWindow,
                                  cons = cons, 
                                  maxTimeSpan = maxTimeSpan,
                                  updateMOSUM = updateMOSUM,
                                  boundaryRMSE = boundaryRMSE,
                                  factorRMSE = factorRMSE,
                                  allowImmediateConfirm = allowImmediateConfirm,
                                  factorRMSE_immediate = factorRMSE_immediate,
                                  rejectPositiveBp = rejectPositiveBp,
                                  level = level)


# ****************************************************************************
# Merge bfm results of all VHSR scenes ---------------------------------------------------
# ****************************************************************************
all.bfmFlag <- bind_rows(DG1.bfmFlag@data,
                         DG2.bfmFlag@data,
                         sq9.bfmFlag@data,
                         sq11.bfmFlag@data,
                         sq13.bfmFlag@data,
                         SC1.bfmFlag@data)
# warning coercing factor (the shapefile original columns) to character, doesn't matter cause those columns are not used in calculation here

# Tibble it up
all.bfmFlag <- as_tibble(all.bfmFlag)

# run is expriment run number defined earlier
# write_rds(all.bfmFlag, str_c(path, "/accuracy_results/accuracy_", run, "_all_df.rds"))   # which experiment run? ***

# Update run for ts up to the year BEFORE the latest VHSR year, to compare with Hansen's accuracy against reference data
write_rds(all.bfmFlag, str_c(path, "/accuracy_results/accuracy_", run, "_upToBeforeLatestVHSRYear", "_all_df.rds"))
