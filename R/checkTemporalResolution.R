# Check the effective temporal resolution of the time series with different situations
# of Landsat(s) in orbit. 
# In GEE, time series were extracted from all scenes, but 
# there can also be missing orbit or missing acquisition during overpass.

(path)
path2 <- "/extracted_time_series/FINALLY_USED/"
extrNDMIsub_DG1 <- read_rds(str_c(path, path2, "extrNDMIsub_DG1.rds"))
extrNDMIsub_DG2 <- read_rds(str_c(path, path2, "extrNDMIsub_DG2.rds"))
extrNDMIsub_SC1 <- read_rds(str_c(path, path2, "extrNDMIsub_SC1.rds"))
extrNDMIsub_sq9 <- read_rds(str_c(path, path2, "extrNDMIsub_sq9.rds"))
# extrNDMIsub_sq10 <- read_rds(str_c(path, path2, "extrNDMIsub_sq10.rds"))
extrNDMIsub_sq11 <- read_rds(str_c(path, path2, "extrNDMIsub_sq11.rds"))
extrNDMIsub_sq13 <- read_rds(str_c(path, path2, "extrNDMIsub_sq13.rds"))

# Make function to get date difference
# onlyValidObs = FALSE gives all acquisition (scenes)
# onlyValidObs = TRUE gives only valid (cloud-free) observations
# x can be (a) ts with index in %Y-%m-%d format
# (b) date in %Y-%m-%d format
getDateDiff <- function(x, onlyValidObs = FALSE) {
  if(onlyValidObs) {
    x <- x[!is.na(x)] 
  }
  if(class(x) == "Date") {
    xDate <- x
  } else {
    xDate <- time(x) 
  }
                       
  dts <- rep(NA, length(x)-1)
  for(t in 2:length(x)) {
    dt <- xDate[t] - xDate[t-1]
    dt <- as.numeric(dt)
    dts[t-1] <- dt
  }
  return(dts)
}


# Test function
# x <- extrNDMIsub_DG1[, "68"]
# dateDiff_DG1 <- getDateDiff(x = x)
# breaks <- seq(min(dateDiff_DG1), max(dateDiff_DG1), 8)
# hist(dateDiff_DG1, breaks = breaks, right = FALSE)
# OK!

# Run the function through time series id, and through DG scenes
extrNDMIsub_DG1_ls <- as.list(extrNDMIsub_DG1)
extrNDMIsub_DG2_ls <- as.list(extrNDMIsub_DG2)
extrNDMIsub_SC1_ls <- as.list(extrNDMIsub_SC1)
extrNDMIsub_sq9_ls <- as.list(extrNDMIsub_sq9)
# extrNDMIsub_sq10_ls <- as.list(extrNDMIsub_sq10)
extrNDMIsub_sq11_ls <- as.list(extrNDMIsub_sq11)
extrNDMIsub_sq13_ls <- as.list(extrNDMIsub_sq13)

# all acquisitions
dateDiff_DG1 <- lapply(extrNDMIsub_DG1_ls, getDateDiff)
dateDiff_DG2 <- lapply(extrNDMIsub_DG2_ls, getDateDiff)
dateDiff_SC1 <- lapply(extrNDMIsub_SC1_ls, getDateDiff)
dateDiff_sq9 <- lapply(extrNDMIsub_sq9_ls, getDateDiff)
# dateDiff_sq10 <- lapply(extrNDMIsub_sq10_ls, getDateDiff)
dateDiff_sq11 <- lapply(extrNDMIsub_sq11_ls, getDateDiff)
dateDiff_sq13 <- lapply(extrNDMIsub_sq13_ls, getDateDiff)

dateDiff_DG1_vec <- unlist(dateDiff_DG1)
dateDiff_DG2_vec <- unlist(dateDiff_DG2)
dateDiff_SC1_vec <- unlist(dateDiff_SC1)
dateDiff_sq9_vec <- unlist(dateDiff_sq9)
# dateDiff_sq10_vec <- unlist(dateDiff_sq10)
dateDiff_sq11_vec <- unlist(dateDiff_sq11)
dateDiff_sq13_vec <- unlist(dateDiff_sq13)


# Only valid observations
dateDiff_DG1_valid <- lapply(extrNDMIsub_DG1_ls, function(z) getDateDiff(z, onlyValidObs = TRUE))
dateDiff_DG2_valid <- lapply(extrNDMIsub_DG2_ls, function(z) getDateDiff(z, onlyValidObs = TRUE))
dateDiff_SC1_valid <- lapply(extrNDMIsub_SC1_ls, function(z) getDateDiff(z, onlyValidObs = TRUE))
dateDiff_sq9_valid <- lapply(extrNDMIsub_sq9_ls, function(z) getDateDiff(z, onlyValidObs = TRUE))
# dateDiff_sq10_valid <- lapply(extrNDMIsub_sq10_ls, function(z) getDateDiff(z, onlyValidObs = TRUE))
dateDiff_sq11_valid <- lapply(extrNDMIsub_sq11_ls, function(z) getDateDiff(z, onlyValidObs = TRUE))
dateDiff_sq13_valid <- lapply(extrNDMIsub_sq13_ls, function(z) getDateDiff(z, onlyValidObs = TRUE))


dateDiff_DG1_vec_valid <- unlist(dateDiff_DG1_valid)
dateDiff_DG2_vec_valid <- unlist(dateDiff_DG2_valid)
dateDiff_SC1_vec_valid <- unlist(dateDiff_SC1_valid)
dateDiff_sq9_vec_valid <- unlist(dateDiff_sq9_valid)
# dateDiff_sq10_vec_valid <- unlist(dateDiff_sq10_valid)
dateDiff_sq11_vec_valid <- unlist(dateDiff_sq11_valid)
dateDiff_sq13_vec_valid <- unlist(dateDiff_sq13_valid)



# Because the DG scenes are not spatially representative, just pool the date differences together
# to give average temporal resolution in our study sites.
# Density plot is more suitable here than frequency?
# Update: actually if the dateDiff is always multiply of 8, a bar plot with discrete X-axis values would be more appropriate
# Check if dateDiff always multiply of 8
# dateDiff_DG1_vec_table <- table(dateDiff_DG1_vec)
# dateDiff_DG2_vec_table <- table(dateDiff_DG2_vec)
# dateDiff_SC1_vec_table <- table(dateDiff_SC1_vec)
# dateDiff_sq9_vec_table <- table(dateDiff_sq9_vec)
# # dateDiff_sq10_vec_table <- table(dateDiff_sq10_vec)
# dateDiff_sq11_vec_table <- table(dateDiff_sq11_vec)
# dateDiff_sq13_vec_table <- table(dateDiff_sq13_vec)
# 
# all((as.numeric(dimnames(dateDiff_DG1_vec_table)[[1]]) %% 8) == 0)
# all((as.numeric(dimnames(dateDiff_DG2_vec_table)[[1]]) %% 8) == 0)
# all((as.numeric(dimnames(dateDiff_SC1_vec_table)[[1]]) %% 8) == 0)
# all((as.numeric(dimnames(dateDiff_sq9_vec_table)[[1]]) %% 8) == 0)   # FALSE
# all((as.numeric(dimnames(dateDiff_sq10_vec_table)[[1]]) %% 8) == 0)
# all((as.numeric(dimnames(dateDiff_sq11_vec_table)[[1]]) %% 8) == 0)  # FALSE
# all((as.numeric(dimnames(dateDiff_sq13_vec_table)[[1]]) %% 8) == 0)  # FALSE
# So actually not always! *****************************************************
# which means can't make regular 16-day time series, which is probably why
# usually bfastts(type = "irregular") and make 1-day time series


# Test plotting histogram
# x <- dateDiff_DG1_vec
# breaks <- seq(min(x), max(x), 8)
# histOut <- hist(x = x, breaks = breaks, right = FALSE, freq = FALSE)
# # Understand the density
# sum(histOut$density) # This is not 1 because diff between breaks are not 1
# sum(diff(histOut$breaks) * histOut$density)   # This is 1
# sum(8 * histOut$density)                      # This is 1

# ********************************************
# Plot histogram of frequency as percentage
# ********************************************

# Make function to plot a customized histogram
# (1) All acquisitions
myHist <- function(x, myMain, col = "white", add = FALSE, lty, ylim = c(0,100), xlim = c(0,365)) {
  myBreaks <- seq(0, 1120, 8)    # seq(0, 304, 8)                # Common breaks
  histOut <- hist(x, 
                  breaks = myBreaks, 
                  right = FALSE, plot = FALSE)
  histOut$density <- histOut$counts/sum(histOut$counts) * 100   # Replace density slot with frequency percentage
  plot(histOut, freq = FALSE, ylim = ylim, xlim = xlim,
       ylab = "Frequency (%)", 
       xlab = "Days", # "Time between valid observations (days)"
       main = myMain,
       col = col,
       add = add,
       lty = lty,
       xaxp = c(0,400,8))
}

# (2) Cloud-free observations
myHistValid <- function(x, myMain, add = FALSE, col = "white", lty, ylim = c(0,100), xlim = c(0,365), xaxp = c(0,1100,22),
                        ylab = "Frequency (%)", xlab = "Days between current and previous cloud-free observation", cex.axis = 1) {
  myBreaks <- seq(0, 1120, 8)                    # Common breaks. All but one DG scene has max=728. DG1 has 47 obs (0.7%) with dateDiff >728 (up to 1120)
  histOut <- hist(x, 
                  breaks = myBreaks, 
                  right = FALSE, plot = FALSE)
  histOut$density <- histOut$counts/sum(histOut$counts) * 100   # Replace density slot with frequency percentage
  plot(histOut, freq = FALSE, ylim = ylim, xlim = xlim,
       ylab = ylab, 
       xlab = xlab,   # "Time between valid observations (days)"
       main = myMain,
       add = add,
       col = col,
       lty = lty,
       xaxp = xaxp,
       cex.axis = cex.axis)
}



# Use the function to plot a customized histogram
# (1) All acquisitions
# par(mfrow = c(2,4))
# myHist(dateDiff_DG1_vec, "DG1")               # DG1
# myHist(dateDiff_DG2_vec, "DG2")               # DG2
# myHist(dateDiff_SC1_vec, "SC1")               # SC1
# myHist(dateDiff_sq9_vec, "sq9")               # sq9
# myHist(dateDiff_sq10_vec, "sq10")             # sq10
# myHist(dateDiff_sq11_vec, "sq11")             # sq11
# myHist(dateDiff_sq13_vec, "sq13")             # sq13

dateDiff_all_vec <- c(dateDiff_DG1_vec,
                            dateDiff_DG2_vec,
                            dateDiff_SC1_vec,
                            dateDiff_sq9_vec,
                            dateDiff_sq11_vec,
                            dateDiff_sq13_vec)

# myHist(dateDiff_all_vec, "ALL", col = "white")    




# (2) Only valid observations
# par(mfrow = c(2,4))
# myHistValid(dateDiff_DG1_vec_valid, "DG1")               # DG1
# myHistValid(dateDiff_DG2_vec_valid, "DG2")               # DG2
# myHistValid(dateDiff_SC1_vec_valid, "SC1")               # SC1
# myHistValid(dateDiff_sq9_vec_valid, "sq9")               # sq9
# myHistValid(dateDiff_sq10_vec_valid, "sq10")             # sq10
# myHistValid(dateDiff_sq11_vec_valid, "sq11")             # sq11
# myHistValid(dateDiff_sq13_vec_valid, "sq13")             # sq13


dateDiff_all_vec_valid <- c(dateDiff_DG1_vec_valid,
                            dateDiff_DG2_vec_valid,
                            dateDiff_SC1_vec_valid,
                            dateDiff_sq9_vec_valid,
                            dateDiff_sq11_vec_valid,
                            dateDiff_sq13_vec_valid)

# par_default <- par()
# 
# 
# col2hex("red")
# col2hex("blue")
# 
# par(mfrow = c(1,2))
# myHist(dateDiff_all_vec, "", col = "white", add = FALSE, lty = 1, ylim = c(0,40), xlim = c(0,365))
# myHistValid(dateDiff_all_vec_valid, "", add = FALSE, col = "white", lty = 1, ylim = c(0,20), xlim = c(0,1120))            
# 
# summary(dateDiff_all_vec_valid)

# FINAL PLOT FOR MANUSCRIPT

# par(mfrow = c(2,2), ps = 12, 
#     mar = c(2.6, 2.6, 1.3, 0.4),    # mar = c(3, 3.5, 1.5, 0.5)
#     # mai = c(0.5, 0.5, 0.2, 0.2),
#     mgp = c(1.5, 0.5, 0))   # las = 1   mgp = c(2, 0.7, 0)
# 



pdf(str_c(final.fig.path, "effective_temporal_resolution.pdf"), 
    width = 7, height = 3.5, pointsize = 12)

par(fig = c(0,1,0,1), mar = c(3, 3, 0.5, 0.5),  mgp = c(2, 0.7, 0), ps = 12)
myHistValid(dateDiff_all_vec_valid, "", add = FALSE, col = "white", lty = 1, ylim = c(0,20), xlim = c(0,1120), cex.axis = 1) 
box()
rect(xleft = -5, ybottom = 0, xright = 58, ytop = 16.5, lty = 2) 
rect(xleft = 420, ybottom = 7.2, xright = 1040, ytop = 18.7, lty = 2) 
segments(x0 = 58, y0 = 16.5, x1 = 420, y1 = 18.7)
segments(x0 = 58, y0 = 0, x1 = 420, y1 = 7.2)
text(30, 17.5, "59.2%")
par(fig = c(0.4,0.9,0.4,0.9), new = T)  
myHistValid(dateDiff_all_vec_valid, "", add = FALSE, col = "white", lty = 1, ylim = c(0,20), xlim = c(0,56), xaxp = c(0,56,7),
            xlab = "", ylab = "", cex.axis = 0.75)  


dev.off()



# *****************************************************************************
# Plot contribution of different sensors ----------------------------------
# *****************************************************************************

















