# Set library path as I am mostly working in Aalto laptop anyway
.libPaths("C:/Program Files/R/R-3.3.1/library")

# Load libraries
require(rgdal)
require(ggplot2)
require(raster)
# require(plyr)
require(signal)
require(Hmisc)
require(strucchange)
require(zoo)
require(bfast)
require(bfastSpatial)  
require(sp)
require(rgrowth)
require(bfastPlot)
require(mapedit)
require(mapview)
require(sf)
require(dtwSat)
require(shiny)
require(timesyncR)
require(doParallel)
require(spatial.tools)
require(STEF)
require(bayts)
require("doSNOW")                                 
require("doParallel")
source("R/Rfunction/removedips.R")
require(xts)
require(animation)
require(dplyr)
require(stringr)
require(tidyverse)
require(lubridate)
require(reshape2)
require(rgrowth)
require(bfastSpatial)

require(DT)   
require(googleVis)
require(gplots)
require(vioplot)
require(RColorBrewer)

source("R/Rfunction/getSceneinfo_mod.R")
source("R/Rfunction/monitor_mod.R")
source("R/Rfunction/bfastmonitor_mod.R")
source("R/Rfunction/multiplot.R")
source("R/Rfunction/computeEmpProc_mod.R")
source("R/Rfunction/bfmPlot_mod.R")
source("R/Rfunction/history_roc.R")
source("R/Rfunction/history_break.R")
source("R/Rfunction/time2num.R")
source("R/Rfunction/dec2date.R")
source("R/Rfunction/attachBfmFlagToSp.R")
source("R/Rfunction/calc_spatial_accuracy.R")
source("R/Rfunction/MOSUM_plot.R")
source("R/Rfunction/bfmPlot_mod_small.R")
source("R/Rfunction/bfmSpatial_mod.R")

# Set language e.g. for plot.zoo
Sys.setlocale("LC_ALL", "English")

# Suggested plotting colours and symbols
pts.cols <- c("magenta", "chartreuse4", "dodgerblue", "dark blue", "brown", "dark orange")
pts.pchs <- c(1,7,5,6,4,2)


# Set path for all machines

if(.Platform$OS.type == 'windows') {
  path <- 'C:/LocalUserData/User-data/hadi1/PHD_RESEARCH/STUDY_IIASA/bfast_hadi_yssp_data'
  
  final.fig.path <- "C:/LocalUserData/User-data/hadi1/PHD_RESEARCH/STUDY_IIASA/bfast_hadi_yssp_data/FINAL_GRAPHS/"
} # else {
#   info <- Sys.info()
#   if (info['nodename'] == 'vanoise') {
#     path <- '/media/dutri001/LP_DUTRIEUX_Data/RS'
#   } else if (info['nodename'] == 'papaya') {
#     path <- '/media/DATA3/dutri001'
#   } else if (info['nodename'] == 'tanargue') {
#     path <- 'media/whatever/'
#   }
  
#} # For some reasons the empty line at the bottom is important