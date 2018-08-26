# How to make pallete for panchromatic jpg
# Make a function
makeClrFromGreyJpg <- function(greyJpg, outName) {
  greyJpgLevels <- length(unique(greyJpg))
  greyPal <- gray.colors(n = greyJpgLevels, start = 0, end = 1)
  greyPalRgb <- t(col2rgb(greyPal))                              # Shape into tall data with column of R, G, B values
  greyPalRgb <- cbind(0:(nrow(greyPalRgb)-1), greyPalRgb)        # Add a column in the beginning so the app can work
  write.table(greyPalRgb,
              file = outName,
              sep = " ", col.names = FALSE, row.names = FALSE)
}


# 1
greyJpg.DG1 <- raster(str_c("C:/LocalUserData/User-data/hadi1/PHD_RESEARCH/STUDY_IIASA/bfast_hadi_yssp_data",
                            "/digital_globe/FINALLY_USED/DG_1/77ff77b3-172f-cb3f-44c2-be8a48df72c8_110_0_20101113_025422_copyRaster.tif"))
outName.DG1 <- str_c("C:/LocalUserData/User-data/hadi1/PHD_RESEARCH/STUDY_IIASA/bfast_hadi_yssp_data",
                     "/digital_globe/FINALLY_USED/DG_1/77ff77b3-172f-cb3f-44c2-be8a48df72c8_110_0_20101113_025422_copyRaster.tif.clr")
makeClrFromGreyJpg(greyJpg.DG1,  outName.DG1)


# 2
greyJpg.SQ9 <- raster(str_c("C:/LocalUserData/User-data/hadi1/PHD_RESEARCH/STUDY_IIASA/bfast_hadi_yssp_data",
                            "/digital_globe/FINALLY_USED/SQ_9/8c831997-77f9-6794-9cf2-f250a0c19158_110_0_20090520_032112_copyRaster.tif"))
outName.SQ9 <- str_c("C:/LocalUserData/User-data/hadi1/PHD_RESEARCH/STUDY_IIASA/bfast_hadi_yssp_data",
                     "/digital_globe/FINALLY_USED/SQ_9/8c831997-77f9-6794-9cf2-f250a0c19158_110_0_20090520_032112_copyRaster.tif.clr")
makeClrFromGreyJpg(greyJpg.SQ9,  outName.SQ9)