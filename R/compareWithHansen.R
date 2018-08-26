#*****************************************************************************
# Hansen map --------
#*****************************************************************************

hansen.dir <- 'C:/LocalUserData/User-data/hadi1/PHD_RESEARCH/STUDY_IIASA/bfast_hadi_yssp_manuscript/to_resubmit_FORESTS/revision/Hansen_data'

list.files(hansen.dir)

# Loss map (0: Not loss; 	1: Loss)
HansenLoss_DG1 <- raster(str_c(hansen.dir, "/HansenLoss_DG1.tif"))
HansenLoss_DG2 <- raster(str_c(hansen.dir, "/HansenLoss_DG2.tif"))
HansenLoss_SC1 <- raster(str_c(hansen.dir, "/HansenLoss_SC1.tif"))
HansenLoss_SQ9 <- raster(str_c(hansen.dir, "/HansenLoss_SQ9.tif"))
HansenLoss_SQ11 <- raster(str_c(hansen.dir, "/HansenLoss_SQ11.tif"))
HansenLoss_SQ13 <- raster(str_c(hansen.dir, "/HansenLoss_SQ13.tif"))

# Loss year
HansenLossYear_DG1 <- raster(str_c(hansen.dir, "/HansenLossYear_DG1.tif"))
HansenLossYear_DG2 <- raster(str_c(hansen.dir, "/HansenLossYear_DG2.tif"))
HansenLossYear_SC1 <- raster(str_c(hansen.dir, "/HansenLossYear_SC1.tif"))
HansenLossYear_SQ9 <- raster(str_c(hansen.dir, "/HansenLossYear_SQ9.tif"))
HansenLossYear_SQ11 <- raster(str_c(hansen.dir, "/HansenLossYear_SQ11.tif"))
HansenLossYear_SQ13 <- raster(str_c(hansen.dir, "/HansenLossYear_SQ13.tif"))

#*****************************************************************************
# Change loss year encoded value to years, then export back to tif for arcmap
#*****************************************************************************
# Function to recode the raster values
# s <- calc(r, fun=function(x){ x[x < 4] <- NA; return(x)} )
recodeHansenLossYear <- function(x) {
  x[x == 0] <- NA
  x <- x + 2000
  return(x)
}

# Apply the function
HansenLossYear_DG1_rc <- calc(HansenLossYear_DG1, recodeHansenLossYear)
HansenLossYear_DG2_rc <- calc(HansenLossYear_DG2, recodeHansenLossYear)
HansenLossYear_SC1_rc <- calc(HansenLossYear_SC1, recodeHansenLossYear)
HansenLossYear_SQ9_rc <- calc(HansenLossYear_SQ9, recodeHansenLossYear)
HansenLossYear_SQ11_rc <- calc(HansenLossYear_SQ11, recodeHansenLossYear)
HansenLossYear_SQ13_rc <- calc(HansenLossYear_SQ13, recodeHansenLossYear)

# Recode as NA the pixels with loss year later than the latest VHSR image 
HansenLossYear_DG1_rc[HansenLossYear_DG1_rc > 2015] <- NA
HansenLossYear_DG2_rc[HansenLossYear_DG2_rc > 2015] <- NA
HansenLossYear_SC1_rc[HansenLossYear_SC1_rc > 2014] <- NA
HansenLossYear_SQ9_rc[HansenLossYear_SQ9_rc > 2014] <- NA

HansenLossYear_SC1_rc_upTo2015 <- HansenLossYear_SC1_rc
HansenLossYear_SC1_rc_upTo2015[HansenLossYear_SC1_rc_upTo2015 > 2015] <- NA

# Save to disk
writeRaster(HansenLossYear_DG1_rc, str_c(hansen.dir, "/recoded/HansenLoss_DG1.tif"))
writeRaster(HansenLossYear_DG2_rc, str_c(hansen.dir, "/recoded/HansenLoss_DG2.tif"))
writeRaster(HansenLossYear_SC1_rc, str_c(hansen.dir, "/recoded/HansenLoss_SC1.tif"))
writeRaster(HansenLossYear_SC1_rc_upTo2015, str_c(hansen.dir, "/recoded/HansenLoss_SC1_upTo2015.tif"))
writeRaster(HansenLossYear_SQ9_rc, str_c(hansen.dir, "/recoded/HansenLoss_SQ9.tif"))


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
# Project reference pixels to WGS84 which is the CRS of Hansen's product --------
#*****************************************************************************
refPixels.DG1 <- spTransform(refPixels.DG1, CRS("+proj=longlat +datum=WGS84"))
refPixels.DG2 <- spTransform(refPixels.DG2, CRS("+proj=longlat +datum=WGS84"))
refPixels.SC1 <- spTransform(refPixels.SC1, CRS("+proj=longlat +datum=WGS84"))
refPixels.SQ9 <- spTransform(refPixels.SQ9, CRS("+proj=longlat +datum=WGS84"))
refPixels.SQ11 <- spTransform(refPixels.SQ11, CRS("+proj=longlat +datum=WGS84"))
refPixels.SQ13 <- spTransform(refPixels.SQ13, CRS("+proj=longlat +datum=WGS84"))


#*****************************************************************************
# Extract loss ------------------------------------------------------------
#*****************************************************************************
extr.loss.DG1 <- raster::extract(HansenLoss_DG1, coordinates(refPixels.DG1), method = "simple", df = TRUE)
extr.loss.DG1$Id <- as.character(refPixels.DG1$Id)
colnames(extr.loss.DG1)[2] <- "HansenLoss"

extr.loss.DG2 <- raster::extract(HansenLoss_DG2, coordinates(refPixels.DG2), method = "simple", df = TRUE)
extr.loss.DG2$Id <- as.character(refPixels.DG2$Id)
colnames(extr.loss.DG2)[2] <- "HansenLoss"

extr.loss.SC1 <- raster::extract(HansenLoss_SC1, coordinates(refPixels.SC1), method = "simple", df = TRUE)
extr.loss.SC1$Id <- as.character(refPixels.SC1$Id)
colnames(extr.loss.SC1)[2] <- "HansenLoss"

extr.loss.SQ9 <- raster::extract(HansenLoss_SQ9, coordinates(refPixels.SQ9), method = "simple", df = TRUE)
extr.loss.SQ9$Id <- as.character(refPixels.SQ9$Id)
colnames(extr.loss.SQ9)[2] <- "HansenLoss"

extr.loss.SQ11 <- raster::extract(HansenLoss_SQ11, coordinates(refPixels.SQ11), method = "simple", df = TRUE)
extr.loss.SQ11$Id <- as.character(refPixels.SQ11$Id)
colnames(extr.loss.SQ11)[2] <- "HansenLoss"

extr.loss.SQ13 <- raster::extract(HansenLoss_SQ13, coordinates(refPixels.SQ13), method = "simple", df = TRUE)
extr.loss.SQ13$Id <- as.character(refPixels.SQ13$Id)
colnames(extr.loss.SQ13)[2] <- "HansenLoss"

# RBIND loss
extr.loss.ALL <- rbind(extr.loss.DG1,
                       extr.loss.DG2,
                       extr.loss.SQ9,
                       extr.loss.SQ11,
                       extr.loss.SQ13,
                       extr.loss.SC1)


#*****************************************************************************
# Extract loss year ------------------------------------------------------------
#*****************************************************************************
extr.lossYear.DG1 <- raster::extract(HansenLossYear_DG1, coordinates(refPixels.DG1), method = "simple", df = TRUE)
extr.lossYear.DG1$Id <- as.character(refPixels.DG1$Id)
colnames(extr.lossYear.DG1)[2] <- "HansenLossYear"


extr.lossYear.DG2 <- raster::extract(HansenLossYear_DG2, coordinates(refPixels.DG2), method = "simple", df = TRUE)
extr.lossYear.DG2$Id <- as.character(refPixels.DG2$Id)
colnames(extr.lossYear.DG2)[2] <- "HansenLossYear"


extr.lossYear.SC1 <- raster::extract(HansenLossYear_SC1, coordinates(refPixels.SC1), method = "simple", df = TRUE)
extr.lossYear.SC1$Id <- as.character(refPixels.SC1$Id)
colnames(extr.lossYear.SC1)[2] <- "HansenLossYear"


extr.lossYear.SQ9 <- raster::extract(HansenLossYear_SQ9, coordinates(refPixels.SQ9), method = "simple", df = TRUE)
extr.lossYear.SQ9$Id <- as.character(refPixels.SQ9$Id)
colnames(extr.lossYear.SQ9)[2] <- "HansenLossYear"


extr.lossYear.SQ11 <- raster::extract(HansenLossYear_SQ11, coordinates(refPixels.SQ11), method = "simple", df = TRUE)
extr.lossYear.SQ11$Id <- as.character(refPixels.SQ11$Id)
colnames(extr.lossYear.SQ11)[2] <- "HansenLossYear"


extr.lossYear.SQ13 <- raster::extract(HansenLossYear_SQ13, coordinates(refPixels.SQ13), method = "simple", df = TRUE)
extr.lossYear.SQ13$Id <- as.character(refPixels.SQ13$Id)
colnames(extr.lossYear.SQ13)[2] <- "HansenLossYear"


# RBIND loss year
extr.lossYear.ALL <- rbind(extr.lossYear.DG1,
                       extr.lossYear.DG2,
                       extr.lossYear.SQ9,
                       extr.lossYear.SQ11,
                       extr.lossYear.SQ13,
                       extr.lossYear.SC1)


#*****************************************************************************
# My change detection result ------------------------------------------------------------
# I NEED TO RE-RUN THE ALGORITHM WITH THE TS UP TO THE END OF THE YEAR?
# OR, FOR WALL-TO-WALL, WE DON'T NEED TO LIMIT THE END DATE! SO COMPARE WALL-TO-WALL UNTIL THE END OF THE YEAR!
# BUT THEN WE DON'T KNOW WHICH ONE IS MORE ACCURATE!
# OR WE FRAME IT LIKE "COMPARED WITH HANSEN'S ANNUAL CHANGE MAP, OUR MAP AGREES QUITE WELL ON THE YEARLY ASSESSMENT, 
# "BUT IT HAS THE BENEFIT OF SUB-ANNUAL POSSIBILITY"
# DECISION: SO IN RESPONSE LETTER, WE SHOW THE ERROR MATRIX, BUT WE SAY WE DON'T INCLUDE IT IN 
# THE PAPER BECAUSE THEY ARE NOT DIRECTLY COMPARABLE DUE TO THAT THE REFERENCE DATE IS NOT UNTIL THE END OF YEAR.
# IN THE PAPER WE COMPARE THE WALL-TO-WALL MAP. HOWEVER NOTE THE HANSEN'S MAP IS FOR CHANGE UP TO THE END OF YEAR,
# WHILE OUR MAP IS FOR CHANGE UP TO THE VHSR LATEST DATE.
# THEN TOO MANY FIGURES. DELETE THE SMALL CLEARING CASE!! 

# **FOR ERROR MATRIX, USE HANSEN'S CHANGE UNTIL THE YEAR BEFORE THE LATEST VHSR YEAR, WHILE
# USE REFERENCE SAMPLES WITH REF CHANGE DATE BEFORE THE YEAR OF THE LATEST VHSR

# **CAN COMPARE WITH GLAD, USE REFERENCE SAMPLE DATA WITH REF CHANGE DATE IN 2015, 2016, AND 2017
# SO WE CAN ASSESS BOTH SPATIAL AND TEMPORAL ACCURACY

# **FOR MAP, COMPARE RESULTS FOR UNTIL THE END OF VHSR YEAR


# SO TO DO TODAY:
# (1) MAKE MAP COMPARISON, RESULTS FOR UNTIL THE END OF VHSR YEAR (need arcmap!)

# (2)* ERROR MATRIX BETWEEN HANSEN'S ANNUAL CHANGE AND REFERENCE DATA, FOR REF DATA WITH REF CHANGE UP TO THE YEAR BEFORE THE LATEST VHSR YEAR
# (3) ERROR MATRIX BETWEEN MY ALGORITHM AND REFERENCE DATA, FOR REF DATA WITH REF CHANGE UP TO THE YEAR BEFORE THE LATEST VHSR YEAR, TO COMPARE WITH HANSEN
# (4) ERROR MATRIX BETWEEN MY ALGORITHM AND HANSEN'S MAP, FOR REF DATA WITH REF CHANGE UP TO THE YEAR BEFORE THE LATEST VHSR YEAR, TO COMPARE WITH HANSEN


# (4) DOWNLOAD GLAD DATA FOR 2015. CREATE ERROR MATRIX, ASSESS SPATIAL AND TEMPORAL ACCURACY WITH REF DATA WITH REF CHANGE DATE IN 2015




#*****************************************************************************
myAlgoResult <- read_rds(str_c(path, "/accuracy_results/accuracy_run27_all_df.rds"))   # which experiment run? ***

# Re-run algorithm with time series up to the year before latest VHSR, to compare with Hansen, againt reference data
myAlgoResult <- read_rds(str_c(path, "/accuracy_results/accuracy_run27_upToBeforeLatestVHSRYear_upToBeforeLatestVHSRYear_all_df.rds"))



#*****************************************************************************
# Merge myAlgoResult with Hansen's product --------------------------------
#*****************************************************************************
myAlgoResult <- as_tibble(myAlgoResult)
extr.loss.ALL <- as_tibble(extr.loss.ALL)
extr.lossYear.ALL <- as_tibble(extr.lossYear.ALL)

# Add loss
# myAlgoResultnHansen <- left_join(myAlgoResult, extr.loss.ALL, by = "Id")
# Rough solution for now, it's ok cause the Id is identical

myAlgoResultnHansen <- myAlgoResult

myAlgoResultnHansen$HansenLoss <- extr.loss.ALL$HansenLoss

# Add loss year
# myAlgoResultnHansen <- left_join(myAlgoResultnHansen, extr.lossYear.ALL, by = "Id")
myAlgoResultnHansen$HansenLossYear <- extr.lossYear.ALL$HansenLossYear

#*****************************************************************************
# Set NA hansen loss values which have loss year values after the latest VHSR scene --------
#*****************************************************************************
# Make loss year into year values
myAlgoResultnHansen <- myAlgoResultnHansen %>% 
  mutate(HansenLossYear = replace(HansenLossYear, HansenLossYear == 0, NA),
         HansenLossYear = HansenLossYear + 2000)


# Add year of reference date
myAlgoResultnHansen <- myAlgoResultnHansen %>% 
  mutate(ref.year = year(ref.date))

# Hansen loss 1 -> 0 if loss year > latest VHSR year
# ref.lastDate <- list(DG1 = as.Date("2015-08-15"), DG2 = as.Date("2015-08-08"),
#                      SQ9 = as.Date("2014-05-13"), SQ10 = as.Date("2015-08-17"),
#                      SQ11 = as.Date("2014-02-04"), SQ13 = as.Date("2014-05-13"),
#                      SC1 = as.Date("2014-02-04"))

myAlgoResultnHansen <- myAlgoResultnHansen %>% 
  mutate(latestVHSRyear = case_when(Scene == "DG1" ~ 2015,
                                    Scene == "DG2" ~ 2015,
                                    Scene == "SC1" ~ 2014,
                                    Scene == "SQ9" ~ 2014,
                                    Scene == "SQ11" ~ 2014,
                                    Scene == "SQ13" ~ 2014))


myAlgoResultnHansen <- myAlgoResultnHansen %>% 
  mutate(HansenLossUpToVHSR = HansenLoss,
         HansenLossUpToVHSR = if_else(HansenLossUpToVHSR == 1 & HansenLossYear > latestVHSRyear, 
                                      0,
                                      HansenLossUpToVHSR))

# Up to the year before latest VHSR year
myAlgoResultnHansen <- myAlgoResultnHansen %>% 
  mutate(HansenLossUpToBeforeVHSR = HansenLoss,
         HansenLossUpToBeforeVHSR = if_else(HansenLossUpToBeforeVHSR == 1 & HansenLossYear >= latestVHSRyear, 
                                      0,
                                      HansenLossUpToBeforeVHSR))

#*****************************************************************************
# Error matrix between reference and Hansen's product --------------------------------
#*****************************************************************************
# Up to latest VHSR year
# ref <- myAlgoResultnHansen$ref.detection
# HansenPred <- myAlgoResultnHansen$HansenLossUpToVHSR
# predNotBeforeRefYear <- myAlgoResultnHansen$HansenLossYear >= myAlgoResultnHansen$ref.year
# 
# calc_spatial_accuracy(ref = ref, pred = HansenPred, predNotBeforeRefYear)

# Up to the year before latest VHSR year
# Reference data with ref change up to before latest VHSR year
# Check
myAlgoResultnHansen %>% dplyr::select(ref.date, ref.year, latestVHSRyear) %>%  
  mutate(change.before.latestVHSR = ref.year < latestVHSRyear) %>% View()
# Aha, need to keep reference samples with no change too
temp <- myAlgoResultnHansen %>% 
  dplyr::filter((ref.year < latestVHSRyear) | ref.detection == 0)    # *****************************
# 399 samples

ref <- temp$ref.detection
HansenPred <- temp$HansenLossUpToBeforeVHSR  
predNotBeforeRefYear <- temp$HansenLossYear >= temp$ref.year

calc_spatial_accuracy(ref = ref, pred = HansenPred, predNotBeforeRefYear)



#*****************************************************************************
# Error matrix between reference and my algorithm --------------------------------
#*****************************************************************************
# All samples as before
ref <- myAlgoResultnHansen$ref.detection
myAlgoPred <- myAlgoResultnHansen$bfm.detection
predNotBeforeRef <- myAlgoResultnHansen$bfm.date.confirmed >= myAlgoResultnHansen$ref.date

calc_spatial_accuracy(ref = ref, pred = myAlgoPred, predNotBeforeRef)

# Ref samples with change up to the year before latest VHSR
myAlgoResultnHansen %>% dplyr::select(ref.date, ref.year, latestVHSRyear) %>%  
  mutate(change.before.latestVHSR = ref.year < latestVHSRyear) %>% View()
# Aha, need to keep reference samples with no change too
temp <- myAlgoResultnHansen %>% 
  dplyr::filter((ref.year < latestVHSRyear) | ref.detection == 0)    # *****************************
# 399 samples

ref <- temp$ref.detection
myAlgoPred <- temp$bfm.detection
predNotBeforeRef <- temp$bfm.date.confirmed >= temp$ref.date

calc_spatial_accuracy(ref = ref, pred = myAlgoPred, predNotBeforeRef)




#*****************************************************************************
# Error matrix between my algo and Hansen's product --------------------------------
# Up to the year before the latest VHSR year
#*****************************************************************************
# Ref samples with change up to the year before latest VHSR
myAlgoResultnHansen %>% dplyr::select(ref.date, ref.year, latestVHSRyear) %>%  
  mutate(change.before.latestVHSR = ref.year < latestVHSRyear) %>% View()
# Aha, need to keep reference samples with no change too
temp <- myAlgoResultnHansen %>% 
  dplyr::filter((ref.year < latestVHSRyear) | ref.detection == 0)    # *****************************
# 399 samples

Hansen <- temp$HansenLossUpToBeforeVHSR
myAlgoPred <- temp$bfm.detection
predNotBeforeRef <- temp$bfm.date.confirmed >= temp$ref.date

calc_spatial_accuracy(ref = Hansen, pred = myAlgoPred, predNotBeforeRef)







