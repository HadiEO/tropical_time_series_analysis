acc4plot <- 
  read_csv2("C:/LocalUserData/User-data/hadi1/PHD_RESEARCH/STUDY_IIASA/bfast_hadi_yssp_data/table/bfm_accuracy_summary_for_plot.csv")


# Plot spatial accuracy
plot.acc.spatial <- acc4plot %>% select(k, Cons, OA, UA, PA) %>%
  reshape2::melt(id.vars = c("k", "Cons")) %>% 
  ggplot(aes(x = k, y = value, col = variable)) +
  facet_grid(. ~ Cons, labeller = labeller(Cons = c("1" = "Cons = 1", "2" = "Cons = 2", "3" = "Cons = 3"))) +
  geom_line() + geom_point(size = 1.8) +
  scale_y_continuous(limits = c(0,100), minor_breaks = seq(0,100,10), breaks = seq(0,100,20)) +
  scale_x_continuous(breaks = seq(3,10,1), minor_breaks = seq(3,10,1)) +
  ylab("%") + xlab("") +   # xlab(expression(value~of~italic(k))) 
  scale_color_manual(values = c("magenta", "dodgerblue", "chartreuse4"), labels = c("OA   ", "UA   ", "PA   ")) +
  theme_bw() +
  theme(legend.position = c(0.5, 0.08), legend.title = element_blank(), legend.direction="horizontal",
        legend.background = element_rect(fill = "transparent"),
        legend.key = element_blank(),
        legend.text = element_text(size = 12),
        axis.title.x = element_blank()) +
  guides(color = guide_legend(override.aes = list(fill = NA))) 

# Plot temporal accuracy
plot.acc.temporal <- acc4plot %>% select(k, Cons, MTL_days) %>%
  reshape2::melt(id.vars = c("k", "Cons")) %>% 
  ggplot(aes(x = k, y = value, col = variable)) +
  facet_grid(. ~ Cons, labeller = labeller(Cons = c("1" = "Cons = 1", "2" = "Cons = 2", "3" = "Cons = 3"))) +
  geom_line(col = "dark orange") + geom_point(size = 1.8, col = "dark orange") +
  xlab(expression(value~of~italic(k))) +
  scale_x_continuous(breaks = seq(3,10,1), minor_breaks = seq(3,10,1)) +
  scale_y_continuous(name = "Days", 
                     limits = c(0,220)) + 
  theme_bw() +
  theme(legend.position = "none",
        strip.background = element_blank(),
        strip.text.x = element_blank(),
        # axis.text.y = element_text(size = 7.5),
        # axis.title.y = element_text(size = 11))
        axis.title.y = element_text(margin = margin(t = 0, r = 2.5, b = 0, l = 0)))





pdf(str_c(final.fig.path, "spatial_temporal_accuracy.pdf"), 
    width = 7.4, height = 5.5, pointsize = 12)
multiplot(plot.acc.spatial, plot.acc.temporal, cols = 1)
dev.off()




# Can't figure out to plot MTL (obs) on secondary y-axis
# acc4plot %>% mutate(MTL_obs = 10 * MTL_obs) %>% select(k, MTL_days, MTL_obs) %>%
#   reshape2::melt(id.vars = "k") %>% 
#   ggplot(aes(x = k, y = value, col = variable)) +
#   geom_line() + geom_point() +
#   scale_x_continuous(breaks = seq(3,10,1)) +
#   scale_y_continuous(name = "Days", 
#     sec.axis = sec_axis(~ . / 5 , name = "No. of observation"),
#     limits = c(0,250)) + 
#   theme_bw() 



# *****************************************************************************************
# Plot distribution of temporal lag
# ****************************************************************************************
# ****************************************************************************
# Temporal accuracy (count-based/sample-based) ---------------------------------------------------
# ****************************************************************************

saveTemporalLagDistribution <- function(all.bfmFlag) {
  # Keep rows of True Positives
  all.bfmFlag.TP <- all.bfmFlag %>% 
    filter(bfm.detection == 1 & ref.detection == 1)
  NROW(all.bfmFlag.TP) 
  
  # Confirmed change date should be not before reference date (with 45 days window considering uncertainty in reference date identified visually)
  all.bfmFlag.TP.bfmDateNotBeforeRef <- all.bfmFlag.TP %>% 
    filter(bfm.date.confirmed >= ref.date)
  NROW(all.bfmFlag.TP.bfmDateNotBeforeRef) 
  
  # Calculate the temporal lag
  all.bfmFlag.TP.bfmDateNotBeforeRef <- all.bfmFlag.TP.bfmDateNotBeforeRef %>% 
    mutate(lag.confirmed = bfm.date.confirmed - ref.date,
           lag.firstFlagged = bfm.date.firstFlagged - ref.date)
  
  # Keep just lag.confirmed for plotting
  out <- all.bfmFlag.TP.bfmDateNotBeforeRef[["lag.confirmed"]]
  return(out)
}

# which experiment run? ***************
# Cons = 1. Respetive runs for k = 3,4,...,10 are 22, 23, 10, 24, 25, 13, 26, 11
# Cons = 2. Respetive runs for k = 3,4,...,10 are 9, 17, 15, 18, 19, 20, 21, 16
# Cons = 3. Respetive runs for k = 3,4,...,10 are 7, 27, 28, 29, 30, 31, 32, 33

all.bfmFlag.cons1.k3 <- read_rds(str_c(path, "/accuracy_results/accuracy_run22_all_df.rds"))   
all.bfmFlag.cons1.k4 <- read_rds(str_c(path, "/accuracy_results/accuracy_run23_all_df.rds"))   
all.bfmFlag.cons1.k5 <- read_rds(str_c(path, "/accuracy_results/accuracy_run10_all_df.rds"))   
all.bfmFlag.cons1.k6 <- read_rds(str_c(path, "/accuracy_results/accuracy_run24_all_df.rds"))   
all.bfmFlag.cons1.k7 <- read_rds(str_c(path, "/accuracy_results/accuracy_run25_all_df.rds"))   
all.bfmFlag.cons1.k8 <- read_rds(str_c(path, "/accuracy_results/accuracy_run13_all_df.rds"))   
all.bfmFlag.cons1.k9 <- read_rds(str_c(path, "/accuracy_results/accuracy_run26_all_df.rds"))   
all.bfmFlag.cons1.k10 <- read_rds(str_c(path, "/accuracy_results/accuracy_run11_all_df.rds"))   

all.bfmFlag.cons2.k3 <- read_rds(str_c(path, "/accuracy_results/accuracy_run9_all_df.rds"))   
all.bfmFlag.cons2.k4 <- read_rds(str_c(path, "/accuracy_results/accuracy_run17_all_df.rds"))   
all.bfmFlag.cons2.k5 <- read_rds(str_c(path, "/accuracy_results/accuracy_run15_all_df.rds"))   
all.bfmFlag.cons2.k6 <- read_rds(str_c(path, "/accuracy_results/accuracy_run18_all_df.rds"))   
all.bfmFlag.cons2.k7 <- read_rds(str_c(path, "/accuracy_results/accuracy_run19_all_df.rds"))   
all.bfmFlag.cons2.k8 <- read_rds(str_c(path, "/accuracy_results/accuracy_run20_all_df.rds"))   
all.bfmFlag.cons2.k9 <- read_rds(str_c(path, "/accuracy_results/accuracy_run21_all_df.rds"))   
all.bfmFlag.cons2.k10 <- read_rds(str_c(path, "/accuracy_results/accuracy_run16_all_df.rds"))  

all.bfmFlag.cons3.k3 <- read_rds(str_c(path, "/accuracy_results/accuracy_run7_all_df.rds"))   
all.bfmFlag.cons3.k4 <- read_rds(str_c(path, "/accuracy_results/accuracy_run27_all_df.rds"))   
all.bfmFlag.cons3.k5 <- read_rds(str_c(path, "/accuracy_results/accuracy_run28_all_df.rds"))   
all.bfmFlag.cons3.k6 <- read_rds(str_c(path, "/accuracy_results/accuracy_run29_all_df.rds"))   
all.bfmFlag.cons3.k7 <- read_rds(str_c(path, "/accuracy_results/accuracy_run30_all_df.rds"))   
all.bfmFlag.cons3.k8 <- read_rds(str_c(path, "/accuracy_results/accuracy_run31_all_df.rds"))   
all.bfmFlag.cons3.k9 <- read_rds(str_c(path, "/accuracy_results/accuracy_run32_all_df.rds"))   
all.bfmFlag.cons3.k10 <- read_rds(str_c(path, "/accuracy_results/accuracy_run33_all_df.rds"))  



TLDist.cons1.k3 <- saveTemporalLagDistribution(all.bfmFlag.cons1.k3)
TLDist.cons1.k4 <- saveTemporalLagDistribution(all.bfmFlag.cons1.k4)
TLDist.cons1.k5 <- saveTemporalLagDistribution(all.bfmFlag.cons1.k5)
TLDist.cons1.k6 <- saveTemporalLagDistribution(all.bfmFlag.cons1.k6)
TLDist.cons1.k7 <- saveTemporalLagDistribution(all.bfmFlag.cons1.k7)
TLDist.cons1.k8 <- saveTemporalLagDistribution(all.bfmFlag.cons1.k8)
TLDist.cons1.k9 <- saveTemporalLagDistribution(all.bfmFlag.cons1.k9)
TLDist.cons1.k10 <- saveTemporalLagDistribution(all.bfmFlag.cons1.k10)


TLDist.cons2.k3 <- saveTemporalLagDistribution(all.bfmFlag.cons2.k3)
TLDist.cons2.k4 <- saveTemporalLagDistribution(all.bfmFlag.cons2.k4)
TLDist.cons2.k5 <- saveTemporalLagDistribution(all.bfmFlag.cons2.k5)
TLDist.cons2.k6 <- saveTemporalLagDistribution(all.bfmFlag.cons2.k6)
TLDist.cons2.k7 <- saveTemporalLagDistribution(all.bfmFlag.cons2.k7)
TLDist.cons2.k8 <- saveTemporalLagDistribution(all.bfmFlag.cons2.k8)
TLDist.cons2.k9 <- saveTemporalLagDistribution(all.bfmFlag.cons2.k9)
TLDist.cons2.k10 <- saveTemporalLagDistribution(all.bfmFlag.cons2.k10)


TLDist.cons3.k3 <- saveTemporalLagDistribution(all.bfmFlag.cons3.k3)
TLDist.cons3.k4 <- saveTemporalLagDistribution(all.bfmFlag.cons3.k4)
TLDist.cons3.k5 <- saveTemporalLagDistribution(all.bfmFlag.cons3.k5)
TLDist.cons3.k6 <- saveTemporalLagDistribution(all.bfmFlag.cons3.k6)
TLDist.cons3.k7 <- saveTemporalLagDistribution(all.bfmFlag.cons3.k7)
TLDist.cons3.k8 <- saveTemporalLagDistribution(all.bfmFlag.cons3.k8)
TLDist.cons3.k9 <- saveTemporalLagDistribution(all.bfmFlag.cons3.k9)
TLDist.cons3.k10 <- saveTemporalLagDistribution(all.bfmFlag.cons3.k10)



TLDist.cons1.ls <- list(k3 = TLDist.cons1.k3, 
                        k4 = TLDist.cons1.k4,
                        k5 = TLDist.cons1.k5,
                        k6 = TLDist.cons1.k6,
                        k7 = TLDist.cons1.k7,
                        k8 = TLDist.cons1.k8,
                        k9 = TLDist.cons1.k9,
                        k10 = TLDist.cons1.k10)

TLDist.cons2.ls <- list(k3 = TLDist.cons2.k3, 
                        k4 = TLDist.cons2.k4,
                        k5 = TLDist.cons2.k5,
                        k6 = TLDist.cons2.k6,
                        k7 = TLDist.cons2.k7,
                        k8 = TLDist.cons2.k8,
                        k9 = TLDist.cons2.k9,
                        k10 = TLDist.cons2.k10)

TLDist.cons3.ls <- list(k3 = TLDist.cons3.k3, 
                        k4 = TLDist.cons3.k4,
                        k5 = TLDist.cons3.k5,
                        k6 = TLDist.cons3.k6,
                        k7 = TLDist.cons3.k7,
                        k8 = TLDist.cons3.k8,
                        k9 = TLDist.cons3.k9,
                        k10 = TLDist.cons3.k10)




# Plot temporal accuracy: boxplot
TLDist.cons1.melt <- reshape2::melt(TLDist.cons1.ls) %>% 
  mutate(TL = as.numeric(value),
         k = factor(L1, levels = c("k3", "k4", "k5", "k6", "k7", "k8", "k9", "k10")))

TLDist.cons2.melt <- reshape2::melt(TLDist.cons2.ls) %>% 
  mutate(TL = as.numeric(value),
         k = factor(L1, levels = c("k3", "k4", "k5", "k6", "k7", "k8", "k9", "k10")))

TLDist.cons3.melt <- reshape2::melt(TLDist.cons3.ls) %>% 
  mutate(TL = as.numeric(value),
         k = factor(L1, levels = c("k3", "k4", "k5", "k6", "k7", "k8", "k9", "k10")))
  
  
plot.TLDist.cons1 <- TLDist.cons3.melt %>% 
  ggplot(aes(x = k, y = TL)) +
  geom_boxplot(lwd = 0.4, outlier.size = 0.8) + 
  scale_x_discrete(labels = c("3", "4", "5", "6", "7", "8", "9", "10")) +
  xlab(expression(value~of~italic(k))) +
  scale_y_continuous(name = "Days", limits = c(0,730)) +   # limits = c(0,220)
  theme_bw() +
  theme(legend.position = "none",
        strip.background = element_blank(),
        strip.text.x = element_blank(),
        # axis.text.y = element_text(size = 7.5),
        # axis.title.y = element_text(size = 11))
        axis.title.y = element_text(margin = margin(t = 0, r = 2.5, b = 0, l = 0)))






