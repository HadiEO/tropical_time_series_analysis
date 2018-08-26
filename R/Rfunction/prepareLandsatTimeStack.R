source("R/Rfunction/makeUniqueDates.R")

prepareLandsatTimeStack <- function(imgTimeStack_L5, imgTimeStack_L7, imgTimeStack_L8,
                                    sceneId_L5, sceneId_L7, sceneId_L8,
                                    outName, collection = "Not Tier 1", uniqueOutName) {
    
   
  names(imgTimeStack_L5) <- sceneId_L5$header             ## Rename the brick with scene id
  names(imgTimeStack_L7) <- sceneId_L7$header
  names(imgTimeStack_L8) <- sceneId_L8$header
  
  # Stack across sensors
  imgTimeStack_L578 <- addLayer(imgTimeStack_L5, imgTimeStack_L7, imgTimeStack_L8)

  if(collection == "Tier 1") {
    dates <- as.Date(substr(names(imgTimeStack_L578), 13, 20), format = "%Y%m%d")
    imgTimeStack_L578 <- setZ(imgTimeStack_L578, dates, name = "time")
  } else if(collection == "Not Tier 1") {
    imgTimeStack_L578 <- setZ(imgTimeStack_L578, getSceneinfo(names(imgTimeStack_L578))$date, name = 'time')    # Set time attribute in z slot
  }
 
  # Sort raster layers by dates
  imgTimeStack_L578 <- subset(imgTimeStack_L578, order(getZ(imgTimeStack_L578)))
 
  # Write to disk
  write_rds(imgTimeStack_L578, outName)
  
  # Make unique dates time series
  if(length(unique(getZ(imgTimeStack_L578))) != length(getZ(imgTimeStack_L578))) {
    imgTimeStack_L578.uniqueDates <- makeUniqueDates(x = imgTimeStack_L578, sensor = "Landsat", collection = collection)
  } else {
    imgTimeStack_L578.uniqueDates <- imgTimeStack_L578
  }
  
  # Write to disk
  write_rds(imgTimeStack_L578.uniqueDates, uniqueOutName)
  
  # Say ok if function runs fine
  return("All good!")
}



# TODO: make function not for three sensors
# prepareLandsatTimeStack2Sensors <- function(imgTimeStack_L5, imgTimeStack_L7, imgTimeStack_L8,
#                                     sceneId_L5, sceneId_L7, sceneId_L8,
#                                     outname) {
#   
#   
#   names(imgTimeStack_L5) <- sceneId_L5$header             ## Rename the brick with scene id
#   names(imgTimeStack_L7) <- sceneId_L7$header
#   names(imgTimeStack_L8) <- sceneId_L8$header
#   
#   # Stack across sensors
#   imgTimeStack_L578 <- addLayer(imgTimeStack_L5, imgTimeStack_L7, imgTimeStack_L8)
#   # imgTimeStack_L78 <- addLayer(imgTimeStack_L7, imgTimeStack_L8)
#   
#   imgTimeStack_L578 <- setZ(imgTimeStack_L578, getSceneinfo(names(imgTimeStack_L578))$date, name = 'time')    # Set time attribute in z slot
#   # dates.imgTimeStack_L78 <- as.Date(substr(names(imgTimeStack_L78), 13, 20), format = "%Y%m%d")
#   # imgTimeStack_L78 <- setZ(imgTimeStack_L78, dates.imgTimeStack_L78, name = 'time')    # Set time attribute in z slot
#   
#   # Sort raster layers by dates
#   imgTimeStack_L578 <- subset(imgTimeStack_L578, order(getZ(imgTimeStack_L578)))
#   # imgTimeStack_L78 <- subset(imgTimeStack_L78, order(getZ(imgTimeStack_L78)))
#   # getZ(imgTimeStack_L578)
#   
#   # Write to disk, change the output file name
#   write_rds(imgTimeStack_L578, outname)
#   
#   # write_rds(imgTimeStack_L78, 
#   #           paste(path, "/raster_time_stack/ndmi_rds/toaNDMITimeStack_L78_SQ_10_duringS2.rds", sep = ""))
#   
#   # Make unique dates time series
#   NDMI.uniqueDates <- makeUniqueDates(x = NDMI, sensor = "Landsat", collection = "Not Tier 1")
#   # If this returns error, it can be that the dates are already unique
#   write_rds(NDMI.uniqueDates, str_c(path, "/raster_time_stack/ndmi_rds/ndmi_sq_10_unique.rds"))
#   
#   
# }
# 
