## This code takes the Landsat image time stack downloaded from GEE and prepare them to be ready for running BFAST Spatial
## Update: err not quite ready actually needs to run makeUniqueDates() later. Update: this is implemented already

# Read the image time stack downloaded from GEE (change input file name!)
L5 <- brick(paste(path, "/raster_time_stack/singleband_geotiff/L5_swir1_SQ13.tif", sep = ""))   # Landsat-5

L7 <- brick(paste(path, "/raster_time_stack/singleband_geotiff/L7_swir1_SQ13.tif", sep = ""))   # Landsat-7    

L8 <- brick(paste(path, "/raster_time_stack/singleband_geotiff/L8_swir1_SQ13.tif", sep = ""))   # Landsat-8

# !FOR COLLECTION 1: Replace 0 with NA, apply scale 0.0001
L5[L5 == 0] <- NA
L5 <- calc(L5, function(x) x * 0.0001)

L7[L7 == 0] <- NA
L7 <- calc(L7, function(x) x * 0.0001)

L8[L8 == 0] <- NA
L8 <- calc(L8, function(x) x * 0.0001)

# Read the scene ID saved by copy-pasting from GEE console (change the study area!)
L5.id <- read_csv(paste(path, "/raster_time_stack/scene_id_newC1T1/L5_SQ13.csv", sep = ""))
L5.id <- L5.id[seq(2,nrow(L5.id),by=2),]

L7.id <- read_csv(paste(path, "/raster_time_stack/scene_id_newC1T1/L7_SQ13.csv", sep = ""))
L7.id <- L7.id[seq(2,nrow(L7.id),by=2),]

L8.id <- read_csv(paste(path, "/raster_time_stack/scene_id_newC1T1/L8_SQ13.csv", sep = ""))
L8.id <- L8.id[seq(2,nrow(L8.id),by=2),]

# Output file
outdir1 <- str_c(path, "/raster_time_stack/singleband_rds/swir1_SQ13.rds")  # change output file name!           
ourdir2 <-  str_c(path, "/raster_time_stack/singleband_rds/swir1_SQ13_unique.rds") # change output file name!  

# Source the function
source("R/Rfunction/prepareLandsatTimeStack.R")

# Execute the function
prepareLandsatTimeStack(imgTimeStack_L5 = L5, imgTimeStack_L7 = L7, imgTimeStack_L8 = L8,
                        sceneId_L5 = L5.id, sceneId_L7 = L7.id, sceneId_L8 = L8.id,
                        outName = outdir1, uniqueOutName = ourdir2, collection = "Tier 1")

