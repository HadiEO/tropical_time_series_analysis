# ****************************************************************************
# Spatial accuracy (count-based/sample-based) ---------------------------------------------------
# ****************************************************************************

# which experiment run? ***************
all.bfmFlag <- read_rds(str_c(path, "/accuracy_results/accuracy_run37_all_df.rds"))   # which experiment run? ***
ref <- all.bfmFlag$ref.detection

# *******************************************************************************
# (1) pred = bfm.detection
# *******************************************************************************
# calc_spatial_accuracy(ref = ref, 
#                       pred = all.bfmFlag$bfm.detection)

# *******************************************************************************
# (2) pred = bfm.detection.negMagn
# But, rather than excluding cases with positive change magnitude (which may happen due to )
# *******************************************************************************
# calc_spatial_accuracy(ref = ref, 
#                       pred = all.bfmFlag$bfm.detection.negMagn)

# *******************************************************************************
# (3) additional date criterion: 
# *******************************************************************************
predNotBeforeRef <- all.bfmFlag$bfm.date.confirmed >= all.bfmFlag$ref.date 

calc_spatial_accuracy(ref = ref, 
                      pred = all.bfmFlag$bfm.detection,
                      predNotBeforeRef = predNotBeforeRef)


# Check the pixels which predNotBeforeRef == FALSE
# temp <- all.bfmFlag %>% select(Id, Scene, ref.detection, bfm.detection,
#                        ref.date, ref.date.adj, bfm.date.confirmed) %>%
#   mutate(lag.adj = bfm.date.confirmed - ref.date.adj,
#          predNotBeforeRef = bfm.date.confirmed >= ref.date.adj)
#   
# 
# temp %>% filter(lag.adj < 0)
# 
# vioplot(temp$lag.adj, na.rm = TRUE)

