bfmSpatial.DG1.run27 <- read_rds(str_c(path, "/bfmSpatial_results/bfmSpatial_DG1_run27.rds"))
bfmSpatial.DG2.run27 <- read_rds(str_c(path, "/bfmSpatial_results/bfmSpatial_DG2_run27.rds"))
bfmSpatial.SC1.run27 <- read_rds(str_c(path, "/bfmSpatial_results/bfmSpatial_SC1_run27.rds"))
bfmSpatial.SQ9.run27 <- read_rds(str_c(path, "/bfmSpatial_results/bfmSpatial_SQ9_run27.rds"))

bfmSpatial.SC1.run27.notAdd1Year <- read_rds(str_c(path, "/bfmSpatial_results/bfmSpatial_SC1_run27_notAdd1Year.rds"))

bfmSpatial.DG1.run27.untilEndOfVHSRYear <- read_rds(str_c(path, "/bfmSpatial_results/bfmSpatial_DG1_run27_untilEndOfVHSRYear.rds"))
bfmSpatial.DG2.run27.untilEndOfVHSRYear <- read_rds(str_c(path, "/bfmSpatial_results/bfmSpatial_DG2_run27_untilEndOfVHSRYear.rds"))
bfmSpatial.SC1.run27.untilEndOfVHSRYear <- read_rds(str_c(path, "/bfmSpatial_results/bfmSpatial_SC1_run27_untilEndOfVHSRYear.rds"))
bfmSpatial.SQ9.run27.untilEndOfVHSRYear <- read_rds(str_c(path, "/bfmSpatial_results/bfmSpatial_SQ9_run27_untilEndOfVHSRYear.rds"))

bfmSpatial.SQ11.run27.untilEndOfVHSRYear <- read_rds(str_c(path, "/bfmSpatial_results/bfmSpatial_SQ11_run27_untilEndOfVHSRYear.rds"))
bfmSpatial.SQ13.run27.untilEndOfVHSRYear <- read_rds(str_c(path, "/bfmSpatial_results/bfmSpatial_SQ13_run27_untilEndOfVHSRYear.rds"))

# **********************************************************************************
# DG1
# **********************************************************************************
change.DG1.run27 <- bfmSpatial.DG1.run27$breakpoint

# Plot decimal date of change
raster::plot(change.DG1.run27)

# Plot years of change 
change.DG1.run27.year <- calc(change.DG1.run27, floor)
min.year <- summary(change.DG1.run27.year)[1,]
max.year <- summary(change.DG1.run27.year)[5,] + 1
  
brks <- c(min.year:max.year); brks.char <- as.character(brks)
col <- "RdYlBu"   # "RdBu"
raster::plot(change.DG1.run27.year, col=rev(brewer.pal(8, col)), legend=F, main="")
raster::plot(change.DG1.run27.year, col=rev(brewer.pal(8, col)), legend.only=T, legend.width=1, legend.shrink=1, side=4, cex=1.25,
     axis.args=list(at=brks, labels=brks.char, cex.axis=1.25))


# **********************************************************************************
# Decision, plot the year of change, export the geotiff to make map in Arcmap
# **********************************************************************************

# **********************************************************************************
# DG1
# **********************************************************************************
change.DG1.run27 <- bfmSpatial.DG1.run27$breakpoint
change.DG1.run27.year <- calc(change.DG1.run27, floor)
summary(change.DG1.run27.year)[1,]
summary(change.DG1.run27.year)[5,] + 1

writeRaster(change.DG1.run27.year, format = "GTiff",
            filename = str_c(path, "/bfmSpatial_results/geotiff/bfmSpatial_DG1_run27_change_year.tif"))

# **********************************************************************************
# DG1 (until end of VHSR year)
# **********************************************************************************
change.DG1.run27.untilEndOfVHSRYear <- bfmSpatial.DG1.run27.untilEndOfVHSRYear$breakpoint
change.DG1.run27.untilEndOfVHSRYear.year <- calc(change.DG1.run27.untilEndOfVHSRYear, floor)
summary(change.DG1.run27.untilEndOfVHSRYear.year)[1,]
summary(change.DG1.run27.untilEndOfVHSRYear.year)[5,] + 1

writeRaster(change.DG1.run27.untilEndOfVHSRYear.year, format = "GTiff",
            filename = str_c(path, "/bfmSpatial_results/geotiff/bfmSpatial_DG1_run27untilEndOfVHSRYear_change_year.tif"))


# **********************************************************************************
# DG2
# **********************************************************************************
change.DG2.run27 <- bfmSpatial.DG2.run27$breakpoint
change.DG2.run27.year <- calc(change.DG2.run27, floor)
summary(change.DG2.run27.year)[1,]
summary(change.DG2.run27.year)[5,] + 1
unique(values(change.DG2.run27.year))

writeRaster(change.DG2.run27.year, format = "GTiff",
            filename = str_c(path, "/bfmSpatial_results/geotiff/bfmSpatial_DG2_run27_change_year.tif"))

# **********************************************************************************
# DG2 (until end of VHSR year)
# **********************************************************************************
change.DG2.run27.untilEndOfVHSRYear <- bfmSpatial.DG2.run27.untilEndOfVHSRYear$breakpoint
change.DG2.run27.untilEndOfVHSRYear.year <- calc(change.DG2.run27.untilEndOfVHSRYear, floor)
summary(change.DG2.run27.untilEndOfVHSRYear.year)[1,]
summary(change.DG2.run27.untilEndOfVHSRYear.year)[5,] + 1

writeRaster(change.DG2.run27.untilEndOfVHSRYear.year, format = "GTiff",
            filename = str_c(path, "/bfmSpatial_results/geotiff/bfmSpatial_DG2_run27untilEndOfVHSRYear_change_year.tif"))


# **********************************************************************************
# SC1
# **********************************************************************************
change.SC1.run27 <- bfmSpatial.SC1.run27$breakpoint
change.SC1.run27.year <- calc(change.SC1.run27, floor)
summary(change.SC1.run27.year)[1,]
summary(change.SC1.run27.year)[5,] + 1

writeRaster(change.SC1.run27.year, format = "GTiff",
            filename = str_c(path, "/bfmSpatial_results/geotiff/bfmSpatial_SC1_run27_change_year.tif"))

# **********************************************************************************
# SC1 (not add 1 year)
# **********************************************************************************
change.SC1.run27.notAdd1Year <- bfmSpatial.SC1.run27.notAdd1Year$breakpoint
change.SC1.run27.notAdd1Year.year <- calc(change.SC1.run27.notAdd1Year, floor)
summary(change.SC1.run27.notAdd1Year.year)[1,]
summary(change.SC1.run27.notAdd1Year.year)[5,] + 1

writeRaster(change.SC1.run27.notAdd1Year.year, format = "GTiff",
            filename = str_c(path, "/bfmSpatial_results/geotiff/bfmSpatial_SC1_run27notAdd1Year_change_year.tif"))

# **********************************************************************************
# SC1 (until end of VHSR year)
# **********************************************************************************
change.SC1.run27.untilEndOfVHSRYear <- bfmSpatial.SC1.run27.untilEndOfVHSRYear$breakpoint
change.SC1.run27.untilEndOfVHSRYear.year <- calc(change.SC1.run27.untilEndOfVHSRYear, floor)
summary(change.SC1.run27.untilEndOfVHSRYear.year)[1,]
summary(change.SC1.run27.untilEndOfVHSRYear.year)[5,] + 1

writeRaster(change.SC1.run27.untilEndOfVHSRYear.year, format = "GTiff",
            filename = str_c(path, "/bfmSpatial_results/geotiff/bfmSpatial_SC1_run27untilEndOfVHSRYear_change_year.tif"))


# **********************************************************************************
# SQ9
# **********************************************************************************
change.SQ9.run27 <- bfmSpatial.SQ9.run27$breakpoint
change.SQ9.run27.year <- calc(change.SQ9.run27, floor)
summary(change.SQ9.run27.year)[1,]
summary(change.SQ9.run27.year)[5,] + 1

writeRaster(change.SQ9.run27.year, format = "GTiff",
            filename = str_c(path, "/bfmSpatial_results/geotiff/bfmSpatial_SQ9_run27_change_year.tif"))

# **********************************************************************************
# SQ9 (until end of VHSR year)
# **********************************************************************************
change.SQ9.run27.untilEndOfVHSRYear <- bfmSpatial.SQ9.run27.untilEndOfVHSRYear$breakpoint
change.SQ9.run27.untilEndOfVHSRYear.year <- calc(change.SQ9.run27.untilEndOfVHSRYear, floor)
summary(change.SQ9.run27.untilEndOfVHSRYear.year)[1,]
summary(change.SQ9.run27.untilEndOfVHSRYear.year)[5,] + 1

writeRaster(change.SQ9.run27.untilEndOfVHSRYear.year, format = "GTiff",
            filename = str_c(path, "/bfmSpatial_results/geotiff/bfmSpatial_SQ9_run27untilEndOfVHSRYear_change_year.tif"))


# **********************************************************************************
# SQ11 (until end of VHSR year)
# **********************************************************************************
change.SQ11.run27.untilEndOfVHSRYear <- bfmSpatial.SQ11.run27.untilEndOfVHSRYear$breakpoint
change.SQ11.run27.untilEndOfVHSRYear.year <- calc(change.SQ11.run27.untilEndOfVHSRYear, floor)
summary(change.SQ11.run27.untilEndOfVHSRYear.year)[1,]
summary(change.SQ11.run27.untilEndOfVHSRYear.year)[5,] + 1

writeRaster(change.SQ11.run27.untilEndOfVHSRYear.year, format = "GTiff",
            filename = str_c(path, "/bfmSpatial_results/geotiff/bfmSpatial_SQ11_run27untilEndOfVHSRYear_change_year.tif"))

# **********************************************************************************
# SQ13 (until end of VHSR year)
# **********************************************************************************
change.SQ13.run27.untilEndOfVHSRYear <- bfmSpatial.SQ13.run27.untilEndOfVHSRYear$breakpoint
change.SQ13.run27.untilEndOfVHSRYear.year <- calc(change.SQ13.run27.untilEndOfVHSRYear, floor)
summary(change.SQ13.run27.untilEndOfVHSRYear.year)[1,]
summary(change.SQ13.run27.untilEndOfVHSRYear.year)[5,] + 1

writeRaster(change.SQ13.run27.untilEndOfVHSRYear.year, format = "GTiff",
            filename = str_c(path, "/bfmSpatial_results/geotiff/bfmSpatial_SQ13_run27untilEndOfVHSRYear_change_year.tif"))
