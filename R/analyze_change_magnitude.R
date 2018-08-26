# *************************************************************************
# LAST ATTEMPT TO IMPROVE CHANGE DETECTION:
# If residual is say < 2*histRMSE, require more consecutive occurence
# If residual is say > 3*histRMSE, require fewer consecutive occurence e.g. 1 for immediate detection
# *************************************************************************

# How much histRMSE?
# Check the *values* of false alarm ("old_flag") vs. confirmed change
# *values* can be:
# (a) obs - pred = process_upd 
# (b) (obs - pred) / histRMSE
# (c) (obs - pred) / pred


# *************************************************************************
# False alarm = old flag --------------------------------------------------
# *************************************************************************
# names(oldFlag.DG1)   # "bfm.obs.oldFlag.ls"   "bfm.pred.oldFlag.ls"  "bfm.resid.oldFlag.ls" "bfm.residDivHistRMSE.oldFlag.ls"
prepOldFlagValues <- function(oldFlagOutName) {                   # which experiment run? ****
  oldFlag.DG1 <- read_rds(str_c(oldFlagOutName, "_DG1.rds"))
  oldFlag.DG2 <- read_rds(str_c(oldFlagOutName, "_DG2.rds"))
  oldFlag.SC1 <- read_rds(str_c(oldFlagOutName, "_SC1.rds"))
  oldFlag.SQ9 <- read_rds(str_c(oldFlagOutName, "_SQ9.rds"))
  oldFlag.SQ11 <- read_rds(str_c(oldFlagOutName, "_SQ11.rds"))
  oldFlag.SQ13 <- read_rds(str_c(oldFlagOutName, "_SQ13.rds"))
  
  # obs
  value <- "bfm.obs.oldFlag.ls"
  oldFlag.all.obs <- c(unlist(oldFlag.DG1[[value]]), 
                       unlist(oldFlag.DG2[[value]]),
                       unlist(oldFlag.SC1[[value]]),
                       unlist(oldFlag.SQ9[[value]]),
                       unlist(oldFlag.SQ11[[value]]),
                       unlist(oldFlag.SQ13[[value]]))
  
  # residual = obs - pred
  value <- "bfm.resid.oldFlag.ls"
  oldFlag.all.resid <- c(unlist(oldFlag.DG1[[value]]), 
                         unlist(oldFlag.DG2[[value]]),
                         unlist(oldFlag.SC1[[value]]),
                         unlist(oldFlag.SQ9[[value]]),
                         unlist(oldFlag.SQ11[[value]]),
                         unlist(oldFlag.SQ13[[value]]))
  
  # residual = obs - pred
  value <- "bfm.residDivHistRMSE.oldFlag.ls"
  oldFlag.all.residDivHistRMSE <- c(unlist(oldFlag.DG1[[value]]), 
                         unlist(oldFlag.DG2[[value]]),
                         unlist(oldFlag.SC1[[value]]),
                         unlist(oldFlag.SQ9[[value]]),
                         unlist(oldFlag.SQ11[[value]]),
                         unlist(oldFlag.SQ13[[value]]))
  
  out <- list(oldFlag.all.obs = oldFlag.all.obs, 
              oldFlag.all.resid = oldFlag.all.resid,
              oldFlag.all.residDivHistRMSE = oldFlag.all.residDivHistRMSE)
}


oldFlagValues <- prepOldFlagValues(oldFlagOutName = str_c(path, "/bfm_results/oldFlag_bfm_run27")) 


# x11()
# par(mfrow = c(1, 2))
# hist(oldFlagValues$oldFlag.all.resid)

# *************************************************************************
# Confirmed change =  --------------------------------------------------
# *************************************************************************
# Which to check?
# - magnitude (median of consecutive window). Nice can also compare with magnitude of no-change case
# - value at breakpoint_firstFlagged
# - value at breakpoint (confirmed)
# - all values from breakpoint_firstFlagged to breakpoint (confirmed)

# ***************************************************************************
# First, compare magnitude (bfm.magn) of change and no-change cases, for correct detection case (true positives and true negatives)
all.bfmFlag <- read_rds(str_c(path, "/accuracy_results/accuracy_run27_all_df.rds"))   # which experiment run? ***

# In terms of histRMSE
all.bfmFlag <- all.bfmFlag %>% 
  mutate(bfm.magn.div.histRMSE = bfm.magn / bfm.histRMSE,
         bfm.resid.firstFlagged.div.histRMSE = bfm.resid.firstFlagged / bfm.histRMSE)

# Rows of True Positives & confirmed date NOT before reference date
all.bfmFlag.TP <- all.bfmFlag %>% 
  filter(bfm.detection == 1 & ref.detection == 1)
all.bfmFlag.TP.bfmDateAfterRef <- all.bfmFlag.TP %>% 
  filter(bfm.date.confirmed >= ref.date)
NROW(all.bfmFlag.TP.bfmDateAfterRef)

# Rows of True Negatives
all.bfmFlag.TN <- all.bfmFlag %>% 
  filter(bfm.detection == 0 & ref.detection == 0)
NROW(all.bfmFlag.TN)

# For sake of completion
# Rows of False Positives [can be very few samples]
all.bfmFlag.FP <- all.bfmFlag %>% 
  filter(bfm.detection == 1 & ref.detection == 0)

# Need to consider also the True Positive but detected earlier than reference
all.bfmFlag.TP.bfmDateBeforeRef <- all.bfmFlag.TP %>%
  filter(bfm.date.confirmed < ref.date)
# This is treated as False Positives
all.bfmFlag.FP <- bind_rows(all.bfmFlag.FP, all.bfmFlag.TP.bfmDateBeforeRef)




# Rows of False Negatives [can be more than FP]
all.bfmFlag.FN <- all.bfmFlag %>% 
  filter(bfm.detection == 0 & ref.detection == 1)


# ***************************************************************************
# What about histRMSE
# boxplot(all.bfmFlag$bfm.histRMSE) 

# Boxplot together
temp.ndmi <- list(abs.magn.TP = abs(all.bfmFlag.TP.bfmDateAfterRef$bfm.magn),
             abs.magn.TN = abs(all.bfmFlag.TN$bfm.magn),
             abs.magn.FP = abs(all.bfmFlag.FP$bfm.magn),
             abs.magn.FN = abs(all.bfmFlag.FN$bfm.magn),
             abs.resid.oldFlag = abs(oldFlagValues$oldFlag.all.resid),
             abs.resid.firstFlagged = abs(all.bfmFlag.TP.bfmDateAfterRef$bfm.resid.firstFlagged),
             histRMSE = all.bfmFlag$bfm.histRMSE,
             four.histRMSE = 4 * all.bfmFlag$bfm.histRMSE)

temp.ndmi.melt <- reshape2::melt(temp.ndmi)
colnames(temp.ndmi.melt) <- c("value", "variable")
temp.ndmi.melt$variable <- factor(temp.ndmi.melt$variable,
                                  levels = c("abs.magn.FP", 
                                             "abs.resid.oldFlag",
                                             "abs.magn.TP",
                                             "abs.resid.firstFlagged",
                                             "abs.magn.FN",
                                             "abs.magn.TN",
                                             "histRMSE",
                                             "four.histRMSE"), ordered = TRUE)



# In terms of histRMSE
temp.rmse <- list(abs.magn.TP = abs(all.bfmFlag.TP.bfmDateAfterRef$bfm.magn.div.histRMSE),   
             abs.magn.TN = abs(all.bfmFlag.TN$bfm.magn.div.histRMSE),
             abs.magn.FP = abs(all.bfmFlag.FP$bfm.magn.div.histRMSE),
             abs.magn.FN = abs(all.bfmFlag.FN$bfm.magn.div.histRMSE),
             abs.resid.firstFlagged = abs(all.bfmFlag.TP.bfmDateAfterRef$bfm.resid.firstFlagged.div.histRMSE),
             abs.resid.oldFlag = abs(oldFlagValues$oldFlag.all.residDivHistRMSE))
             

temp.rmse.melt <- reshape2::melt(temp.rmse)
colnames(temp.rmse.melt) <- c("value", "variable")
temp.rmse.melt$variable <- factor(temp.rmse.melt$variable,
                             levels = c("abs.magn.FP", 
                                        "abs.resid.oldFlag",
                                        "abs.magn.TP",
                                        "abs.resid.firstFlagged",
                                        "abs.magn.FN",
                                        "abs.magn.TN"), ordered = TRUE)




# Plot in terms of NDMI [boxplot]
plot.magn.ndmi <- ggplot(temp.ndmi.melt, aes(x = variable, y = value)) +
  geom_boxplot(lwd = 0.4, outlier.size = 0.8) +  # color = "black", fill = "white"
  theme_bw() +
  scale_y_continuous(breaks = seq(0,1,0.1)) +
  ylab(expression("|magnitude|, "~RMSE[history])) +
  scale_x_discrete(labels = c("FP", "noise", "TP", "1st flagged", "FN", "TN", 
                              expression(RMSE[history]), expression("4*"~RMSE[history]~""))) +
  theme(axis.title.x = element_blank()) +
  theme(axis.text.x = element_text(angle = 45, vjust = 0.6)) +
  annotate("text", label = "(a)", x = 8, y = 0.85)  # +
  # annotate("text", label = "n = 12", x = 1, y = 0.1) +
  # annotate("text", label = "n = 707", x = 2, y = 0.08) +
  # annotate("text", label = "n = 207", x = 3, y = 0.12) +
  # annotate("text", label = "n = 207", x = 4, y = 0.12) +
  # annotate("text", label = "n = 15", x = 5, y = 0.11) +
  # annotate("text", label = "n = 201", x = 6, y = 0.14) +
  # annotate("text", label = "n = 435", x = 7, y = 0.14) +
  # annotate("text", label = "n = 435", x = 8, y = 0.45) 


# Plot in terms of NDMI [violin]
plot.magn.ndmi.violin <- ggplot(temp.ndmi.melt, aes(x = variable, y = value)) +
  geom_violin() + 
  theme_bw() +
  scale_y_continuous(breaks = seq(0,1,0.1)) +
  ylab(expression("|magnitude|, "~RMSE[history])) +
  scale_x_discrete(labels = c("FP", "noise", "TP", "1st flagged", "FN", "TN", 
                              expression(RMSE[history]), expression("4*"~RMSE[history]~""))) +
  theme(axis.title.x = element_blank()) +
  theme(axis.text.x = element_text(angle = 45, vjust = 0.6)) +
  annotate("text", label = "(a)", x = 8, y = 0.85) 

# Plot in terms of RMSE
plot.magn.rmse <- ggplot(temp.rmse.melt, aes(x = variable, y = value)) +
  geom_boxplot(lwd = 0.4, outlier.size = 0.8) + # color = "black", fill = "white"
  theme_bw() +
  scale_y_continuous(breaks = seq(0,30,2)) +
  ylab(expression("|magnitude| " / ~RMSE[history])) +
  scale_x_discrete(labels = c("FP", "noise", "TP", " 1st flagged    ", "FN", "TN")) +
  theme(axis.title.x = element_blank()) +
  theme(axis.text.x = element_text(angle = 45, vjust = 0.6)) +
  annotate("text", label = "(b)", x = 6.2, y = 26) # +
  # annotate("text", label = "n = 12", x = 1, y = 3.5) +
  # annotate("text", label = "n = 707", x = 2, y = 3.2) +
  # annotate("text", label = "n = 207", x = 3, y = 3.3) +
  # annotate("text", label = "n = 207", x = 4, y = 3.2) +
  # annotate("text", label = "n = 15", x = 5, y = 2) +
  # annotate("text", label = "n = 201", x = 6, y = 2.8) 

# Plot in terms of RMSE [violin]
plot.magn.rmse.violin <- ggplot(temp.rmse.melt, aes(x = variable, y = value)) +
  geom_violin() +
  theme_bw() +
  scale_y_continuous(breaks = seq(0,30,2)) +
  ylab(expression("|magnitude| " / ~RMSE[history])) +
  scale_x_discrete(labels = c("FP", "noise", "TP", " 1st flagged    ", "FN", "TN")) +
  theme(axis.title.x = element_blank()) +
  theme(axis.text.x = element_text(angle = 45, vjust = 0.6)) +
  annotate("text", label = "(b)", x = 6.2, y = 26)



pdf(str_c(final.fig.path, "change_magnitude_violin.pdf"), 
    width = 7.4, height = 3, pointsize = 12)
# multiplot(plot.magn.ndmi, plot.magn.rmse, cols = 2)
multiplot(plot.magn.ndmi.violin, plot.magn.rmse.violin, cols = 2)
dev.off()


