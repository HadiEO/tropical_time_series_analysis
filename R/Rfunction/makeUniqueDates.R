# x <- NDMI.DG1
# x <- S1.VH_DG1

# Argument:
# x => rasterTimeStack with some dates with multiple layers
# sensor => Landsat or Sentinel-1, which has different "date" information embedded in the scene id

# Note: here simply take mean of observations for the same date

# This function works only if there are at most two observations (layers) for a given date
makeUniqueDates <- function(x, sensor, collection) {
  
  temp <- table(getZ(x)) %>% as_tibble      # There are dates with multiple layers

  temp3 <- temp[temp$n > 1,]                # Z attribute = dates with multiple layers
  
  temp4 <- which(as.character(getZ(x)) %in% temp3$Var1)    # Which layer number (ordered) belongs to the dates with multiple layers?
  temp5 <- subset(x, temp4)                                # Get RasterTS with multiple layers per date
  
  temp6 <- which(!as.character(getZ(x)) %in% temp3$Var1)   # Which layer number (ordered) NOT belongs to the dates with multiple layers?
  temp7 <- subset(x, temp6)                         # Get RasterTS with ONE layer per date
  
  # table(table(getZ(temp5)))               # Check that all have 2 layers
  
  # Take the mean of duplicated dates
  k12.init <- temp5[[1]]; k12.init <- setZ(k12.init, z =  getZ(temp5)[1]) 
  k12.init[] <- NA
  names(k12.init) <- "init"
  
  for(k in seq(1, nlayers(temp5), by = 2)) {      # run k12.init first!
    
    k1 <- temp5[[k]]; k1 <- setZ(k1, z = getZ(temp5)[k])
    k2 <- temp5[[k+1]]; k2 <- setZ(k2, z =  getZ(temp5)[k+1])                           # This works because each dates have exactly two scenes
    # k12 <- overlay(k1, k2, fun = function(r1, r2) mean(c(r1, r2), na.rm = TRUE))
    k12 <- raster::brick(k1, k2)
    k12.mean <- calc(k12, fun = function(r) mean(r, na.rm = TRUE))
    names(k12.mean) <- names(k1); k12.mean <- setZ(k12.mean, z =  getZ(temp5)[k]) 
    k12.init <- raster::stack(k12.init, k12.mean)
    
  }
  
  # Remove the first layer i.e. init
  k12.init <- subset(k12.init, 2:nlayers(k12.init))
  
  # Merge back with 
  x.uniqueDates <- raster::stack(temp7, k12.init)
  
  # SetZ and Re-order layers by dates
  if (sensor == "Landsat") {
    if (collection == "Tier 1") {
      dates <- as.Date(substr(names(x.uniqueDates), 13, 20), format = "%Y%m%d")
      x.uniqueDates <- setZ(x.uniqueDates, dates, name = "time")
      x.uniqueDates <- subset(x.uniqueDates, order(getZ(x.uniqueDates)))
    } else {
      dates <- getSceneinfo(names(x.uniqueDates))$date 
      x.uniqueDates <- setZ(x.uniqueDates, dates, name = "time")
      x.uniqueDates <- subset(x.uniqueDates, order(getZ(x.uniqueDates)))
    }
    
  } else if (sensor == "Sentinel-1") {
    dates <- as.Date(substr(names(x.uniqueDates), 18, 25), format = "%Y%m%d")
    x.uniqueDates <- setZ(x.uniqueDates, dates, name = "time")
    x.uniqueDates <- subset(x.uniqueDates, order(getZ(x.uniqueDates)))
  } else if(sensor == "Sentinel-2") {
    dates <- as.Date(substr(names(x.uniqueDates), 2, 9), format = "%Y%m%d")
    x.uniqueDates <- setZ(x.uniqueDates, dates, name = "time")
    x.uniqueDates <- subset(x.uniqueDates, order(getZ(x.uniqueDates)))
  }

  # Return RasterTS with unique Dates
  return(x.uniqueDates)

}

# 
