# DG1
extr.red.sub.DG1 <- read_rds(str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_red_sub_DG1.rds"))
extr.nir.sub.DG1 <- read_rds(str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_nir_sub_DG1.rds"))
extr.swir1.sub.DG1 <- read_rds(str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_swir1_sub_DG1.rds"))

extr.ndmi.sub.DG1 <- (extr.nir.sub.DG1 - extr.swir1.sub.DG1) / (extr.nir.sub.DG1 + extr.swir1.sub.DG1)
write_rds(extr.ndmi.sub.DG1, str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_ndmi_sub_DG1.rds"))

extr.ndvi.sub.DG1 <- (extr.nir.sub.DG1 - extr.red.sub.DG1) / (extr.nir.sub.DG1 + extr.red.sub.DG1)
write_rds(extr.ndvi.sub.DG1, str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_ndvi_sub_DG1.rds"))


# DG2
extr.red.sub.DG2 <- read_rds(str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_red_sub_DG2.rds"))
extr.nir.sub.DG2 <- read_rds(str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_nir_sub_DG2.rds"))
extr.swir1.sub.DG2 <- read_rds(str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_swir1_sub_DG2.rds"))

extr.ndmi.sub.DG2 <- (extr.nir.sub.DG2 - extr.swir1.sub.DG2) / (extr.nir.sub.DG2 + extr.swir1.sub.DG2)
write_rds(extr.ndmi.sub.DG2, str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_ndmi_sub_DG2.rds"))

extr.ndvi.sub.DG2 <- (extr.nir.sub.DG2 - extr.red.sub.DG2) / (extr.nir.sub.DG2 + extr.red.sub.DG2)
write_rds(extr.ndvi.sub.DG2, str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_ndvi_sub_DG2.rds"))


# SC1
extr.red.sub.SC1 <- read_rds(str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_red_sub_SC1.rds"))
extr.nir.sub.SC1 <- read_rds(str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_nir_sub_SC1.rds"))
extr.swir1.sub.SC1 <- read_rds(str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_swir1_sub_SC1.rds"))

extr.ndmi.sub.SC1 <- (extr.nir.sub.SC1 - extr.swir1.sub.SC1) / (extr.nir.sub.SC1 + extr.swir1.sub.SC1)
write_rds(extr.ndmi.sub.SC1, str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_ndmi_sub_SC1.rds"))

extr.ndvi.sub.SC1 <- (extr.nir.sub.SC1 - extr.red.sub.SC1) / (extr.nir.sub.SC1 + extr.red.sub.SC1)
write_rds(extr.ndvi.sub.SC1, str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_ndvi_sub_SC1.rds"))


# SQ13
extr.red.sub.SQ13 <- read_rds(str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_red_sub_SQ13.rds"))
extr.nir.sub.SQ13 <- read_rds(str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_nir_sub_SQ13.rds"))
extr.swir1.sub.SQ13 <- read_rds(str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_swir1_sub_SQ13.rds"))

extr.ndmi.sub.SQ13 <- (extr.nir.sub.SQ13 - extr.swir1.sub.SQ13) / (extr.nir.sub.SQ13 + extr.swir1.sub.SQ13)
write_rds(extr.ndmi.sub.SQ13, str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_ndmi_sub_SQ13.rds"))

extr.ndvi.sub.SQ13 <- (extr.nir.sub.SQ13 - extr.red.sub.SQ13) / (extr.nir.sub.SQ13 + extr.red.sub.SQ13)
write_rds(extr.ndvi.sub.SQ13, str_c(path, "/extracted_time_series/FINALLY_USED_SINGLEBAND/extr_ndvi_sub_SQ13.rds"))
