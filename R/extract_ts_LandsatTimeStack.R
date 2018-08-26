#*****************************************************************************
# Last date of VHSR, thus monitoring --------------------------------------
#*****************************************************************************
ref.lastDate <- list(DG1 = as.Date("2015-08-15"), DG2 = as.Date("2015-08-08"),
                     SQ9 = as.Date("2014-05-13"), SQ10 = as.Date("2015-08-17"),
                     SQ11 = as.Date("2014-02-04"), SQ13 = as.Date("2014-05-13"),
                     SC1 = as.Date("2014-02-04"))


#*****************************************************************************
# Update: Import the unique-date NDMI time stack to extract ts until the end of latest VHSR year, to compare with Hansen --------------------------------
#*****************************************************************************
# The raster time stack (unique dates, but the end date is till 2017)
NDMI.DG1.unique <- read_rds(str_c(path, "/raster_time_stack/ndmi_rds/ndmi_DG_1_unique.rds"))
NDMI.DG2.unique <- read_rds(str_c(path, "/raster_time_stack/ndmi_rds/ndmi_DG_2_unique.rds"))
NDMI.SC1.unique <- read_rds(str_c(path, "/raster_time_stack/ndmi_rds/ndmi_SC_1_unique.rds"))
NDMI.SQ9.unique <- read_rds(str_c(path, "/raster_time_stack/ndmi_rds/ndmi_sq_9_unique.rds"))
NDMI.SQ11.unique <- read_rds(str_c(path, "/raster_time_stack/ndmi_rds/ndmi_sq_11_unique.rds"))
NDMI.SQ13.unique <- read_rds(str_c(path, "/raster_time_stack/ndmi_rds/ndmi_sq_13_unique.rds"))

# # Update: extract ts up to the end of latest VHSR year, to compare with Hansen annual change map
# ref.lastDate <- list(DG1 = as.Date("2015-12-31"), DG2 = as.Date("2015-12-31"),
#                      SC1 = as.Date("2014-12-31"), SQ9 = as.Date("2014-12-31"), 
#                      SQ11 = as.Date("2014-12-31"), SQ13 = as.Date("2014-12-31"))


# Update: also extract ts up to the end of the year BEFORE the latest VHSR, to compare with Hansen's against reference data
ref.lastDate <- list(DG1 = as.Date("2014-12-31"), DG2 = as.Date("2014-12-31"),
                     SC1 = as.Date("2013-12-31"), SQ9 = as.Date("2013-12-31"), 
                     SQ11 = as.Date("2013-12-31"), SQ13 = as.Date("2013-12-31"))



# Need these dates in c(year, jday) 
source("R/Rfunction/dateToYearJday.R")
ref.lastDate <- lapply(ref.lastDate, dateToYearJday)

# Cut the raster time stack end date
NDMI.DG1.unique.sub <- subsetRasterTS(NDMI.DG1.unique, maxDate = ref.lastDate$DG1)
NDMI.DG2.unique.sub <- subsetRasterTS(NDMI.DG2.unique, maxDate = ref.lastDate$DG2)
NDMI.SC1.unique.sub <- subsetRasterTS(NDMI.SC1.unique, maxDate = ref.lastDate$SC1)
NDMI.SQ9.unique.sub <- subsetRasterTS(NDMI.SQ9.unique, maxDate = ref.lastDate$SQ9)
NDMI.SQ11.unique.sub <- subsetRasterTS(NDMI.SQ11.unique, maxDate = ref.lastDate$SQ11)
NDMI.SQ13.unique.sub <- subsetRasterTS(NDMI.SQ13.unique, maxDate = ref.lastDate$SQ13)


#*****************************************************************************
# Import the unique-date raster time stack --------------------------------
# subsetRasterTS() cannot be used for new Landsat collection scene names!
#*****************************************************************************
# SC1
red.SC1.unique <- read_rds(str_c(path, "/raster_time_stack/singleband_rds/red_SC1_unique.rds"))
nir.SC1.unique <- read_rds(str_c(path, "/raster_time_stack/singleband_rds/nir_SC1_unique.rds"))
swir1.SC1.unique <- read_rds(str_c(path, "/raster_time_stack/singleband_rds/swir1_SC1_unique.rds"))

# DG1
red.DG1.unique <- read_rds(str_c(path, "/raster_time_stack/singleband_rds/red_DG1_unique.rds"))
nir.DG1.unique <- read_rds(str_c(path, "/raster_time_stack/singleband_rds/nir_DG1_unique.rds"))
swir1.DG1.unique <- read_rds(str_c(path, "/raster_time_stack/singleband_rds/swir1_DG1_unique.rds"))

# DG2
red.DG2.unique <- read_rds(str_c(path, "/raster_time_stack/singleband_rds/red_DG2_unique.rds"))
nir.DG2.unique <- read_rds(str_c(path, "/raster_time_stack/singleband_rds/nir_DG2_unique.rds"))
swir1.DG2.unique <- read_rds(str_c(path, "/raster_time_stack/singleband_rds/swir1_DG2_unique.rds"))

# SQ13
red.SQ13.unique <- read_rds(str_c(path, "/raster_time_stack/singleband_rds/red_SQ13_unique.rds"))
nir.SQ13.unique <- read_rds(str_c(path, "/raster_time_stack/singleband_rds/nir_SQ13_unique.rds"))
swir1.SQ13.unique <- read_rds(str_c(path, "/raster_time_stack/singleband_rds/swir1_SQ13_unique.rds"))


#*****************************************************************************
# Cut the raster time stack to the end of monitoring ----------------------
#*****************************************************************************
# SC1
red.SC1.unique.sub <- subset(red.SC1.unique, which(getZ(red.SC1.unique) <= ref.lastDate$SC1 + 365))
nir.SC1.unique.sub <- subset(nir.SC1.unique, which(getZ(nir.SC1.unique) <= ref.lastDate$SC1 + 365))
swir1.SC1.unique.sub <- subset(swir1.SC1.unique, which(getZ(swir1.SC1.unique) <= ref.lastDate$SC1 + 365))

# DG1
red.DG1.unique.sub <- subset(red.DG1.unique, which(getZ(red.DG1.unique) <= ref.lastDate$DG1))
nir.DG1.unique.sub <- subset(nir.DG1.unique, which(getZ(nir.DG1.unique) <= ref.lastDate$DG1))
swir1.DG1.unique.sub <- subset(swir1.DG1.unique, which(getZ(swir1.DG1.unique) <= ref.lastDate$DG1))

# DG2
red.DG2.unique.sub <- subset(red.DG2.unique, which(getZ(red.DG2.unique) <= ref.lastDate$DG2))
nir.DG2.unique.sub <- subset(nir.DG2.unique, which(getZ(nir.DG2.unique) <= ref.lastDate$DG2))
swir1.DG2.unique.sub <- subset(swir1.DG2.unique, which(getZ(swir1.DG2.unique) <= ref.lastDate$DG2))

# SQ13
red.SQ13.unique.sub <- subset(red.SQ13.unique, which(getZ(red.SQ13.unique) <= ref.lastDate$SQ13))
nir.SQ13.unique.sub <- subset(nir.SQ13.unique, which(getZ(nir.SQ13.unique) <= ref.lastDate$SQ13))
swir1.SQ13.unique.sub <- subset(swir1.SQ13.unique, which(getZ(swir1.SQ13.unique) <= ref.lastDate$SQ13))


#*****************************************************************************
# Now read the selected mesh points (= pixels) to extract the spectral time series --------
#*****************************************************************************
shp.folder <- paste(path, "/vector_data/FINALLY_USED", sep = "")
refPixels.DG1 <- readOGR(dsn = shp.folder, layer = "meshSelect_prevDG1")
refPixels.DG2 <- readOGR(dsn = shp.folder, layer = "meshSelect_prevDG2")    
refPixels.SC1 <- readOGR(dsn = shp.folder, layer = "meshSelect_SC_1")
refPixels.SQ9 <- readOGR(dsn = shp.folder, layer = "meshSelect_sq_9")
refPixels.SQ11 <- readOGR(dsn = shp.folder, layer = "meshSelect_sq_11")
refPixels.SQ13 <- readOGR(dsn = shp.folder, layer = "meshSelect_sq_13")

#*****************************************************************************
# Extract time series -----------------------------------------------------
#*****************************************************************************
# require(velox)
# vlx <- velox(red.SC1.unique.sub)    # This takes a while, better use zooExtract btw
# ?VeloxRaster_extract
# spectra <- vlx$extract()
# names(spectra)[-1] <- 

?zooExtract



#*****************************************************************************
# Update: extract NDMI ts up to the year before the latest VHSR, to compare with Hansen's accuracy against reference samples
#*****************************************************************************
# DG1
extr.NDMI.sub.DG1 <- zooExtract(NDMI.DG1.unique.sub, coordinates(refPixels.DG1), method = "simple")
colnames(extr.NDMI.sub.DG1) <- as.character(refPixels.DG1$Id)
write_rds(extr.NDMI.sub.DG1, 
          str_c(path, "/extracted_time_series/FINALLY_USED/upToBeforeLatestVHSRYear/extr_NDMI_sub_DG1.rds"))

# DG2
extr.NDMI.sub.DG2 <- zooExtract(NDMI.DG2.unique.sub, coordinates(refPixels.DG2), method = "simple")
colnames(extr.NDMI.sub.DG2) <- as.character(refPixels.DG2$Id)
write_rds(extr.NDMI.sub.DG2, 
          str_c(path, "/extracted_time_series/FINALLY_USED/upToBeforeLatestVHSRYear/extr_NDMI_sub_DG2.rds"))

# SC1
extr.NDMI.sub.SC1 <- zooExtract(NDMI.SC1.unique.sub, coordinates(refPixels.SC1), method = "simple")
colnames(extr.NDMI.sub.SC1) <- as.character(refPixels.SC1$Id)
write_rds(extr.NDMI.sub.SC1, 
          str_c(path, "/extracted_time_series/FINALLY_USED/upToBeforeLatestVHSRYear/extr_NDMI_sub_SC1.rds"))

# SQ9
extr.NDMI.sub.SQ9 <- zooExtract(NDMI.SQ9.unique.sub, coordinates(refPixels.SQ9), method = "simple")
colnames(extr.NDMI.sub.SQ9) <- as.character(refPixels.SQ9$Id)
write_rds(extr.NDMI.sub.SQ9, 
          str_c(path, "/extracted_time_series/FINALLY_USED/upToBeforeLatestVHSRYear/extr_NDMI_sub_SQ9.rds"))

# SQ11
extr.NDMI.sub.SQ11 <- zooExtract(NDMI.SQ11.unique.sub, coordinates(refPixels.SQ11), method = "simple")
colnames(extr.NDMI.sub.SQ11) <- as.character(refPixels.SQ11$Id)
write_rds(extr.NDMI.sub.SQ11, 
          str_c(path, "/extracted_time_series/FINALLY_USED/upToBeforeLatestVHSRYear/extr_NDMI_sub_SQ11.rds"))

# SQ13
extr.NDMI.sub.SQ13 <- zooExtract(NDMI.SQ13.unique.sub, coordinates(refPixels.SQ13), method = "simple")
colnames(extr.NDMI.sub.SQ13) <- as.character(refPixels.SQ13$Id)
write_rds(extr.NDMI.sub.SQ13, 
          str_c(path, "/extracted_time_series/FINALLY_USED/upToBeforeLatestVHSRYear/extr_NDMI_sub_SQ13.rds"))





#*****************************************************************************
# SC1
#*****************************************************************************
# Red
extr.red.sub.SC1 <- zooExtract(red.SC1.unique.sub, coordinates(refPixels.SC1), method = "simple")
colnames(extr.red.sub.SC1) <- as.character(refPixels.SC1$Id)
write_rds(extr.red.sub.SC1, 
          str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_red_sub_SC1.rds"))

# NIR
extr.nir.sub.SC1 <- zooExtract(nir.SC1.unique.sub, coordinates(refPixels.SC1), method = "simple")
colnames(extr.nir.sub.SC1) <- as.character(refPixels.SC1$Id)
write_rds(extr.nir.sub.SC1, 
          str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_nir_sub_SC1.rds"))

# SWIR1
extr.swir1.sub.SC1 <- zooExtract(swir1.SC1.unique.sub, coordinates(refPixels.SC1), method = "simple")
colnames(extr.swir1.sub.SC1) <- as.character(refPixels.SC1$Id)
write_rds(extr.swir1.sub.SC1, 
          str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_swir1_sub_SC1.rds"))

#*****************************************************************************
# DG1
#*****************************************************************************
# Red
extr.red.sub.DG1 <- zooExtract(red.DG1.unique.sub, coordinates(refPixels.DG1), method = "simple")
colnames(extr.red.sub.DG1) <- as.character(refPixels.DG1$Id)
write_rds(extr.red.sub.DG1, 
          str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_red_sub_DG1.rds"))

# NIR
extr.nir.sub.DG1 <- zooExtract(nir.DG1.unique.sub, coordinates(refPixels.DG1), method = "simple")
colnames(extr.nir.sub.DG1) <- as.character(refPixels.DG1$Id)
write_rds(extr.nir.sub.DG1, 
          str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_nir_sub_DG1.rds"))

# SWIR1
extr.swir1.sub.DG1 <- zooExtract(swir1.DG1.unique.sub, coordinates(refPixels.DG1), method = "simple")
colnames(extr.swir1.sub.DG1) <- as.character(refPixels.DG1$Id)
write_rds(extr.swir1.sub.DG1, 
          str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_swir1_sub_DG1.rds"))

#*****************************************************************************
# DG2
#*****************************************************************************
# Red
extr.red.sub.DG2 <- zooExtract(red.DG2.unique.sub, coordinates(refPixels.DG2), method = "simple")
colnames(extr.red.sub.DG2) <- as.character(refPixels.DG2$Id)
write_rds(extr.red.sub.DG2, 
          str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_red_sub_DG2.rds"))

# NIR
extr.nir.sub.DG2 <- zooExtract(nir.DG2.unique.sub, coordinates(refPixels.DG2), method = "simple")
colnames(extr.nir.sub.DG2) <- as.character(refPixels.DG2$Id)
write_rds(extr.nir.sub.DG2, 
          str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_nir_sub_DG2.rds"))

# SWIR1
extr.swir1.sub.DG2 <- zooExtract(swir1.DG2.unique.sub, coordinates(refPixels.DG2), method = "simple")
colnames(extr.swir1.sub.DG2) <- as.character(refPixels.DG2$Id)
write_rds(extr.swir1.sub.DG2, 
          str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_swir1_sub_DG2.rds"))

#*****************************************************************************
# SQ13
#*****************************************************************************
# Red
extr.red.sub.SQ13 <- zooExtract(red.SQ13.unique.sub, coordinates(refPixels.SQ13), method = "simple")
colnames(extr.red.sub.SQ13) <- as.character(refPixels.SQ13$Id)
write_rds(extr.red.sub.SQ13, 
          str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_red_sub_SQ13.rds"))

# NIR
extr.nir.sub.SQ13 <- zooExtract(nir.SQ13.unique.sub, coordinates(refPixels.SQ13), method = "simple")
colnames(extr.nir.sub.SQ13) <- as.character(refPixels.SQ13$Id)
write_rds(extr.nir.sub.SQ13, 
          str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_nir_sub_SQ13.rds"))

# SWIR1
extr.swir1.sub.SQ13 <- zooExtract(swir1.SQ13.unique.sub, coordinates(refPixels.SQ13), method = "simple")
colnames(extr.swir1.sub.SQ13) <- as.character(refPixels.SQ13$Id)
write_rds(extr.swir1.sub.SQ13, 
          str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_swir1_sub_SQ13.rds"))



