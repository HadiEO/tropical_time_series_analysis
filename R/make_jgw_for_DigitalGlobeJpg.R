## This script iterates through JPG files in a folder, make .jgw files and write lines in it
## .jgw is the worldfile for JPG files
## Test data is in folder sample_data/data1/

# Function to make .jgw files with same filename as .jpg in a folder
makeJGW <- function(folder) {
  jpgs <- as.list(list.files(folder, pattern = glob2rx('*.jpg')))
  
  jpgs.cutExt <- lapply(jpgs, FUN = function(jpg) str_split(jpg, "\\.")[[1]][1])
  
  lapply(jpgs.cutExt, FUN = function(jpg.cutExt) file.create(paste(folder, "/", jpg.cutExt, ".jgw", sep = "")))    # By default, this overwrites
}



selectDG.dbf <- read_csv(paste(path, "/sample_data/data1/dg_CountPlusRange_more17.csv", sep = ""))   # List selected jpg filenames with longest data period and most no. of images
selectDG.dbf <- selectDG.dbf[!is.na(selectDG.dbf$SceneName),]                      # There is NA
bestDG.interesting <- selectDG.dbf


# Function to write lines in existing .jgw files (this works for "group" i.e. sampling mode 110 per Christoph instruction. All JPGs are group 110)
# It calls the following function to write lines
writeLinesInJGW <- function(jgw, jgw.full) {
  x.wgs <- bestDG.interesting[str_detect(jgw, bestDG.interesting$SceneName), "X"]
  y.wgs <- bestDG.interesting[str_detect(jgw, bestDG.interesting$SceneName), "Y"]
  line5 <- as.character(round(x.wgs - 0.01/2 + 4.882813e-06/2, 3))
  line6 <- as.character(round(y.wgs + 0.01/2 - 4.882813e-06/2, 3))
  
  fileConn <- file(jgw.full)
  writeLines(c("4.882813e-06","0","0","-4.882813e-06",line5,line6), fileConn)                 # By default, this overwrites
  close(fileConn)
  
  out <- "OK"
  return(out)
}


writeJGW <- function(folder) {
  jgws.full <- as.list(list.files(folder, pattern = glob2rx('*.jgw'), full.names = TRUE))
  jgws <- as.list(list.files(folder, pattern = glob2rx('*.jgw'), full.names = FALSE))
  
  out <- mapply(writeLinesInJGW, jgw = jgws, jgw.full = jgws.full)                                 
  return(out)
}

# IMPORTANT!! Need to define projection of the JPG files as WGS84 e.g. in arcmap 

# Now do for all folders: (1) Create JGW files (2) Write lines in it -------
# Run the following for your available .jpg
# JGW.folders are folders where the JPG files are stored, one folder for one scene center (can be many dates)
# JGW.folders <- as.list(list.files("sample_data/data1", full.names = TRUE)[-16])
# lapply(JGW.folders, FUN = makeJGW)              
# lapply(JGW.folders, FUN = writeJGW) 


# Do for the newly added small clearing folder
JGW.folders <- paste(path, "/digital_globe/SC_1", sep = "")
lapply(JGW.folders, FUN = makeJGW)
lapply(JGW.folders, FUN = writeJGW)

