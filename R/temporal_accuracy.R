# ****************************************************************************
# Temporal accuracy (count-based/sample-based) ---------------------------------------------------
# ****************************************************************************

# which experiment run? ***************
all.bfmFlag <- read_rds(str_c(path, "/accuracy_results/accuracy_run37_all_df.rds"))   # which experiment run? ***

# Keep rows of True Positives
all.bfmFlag.TP <- all.bfmFlag %>% 
  filter(bfm.detection == 1 & ref.detection == 1)
NROW(all.bfmFlag.TP) 


# Lag between firstFlagged change and reference
# vs.
# Lag between confirmed change and reference
# lagFirstFlagged <- as.numeric(all.bfmFlag.TP$bfm.date.firstFlagged - all.bfmFlag.TP$ref.date.adj)
# lagConfirmed <- as.numeric(all.bfmFlag.TP$bfm.date.confirmed - all.bfmFlag.TP$ref.date.adj)
# x11()
# vioplot(lagFirstFlagged[!is.na(lagFirstFlagged)],
#         lagConfirmed[!is.na(lagConfirmed)],
#         names = c("lagFirstFlagged", "lagConfirmed"))



# Confirmed change date should be not before reference date 
all.bfmFlag.TP.bfmDateNotBeforeRef <- all.bfmFlag.TP %>% 
  # filter(bfm.date.confirmed >= ref.date.adj)
  filter(bfm.date.confirmed >= ref.date)
NROW(all.bfmFlag.TP.bfmDateNotBeforeRef) 

# Calculate the temporal lag
all.bfmFlag.TP.bfmDateNotBeforeRef <- all.bfmFlag.TP.bfmDateNotBeforeRef %>% 
  # mutate(lag.confirmed = bfm.date.confirmed - ref.date.adj,
  #        lag.firstFlagged = bfm.date.firstFlagged - ref.date.adj)
  mutate(lag.confirmed = bfm.date.confirmed - ref.date,
         lag.firstFlagged = bfm.date.firstFlagged - ref.date)

# hist(as.numeric(all.bfmFlag.TP.bfmDateNotBeforeRef$lag.confirmed))
# hist(as.numeric(all.bfmFlag.TP.bfmDateNotBeforeRef$lag.firstFlagged))   

# ******************************************************
# lag
# ******************************************************
median(all.bfmFlag.TP.bfmDateNotBeforeRef$lag.confirmed, na.rm = TRUE)
median(all.bfmFlag.TP.bfmDateNotBeforeRef$lag.firstFlagged, na.rm = TRUE)
# ******************************************************

# Lag between firstFlagged change and reference
# vs.
# Lag between confirmed change and reference
# x11()
# vioplot(all.bfmFlag.TP.bfmDateNotBeforeRef$lag.firstFlagged,
#         all.bfmFlag.TP.bfmDateNotBeforeRef$lag.confirmed,
#         names = c("lagFirstFlagged", "lagConfirmed"))

# temp <- list(lag.firstFlagged = all.bfmFlag.TP.bfmDateNotBeforeRef$lag.firstFlagged,
#              lag.confirmed = all.bfmFlag.TP.bfmDateNotBeforeRef$lag.confirmed)
# temp.melt <- reshape2::melt(temp)
# colnames(temp.melt) <- c("value", "variable")
# ggplot(temp.melt, aes(x = variable, y = value)) +
#   geom_boxplot(color = "black", fill = "gold") +
#   theme_bw() +
#   # scale_y_continuous(breaks = seq(0,20,2)) +
#   ggtitle("lag in days")


# ******************************************************
# Temporal accuracy as no. of observation ---------------------------------
# ******************************************************
# Difference between the obs no. of breakpoint and reference change date

# *********************************************************************
median(all.bfmFlag.TP.bfmDateNotBeforeRef$lag.obs.confirmed, na.rm = TRUE)
median(all.bfmFlag.TP.bfmDateNotBeforeRef$lag.obs.firstFlagged, na.rm = TRUE)
# **********************************************************************

# temp <- list(lag.firstFlagged = all.bfmFlag.TP.bfmDateNotBeforeRef$lag.obs.firstFlagged,
#              lag.confirmed = all.bfmFlag.TP.bfmDateNotBeforeRef$lag.obs.confirmed)
# temp.melt <- reshape2::melt(temp)
# colnames(temp.melt) <- c("value", "variable")
# ggplot(temp.melt, aes(x = variable, y = value)) +
#   geom_boxplot(color = "black", fill = "gold") +
#   theme_bw() +
#   # scale_y_continuous(breaks = seq(0,20,2)) +
#   ggtitle("lag in obs")








