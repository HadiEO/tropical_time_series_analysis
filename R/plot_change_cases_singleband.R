# ********************************************************************
# Extracted zoo ts
# ********************************************************************

# Change red, nir, or swir1 extracted time series
# or the ndmi or ndvi calculated from the single bands

# DG1 
extr.DG1 <- read_rds(str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_ndvi_sub_DG1.rds"))
extr.ls.DG1 <- as.list(extr.DG1)
bts.ls.DG1 <- lapply(extr.ls.DG1, FUN = function(z) bfastts(z, dates = time(z), type = "irregular"))
extr.dateNoNA.ls.DG1 <- lapply(extr.ls.DG1, 
                                   FUN = function(z) index(z[!is.na(z)]))

# DG2 
extr.DG2 <- read_rds(str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_ndvi_sub_DG2.rds"))
extr.ls.DG2 <- as.list(extr.DG2)
bts.ls.DG2 <- lapply(extr.ls.DG2, FUN = function(z) bfastts(z, dates = time(z), type = "irregular"))
extr.dateNoNA.ls.DG2 <- lapply(extr.ls.DG2, 
                                   FUN = function(z) index(z[!is.na(z)]))

# SC1 
extr.SC1 <- read_rds(str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_ndvi_sub_SC1.rds"))
extr.ls.SC1 <- as.list(extr.SC1)
bts.ls.SC1 <- lapply(extr.ls.SC1, FUN = function(z) bfastts(z, dates = time(z), type = "irregular"))
extr.dateNoNA.ls.SC1 <- lapply(extr.ls.SC1, 
                                   FUN = function(z) index(z[!is.na(z)]))

# SQ13 
extr.SQ13 <- read_rds(str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_ndvi_sub_SQ13.rds"))
extr.ls.SQ13 <- as.list(extr.SQ13)
bts.ls.SQ13 <- lapply(extr.ls.SQ13, FUN = function(z) bfastts(z, dates = time(z), type = "irregular"))
extr.dateNoNA.ls.SQ13 <- lapply(extr.ls.SQ13, 
                                    FUN = function(z) index(z[!is.na(z)]))



# ********************************************************************
# Reference date
# ********************************************************************
ref.date.all <- read_rds(str_c(path, "/from_shiny/", "all_refChangeDate_final_adj_intactNoDate.rds"))


# ********************************************************************
# Which time series to showcase? 
# Case 1: Forest -> OP
# Case 2: Natural revegetation
# Case 3: Intact forest
# Case 4: Built-up
# Case 5: Sub-pixel removal
# Each case 2 sample pixels (a) and (b)
# ********************************************************************

# ********************************************************************
# Case 1
# ********************************************************************
ts.case1.a <- bts.ls.DG1$`527`                       
dateNoNA.case1.a <- extr.dateNoNA.ls.DG1$`527` 
refDate.case1.a <- ref.date.all %>% 
  filter(Scene == "DG1", Id == "527") %>% 
  .[["Date"]]

ts.case1.b <- bts.ls.DG1$`1131`                       
dateNoNA.case1.b <- extr.dateNoNA.ls.DG1$`1131` 
refDate.case1.b <- ref.date.all %>% 
  filter(Scene == "DG1", Id == "1131") %>% 
  .[["Date"]]


# ********************************************************************
# Case 2
# ********************************************************************
ts.case2.a <- bts.ls.DG2$`622`                       
dateNoNA.case2.a <- extr.dateNoNA.ls.DG2$`622` 
refDate.case2.a <- ref.date.all %>% 
  filter(Scene == "DG2", Id == "622") %>% 
  .[["Date"]]

ts.case2.b <- bts.ls.DG2$`696`                       
dateNoNA.case2.b <- extr.dateNoNA.ls.DG2$`696` 
refDate.case2.b <- ref.date.all %>% 
  filter(Scene == "DG2", Id == "696") %>% 
  .[["Date"]]


# ********************************************************************
# Case 3
# ********************************************************************
ts.case3.a <- bts.ls.DG1$`1200`                       
dateNoNA.case3.a <- extr.dateNoNA.ls.DG1$`1200` 
refDate.case3.a <- ref.date.all %>% 
  filter(Scene == "DG1", Id == "1200") %>% 
  .[["Date"]]

ts.case3.b <- bts.ls.DG2$`1199`                       
dateNoNA.case3.b <- extr.dateNoNA.ls.DG2$`1199` 
refDate.case3.b <- ref.date.all %>% 
  filter(Scene == "DG2", Id == "1199") %>% 
  .[["Date"]]

# ********************************************************************
# Case 4
# ********************************************************************
ts.case4 <- bts.ls.DG1$`215`                       
dateNoNA.case4 <- extr.dateNoNA.ls.DG1$`215` 
refDate.case4 <- ref.date.all %>% 
  filter(Scene == "DG1", Id == "215") %>% 
  .[["Date"]]


# ********************************************************************
# Case 5
# ********************************************************************
ts.case5.a <- bts.ls.SC1$`719`                       
dateNoNA.case5.a <- extr.dateNoNA.ls.SC1$`719` 
refDate.case5.a <- ref.date.all %>% 
  filter(Scene == "SC1", Id == "719") %>% 
  .[["Date"]]

ts.case5.b <- bts.ls.SC1$`250`                       
dateNoNA.case5.b <- extr.dateNoNA.ls.SC1$`250` 
refDate.case5.b <- ref.date.all %>% 
  filter(Scene == "SC1", Id == "250") %>% 
  .[["Date"]]



# ********************************************************************
# Run bfm for different change cases and algorithms
# ********************************************************************

# ********************************************************************
# Make my own function
# ********************************************************************
# run is either "run5" or "run27"
temp.fun <- function(now.ts, now.dateNoNA, run, now.refDate, subplot.label,
                     showSensor, dataWithSensor, preCollection = TRUE, ylim = c(-0.2, 0.6)) {
  
  # Fixed setting
  searchWindow <- 1
  maxTimeSpan <- 2
  start <- c(2000,1)
  history = "all"
  
  # Scenarios for comparison
  if(run == "run5") {           # Input
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
    
  } else if(run == "run27") {    # Input
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
  }
  
  # Run bfm
  bfm.res <- bfastmonitor_mod(
    now.ts,                                           # Input
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
    originalDateNoNA = now.dateNoNA,                  # Input
    allowImmediateConfirm = allowImmediateConfirm,
    factorRMSE_immediate = factorRMSE_immediate,
    rejectPositiveBp = rejectPositiveBp,
    level = level
  )
  
  # Plot bfm result
  plot.bfmRes <- bfmPlot_mod_small(bfm.res, plotlabs = "",
                                   ncols = 1, displayMagn = FALSE, displayResiduals = 'none', displayOldFlag = TRUE,
                                   circleVersion = TRUE, displayRefDate = TRUE, refDate = now.refDate,   # Input now.refDate
                                   showSensor = showSensor, dataWithSensor = dataWithSensor,
                                   preCollection = preCollection) +                 # Input showSensor, dataWithSensor          
    theme_bw() + labs(y = "", x = "Date") + scale_y_continuous(limits = ylim) +
    theme(axis.text.x = element_text(),   # element_text(angle = 45, hjust = 1)
          axis.title.x = element_blank(),
          strip.background = element_blank(),
          strip.text.x = element_blank(),
          axis.title.y = element_blank(),
          legend.position = "none") +
    annotate("text", label = subplot.label, x = as.Date("1989-01-01"), y = -0.15)                # Input subplot.label
  
  out <- list(bfmRes = bfm.res, plotBfmRes = plot.bfmRes)
  return(out)
}

# ********************************************************************
# Run the function
# ********************************************************************

# ********************************************************************
# Case 1
# ********************************************************************
source("R/Rfunction/bfmPlot_mod_small.R")


# bfmRes.case1.a.run5 <- temp.fun(now.ts = ts.case1.a,
#                            now.dateNoNA = dateNoNA.case1.a,
#                            run = "run5",
#                            now.refDate = refDate.case1.a, 
#                            subplot.label = "(a)",
#                            showSensor = TRUE,
#                            dataWithSensor = extr.DG1)

bfmRes.case1.a.run27 <- temp.fun(now.ts = ts.case1.a,
                                 now.dateNoNA = dateNoNA.case1.a,
                                 run = "run27",
                                 now.refDate = refDate.case1.a, 
                                 subplot.label = "(a)",     # "(j)"
                                 showSensor = TRUE,
                                 dataWithSensor = extr.DG1,
                                 preCollection = FALSE,
                                 ylim = c(0, 1))

# bfmRes.case1.b.run5 <- temp.fun(now.ts = ts.case1.b,
#                                 now.dateNoNA = dateNoNA.case1.b,
#                                 run = "run5",
#                                 now.refDate = refDate.case1.b, 
#                                 subplot.label = "(b)",
#                                 showSensor = TRUE,
#                                 dataWithSensor = extr.DG1)

bfmRes.case1.b.run27 <- temp.fun(now.ts = ts.case1.b,
                                 now.dateNoNA = dateNoNA.case1.b,
                                 run = "run27",
                                 now.refDate = refDate.case1.b, 
                                 subplot.label = "(b)",           # "(k)"
                                 showSensor = TRUE,
                                 dataWithSensor = extr.DG1,
                                 preCollection = FALSE,
                                 ylim = c(0, 1))

# ********************************************************************
# Case 2
# ********************************************************************
# bfmRes.case2.a.run5 <- temp.fun(now.ts = ts.case2.a,
#                                 now.dateNoNA = dateNoNA.case2.a,
#                                 run = "run5",
#                                 now.refDate = refDate.case2.a, 
#                                 subplot.label = "(c)",
#                                 showSensor = TRUE,
#                                 dataWithSensor = extr.DG2)

bfmRes.case2.a.run27 <- temp.fun(now.ts = ts.case2.a,
                                 now.dateNoNA = dateNoNA.case2.a,
                                 run = "run27",
                                 now.refDate = refDate.case2.a, 
                                 subplot.label = "(c)",              # "(l)"
                                 showSensor = TRUE,
                                 dataWithSensor = extr.DG2,
                                 preCollection = FALSE,
                                 ylim = c(0, 1))

# bfmRes.case2.b.run5 <- temp.fun(now.ts = ts.case2.b,
#                                 now.dateNoNA = dateNoNA.case2.b,
#                                 run = "run5",
#                                 now.refDate = refDate.case2.b, 
#                                 subplot.label = "(d)",
#                                 showSensor = TRUE,
#                                 dataWithSensor = extr.DG2)

bfmRes.case2.b.run27 <- temp.fun(now.ts = ts.case2.b,
                                 now.dateNoNA = dateNoNA.case2.b,
                                 run = "run27",
                                 now.refDate = refDate.case2.b, 
                                 subplot.label = "(d)",                  # "(m)"
                                 showSensor = TRUE,
                                 dataWithSensor = extr.DG2,
                                 preCollection = FALSE,
                                 ylim = c(0, 1))

# ********************************************************************
# Case 3
# ********************************************************************
# bfmRes.case3.a.run5 <- temp.fun(now.ts = ts.case3.a,
#                                 now.dateNoNA = dateNoNA.case3.a,
#                                 run = "run5",
#                                 now.refDate = refDate.case3.a, 
#                                 subplot.label = "(e)",
#                                 showSensor = TRUE,
#                                 dataWithSensor = extr.DG1)

bfmRes.case3.a.run27 <- temp.fun(now.ts = ts.case3.a,
                                 now.dateNoNA = dateNoNA.case3.a,
                                 run = "run27",
                                 now.refDate = refDate.case3.a, 
                                 subplot.label = "(e)",               # "(n)"
                                 showSensor = TRUE,
                                 dataWithSensor = extr.DG1,
                                 preCollection = FALSE,
                                 ylim = c(0, 1))

# bfmRes.case3.b.run5 <- temp.fun(now.ts = ts.case3.b,
#                                 now.dateNoNA = dateNoNA.case3.b,
#                                 run = "run5",
#                                 now.refDate = refDate.case3.b, 
#                                 subplot.label = "(f)",
#                                 showSensor = TRUE,
#                                 dataWithSensor = extr.SC1)

bfmRes.case3.b.run27 <- temp.fun(now.ts = ts.case3.b,
                                 now.dateNoNA = dateNoNA.case3.b,
                                 run = "run27",
                                 now.refDate = refDate.case3.b, 
                                 subplot.label = "(f)",            # "(o)"
                                 showSensor = TRUE,
                                 dataWithSensor = extr.SC1,
                                 preCollection = FALSE,
                                 ylim = c(0, 1))

# ********************************************************************
# Case 4
# ********************************************************************
# bfmRes.case4.run5 <- temp.fun(now.ts = ts.case4,
#                                 now.dateNoNA = dateNoNA.case4,
#                                 run = "run5",
#                                 now.refDate = refDate.case4, 
#                                 subplot.label = "(g)",
#                               showSensor = TRUE,
#                               dataWithSensor = extr.DG1)

bfmRes.case4.run27 <- temp.fun(now.ts = ts.case4,
                               now.dateNoNA = dateNoNA.case4,
                               run = "run27",
                               now.refDate = refDate.case4, 
                               subplot.label = "(g)",             #  "(p)"
                               showSensor = TRUE,
                               dataWithSensor = extr.DG1,
                               preCollection = FALSE,
                               ylim = c(0, 1))

# ********************************************************************
# Case 5
# ********************************************************************
# bfmRes.case5.a.run5 <- temp.fun(now.ts = ts.case5.a,
#                                 now.dateNoNA = dateNoNA.case5.a,
#                                 run = "run5",
#                                 now.refDate = refDate.case5.a, 
#                                 subplot.label = "(h)",
#                                 showSensor = TRUE,
#                                 dataWithSensor = extr.SC1)

bfmRes.case5.a.run27 <- temp.fun(now.ts = ts.case5.a,
                                 now.dateNoNA = dateNoNA.case5.a,
                                 run = "run27",
                                 now.refDate = refDate.case5.a, 
                                 subplot.label = "(h)",             # "(q)"
                                 showSensor = TRUE,
                                 dataWithSensor = extr.SC1,
                                 preCollection = FALSE,
                                 ylim = c(0, 1))               # Change y axis limit for different bands
# 
# bfmRes.case5.b.run5 <- temp.fun(now.ts = ts.case5.b,
#                                 now.dateNoNA = dateNoNA.case5.b,
#                                 run = "run5",
#                                 now.refDate = refDate.case5.b, 
#                                 subplot.label = "(i)",
#                                 showSensor = TRUE,
#                                 dataWithSensor = extr.SC1)

bfmRes.case5.b.run27 <- temp.fun(now.ts = ts.case5.b,
                                 now.dateNoNA = dateNoNA.case5.b,
                                 run = "run27",
                                 now.refDate = refDate.case5.b, 
                                 subplot.label = "(i)",                # "(r)"
                                 showSensor = TRUE,
                                 dataWithSensor = extr.SC1, 
                                 preCollection = FALSE,
                                 ylim = c(0, 1))                # Change y axis limit for different bands


# ********************************************************************
# Plot together
# ********************************************************************
# pdf(str_c(final.fig.path, "demo_change_cases_showSensor_wide_runXb.pdf"), 
#     width = 7.4, height = 10, pointsize = 10)
# multiplot(bfmRes.case1.a.run5$plotBfmRes, bfmRes.case1.b.run5$plotBfmRes,
#           bfmRes.case2.a.run5$plotBfmRes, bfmRes.case2.b.run5$plotBfmRes,
#           bfmRes.case3.a.run5$plotBfmRes, bfmRes.case3.b.run5$plotBfmRes,
#           bfmRes.case4.run5$plotBfmRes,
#           bfmRes.case5.a.run5$plotBfmRes, bfmRes.case5.b.run5$plotBfmRes,
#           
#           bfmRes.case1.a.run27$plotBfmRes, bfmRes.case1.b.run27$plotBfmRes,
#           bfmRes.case2.a.run27$plotBfmRes, bfmRes.case2.b.run27$plotBfmRes,
#           bfmRes.case3.a.run27$plotBfmRes, bfmRes.case3.b.run27$plotBfmRes,
#           bfmRes.case4.run27$plotBfmRes,
#           bfmRes.case5.a.run27$plotBfmRes, bfmRes.case5.b.run27$plotBfmRes,
#           
#           cols = 2)
# dev.off()

# **************************************************************************
# For FORESTS
# **************************************************************************
# pdf(str_c(final.fig.path, "/for_FORESTS/demo_change_cases_showSensor_wide.pdf"), 
#     width = 6.5, height = 10, pointsize = 10)

# pdf(str_c(final.fig.path, "/for_THESIS/demo_change_cases_showSensor_wide_NDMI.pdf"), 
#     width = 6.5, height = 10, pointsize = 10)

pdf(str_c(final.fig.path, "/for_THESIS/demo_change_cases_showSensor_wide_NDVI.pdf"), 
    width = 6.5, height = 10, pointsize = 10)

multiplot(bfmRes.case1.a.run27$plotBfmRes, bfmRes.case1.b.run27$plotBfmRes,
          bfmRes.case2.a.run27$plotBfmRes, bfmRes.case2.b.run27$plotBfmRes,
          bfmRes.case3.a.run27$plotBfmRes, bfmRes.case3.b.run27$plotBfmRes,
          bfmRes.case4.run27$plotBfmRes,
          bfmRes.case5.a.run27$plotBfmRes, bfmRes.case5.b.run27$plotBfmRes,
          cols = 1)
dev.off()

