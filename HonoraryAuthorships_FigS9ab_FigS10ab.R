##### Honorary Authorship Adjustment
# This script processes data and produces figures for the honorary authorship analysis
# It reads in two datasets
### The first (loaded as SCIENTISTS) is a panel of scientists' careers, with the amount of pivot of their papers relative to their prior papers
### The second (loaded as LOCATION) gives the country of affiliation for all scientists in the SCIENTISTS dataset
# The code produces four figures that appear in the paper's supplement:
### FIGURE S9a, raw pivot values by career age
### FIGURE S9b, residualized pivot values by career age
### FIGURE S10a, distribution of residualized pivot values by country of origin (China vs. Rest of World)
### FIGURE S10b, distribution of residualized pivot values by country of origin, following downsampling of China's excessively-large pivot authorships

library(data.table)
library(dplyr)
library(fixest)
library(ggplot2)


# ---- 0) Change WD for where you store the data ----
setwd("YOUR_PATH_HERE/data")


# ---- 1) Prepare Locations and Scientist data ----
# Read SCIENTISTS. Columns are: authorId, paperID, cosine similarity to all prior papers by the author, cosine similarity to last 5 papers by the author, cosine similarity to all papers from last 5 years by the author
SCIENTISTS <- fread("Honorary_Authors.csv.gz") 
LOCATION <- fread("Honorary_Authors_Locations.csv.gz")
SCIENTISTS <- SCIENTISTS[,c(1,2,3)]
INCLUDED_PAPERS <- unique(LOCATION$paperId)
# Retain only the scientists on papers that involve bilateral collaboration between regions
SCIENTISTS <- SCIENTISTS[which(SCIENTISTS$paper_id %in% INCLUDED_PAPERS),]
rm(INCLUDED_PAPERS)
names(SCIENTISTS) <-  c("AID","PID","PS_ALL")
names(LOCATION) <-  c("PID","AID","COUNTRY")
SCIENTISTS <- merge(SCIENTISTS, LOCATION, by=c("PID","AID"), all.x=F)
SCIENTISTS <- SCIENTISTS %>% group_by(AID) %>% mutate(CUMULATIVE_PAPER = (row_number()),
                                                      TOT_PAPERS = n())
SCIENTISTS$CUMULATIVE_PAPER_F <- as.factor(SCIENTISTS$CUMULATIVE_PAPER)
# Keep only scientists with 3+ career papers
SCIENTISTS <- SCIENTISTS[which(SCIENTISTS$TOT_PAPERS >= 3),]


# ---- 2) Regress pivot (cosine similarity) against cumulative paper count indicators, collect residuals ----
REG <- feols(PS_ALL ~ 0 | CUMULATIVE_PAPER_F, data=SCIENTISTS) 
SCIENTISTS <- SCIENTISTS[obs(REG),]
SCIENTISTS$RESID <- resid(REG)

# ---- 3) Figure S9A, raw pivot values (cosine similarities)
TEXT_SIZE <- 14
SCIENTISTS %>% filter(CUMULATIVE_PAPER_F %in% 1:200) %>% group_by(CUMULATIVE_PAPER) %>% summarize(CosineSimilarity = mean(PS_ALL)) %>% ggplot(aes(x=CUMULATIVE_PAPER, y=CosineSimilarity)) +
  geom_point() + theme_classic() + labs(title="", x="Cumulative Papers by Author", y = "Cosine Similarity") +
  theme(axis.text.x = element_text(size=TEXT_SIZE),
        axis.text.y = element_text(size=TEXT_SIZE),
        axis.title.y = element_text(size=TEXT_SIZE),
        axis.title.x = element_text(size=TEXT_SIZE),
        title = element_text(size=TEXT_SIZE)) 
#ggsave("/Users/cresposito/Library/CloudStorage/Dropbox/Chinese Scientific Leadership/Fig/Ghosts/Pivots_By_Cumulative_Papers.png", height=150, width=150, units="mm", dpi=400)


# ---- 4) Figure S9B, residualized pivot values (cosine similarities)
SCIENTISTS %>% filter(CUMULATIVE_PAPER_F %in% 1:200) %>% group_by(CUMULATIVE_PAPER) %>% summarize(ResidSimilarity = mean(RESID)) %>% ggplot(aes(x=CUMULATIVE_PAPER, y=ResidSimilarity)) +
  geom_point() + theme_classic() + labs(title="", x="Cumulative Papers by Author", y = "Residual of Cosine Similarity") +
  theme(axis.text.x = element_text(size=TEXT_SIZE),
        axis.text.y = element_text(size=TEXT_SIZE),
        axis.title.y = element_text(size=TEXT_SIZE),
        axis.title.x = element_text(size=TEXT_SIZE),
        title = element_text(size=TEXT_SIZE)) +
  coord_cartesian(ylim=c(-0.0000000000001, 0.0000000000001))
#ggsave("/Users/cresposito/Library/CloudStorage/Dropbox/Chinese Scientific Leadership/Fig/Ghosts/Residual_Pivots_By_Cumulative_Papers.png", height=150, width=150, units="mm", dpi=400)


##### Histograms
### These figures do not appear in the paper. They are informative, but they are commented out because they are unneccessary to reproduce the paper's figures
# ggplot(SCIENTISTS, aes(x=PS_ALL)) + geom_histogram(bins=50) + coord_cartesian(xlim=c(-1, 1), ylim=c(0, 500000)) + theme_classic() +
#   labs(title="Distribution of Cosine Similarity to Prior Paper Centroid", x="Cosine Similarity", y = "Count") +
#   theme(axis.text.x = element_text(size=TEXT_SIZE),
#         axis.text.y = element_text(size=TEXT_SIZE),
#         axis.title.y = element_text(size=TEXT_SIZE),
#         axis.title.x = element_text(size=TEXT_SIZE),
#         title = element_text(size=TEXT_SIZE))
# ggplot(SCIENTISTS, aes(x=RESID)) + geom_histogram(bins=50) + coord_cartesian(xlim=c(-1, 1), ylim=c(0, 250000)) + theme_classic() +
#   labs(title="Distribution of Residual Cosine Similarity to Prior Paper Centroid", x="Residual Cosine Similarity", y = "Count") +
#   theme(axis.text.x = element_text(size=TEXT_SIZE),
#         axis.text.y = element_text(size=TEXT_SIZE),
#         axis.title.y = element_text(size=TEXT_SIZE),
#         axis.title.x = element_text(size=TEXT_SIZE),
#         title = element_text(size=TEXT_SIZE))



# ---- 5) Assign authorships to China and RestOfWorld
SCIENTISTS$LOCATION <- SCIENTISTS$COUNTRY
SCIENTISTS$LOCATION[SCIENTISTS$COUNTRY != "CN"] <- "RestOfWorld"
SCIENTISTS$LOCATION[SCIENTISTS$COUNTRY == "CN"] <- "China"
SCIENTISTS$LOCATION <- factor(SCIENTISTS$LOCATION, levels = c("China","RestOfWorld"))

# ---- 6) FIGURE S10A, distribution of residualized pivot values for China and RestOfWorld
BREAKS = seq(-1, .2, by=.01)
SCIENTISTS$RESID_CUT = cut(SCIENTISTS$RESID, breaks = BREAKS)
SCIENTISTS$X <- gsub("^(.*?),.*", "\\1", SCIENTISTS$RESID_CUT)
SCIENTISTS$X <- as.numeric(gsub("[()]", "", SCIENTISTS$X))
DATA_CUT = SCIENTISTS %>% group_by(LOCATION, X) %>% summarise (n = n()) %>% mutate(freq = n / sum(n))
ggplot(data=DATA_CUT, 
       aes(x = X, y=freq*100, fill=LOCATION)) + geom_bar(stat="identity", position="dodge") + coord_cartesian(xlim=c(-.15, .05)) + 
  labs(title="", x="Residual Cosine Similarity", y = "Share of Location's Authorships (%)") + theme_classic() +
  scale_fill_manual("Author Location:", values = c("China" = "red", "RestOfWorld" = "grey")) +
  theme(axis.text.x = element_text(size=TEXT_SIZE),
        axis.text.y = element_text(size=TEXT_SIZE),
        axis.title.y = element_text(size=TEXT_SIZE),
        axis.title.x = element_text(size=TEXT_SIZE),
        title = element_text(size=TEXT_SIZE),
        legend.title = element_text(size=TEXT_SIZE+1),
        legend.text=element_text(size=TEXT_SIZE),
        legend.position="bottom")
#ggsave("/Users/cresposito/Library/CloudStorage/Dropbox/Chinese Scientific Leadership/Fig/Ghosts/Similarity_Comparison_By_Location.png", height=150, width=150, units="mm", dpi=400)


# ---- 7) Down-sample Chinese authorships in residual cosine similarity bins that China is overrepresented in
# Sampling probabilities
PROBS <- DATA_CUT[which(DATA_CUT$X > -0.5),]
PROBS <- PROBS %>% group_by(X) %>% mutate(PROB = (freq[LOCATION == "RestOfWorld"] / freq[LOCATION == "China"] )) %>% as.data.frame()
PROBS <- PROBS[which(PROBS$LOCATION == "China"),]
PROBS$PROB[which(PROBS$PROB > 1)] <- 1
PROBS <- cbind.data.frame(PROBS$X, PROBS$PROB)
names(PROBS) <- c("X","PROB")
# Only downsample if from China
SCIENTISTS_CN <- SCIENTISTS[which(SCIENTISTS$COUNTRY == "CN"),]
SCIENTISTS_CN <- merge(SCIENTISTS_CN, PROBS, by="X", all.x=T)
# Identify scientists to downsample (labeled as "EXCLUDE")
EXCLUDE1 <- SCIENTISTS_CN[which(is.na(SCIENTISTS_CN$PROB)),]
SCIENTISTS_CN <- SCIENTISTS_CN[which(is.na(SCIENTISTS_CN$PROB)==F),]
SCIENTISTS_CN$RAN <- runif(min=0, max=1, n=nrow(SCIENTISTS_CN))
SCIENTISTS_CN$EXCLUDE <- 0
SCIENTISTS_CN$EXCLUDE[SCIENTISTS_CN$RAN > SCIENTISTS_CN$PROB] <- 1
EXCLUDE2 <- SCIENTISTS_CN[which(SCIENTISTS_CN$EXCLUDE==1),]
EXCLUDE <- rbind.data.frame(cbind(EXCLUDE1$PID, EXCLUDE1$AID, EXCLUDE1$X), cbind(EXCLUDE2$PID, EXCLUDE2$AID, EXCLUDE2$X))
names(EXCLUDE) <- c("PID","AID","X")
EXCLUDE$X <- as.numeric(EXCLUDE$X)
# EXCLUDE now has the excluded Chinese authorshops

# ---- 7) FIGURE S10B, distribution of residualized pivot values for the excluded Chinese authorships
ggplot(data=EXCLUDE, 
       aes(x = X)) + geom_histogram(binwidth=.01, fill="red") + coord_cartesian(xlim=c(-.15, .05)) + 
  labs(title="", x="Residual Cosine Similarity", y = "Count of Excluded Authorships") + theme_classic() +
  theme(axis.text.x = element_text(size=TEXT_SIZE),
        axis.text.y = element_text(size=TEXT_SIZE),
        axis.title.y = element_text(size=TEXT_SIZE),
        axis.title.x = element_text(size=TEXT_SIZE),
        title = element_text(size=TEXT_SIZE),
        legend.title = element_text(size=TEXT_SIZE+2))
#ggsave("/Users/crßesposito/Library/CloudStorage/Dropbox/Chinese Scientific Leadership/Fig/Ghosts/Dropped_Chinese_Authorships.png", height=150, width=150, units="mm", dpi=400)





