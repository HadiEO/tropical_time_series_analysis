GLAD.dir <- 'C:/LocalUserData/User-data/hadi1/PHD_RESEARCH/STUDY_IIASA/bfast_hadi_yssp_manuscript/to_resubmit_FORESTS/revision/Hansen_data/GLAD_Alerts_Footprint'

# GLAD.shp <- st_read(str_c(GLAD.dir, "/GLAD_Alerts_Footprint.shp"))

GLAD.tif <- raster(str_c(GLAD.dir, "/tif/SEA_day_2015n.tif"))   # WGS84

# Clip GLAD.tif to the extent of VHSR scenes DG1 and DG2
extent.dir <- 'C:/LocalUserData/User-data/hadi1/PHD_RESEARCH/STUDY_IIASA/bfast_hadi_yssp_data/vector_data/FINALLY_USED_EXTENT'
extent.DG1 <- st_read(str_c(extent.dir, "/DG1_extent.shp"))
extent.DG2 <- st_read(str_c(extent.dir, "/DG2_extent.shp"))

as(extent.DG1, "Spatial") # Don't know why it doesn't work

# Just do manually for now (xmin, xmax, ymin, ymax)
extent(extent.DG1)
GLAD.DG1 <- raster::crop(GLAD.tif, c(118.03, 118.04, 2.300005, 2.31))
raster::plot(GLAD.DG1)

extent(extent.DG2)
GLAD.DG2 <- raster::crop(GLAD.tif, c(117.98, 117.99, 2.250005, 2.26))
raster::plot(GLAD.DG2)


# Replace pixels with detection day after the date of latest VHSR image, in each site.
# DG1 : 2015-08-15
# DG2: 2015-08-08

GLAD.DG1[GLAD.DG1 > yday(as.Date("2015-08-15"))] <- NA
GLAD.DG2[GLAD.DG2 > yday(as.Date("2015-08-08"))] <- NA

# Export as tif
writeRaster(GLAD.DG1, str_c(GLAD.dir, "/tif/clipped/GLAD_DG1.tif"))
writeRaster(GLAD.DG2, str_c(GLAD.dir, "/tif/clipped/GLAD_DG2.tif"))


# Plot the detection day pixels on top of latest VHSR image

