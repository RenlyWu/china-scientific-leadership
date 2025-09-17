##### Chinese migration and leadership
# This script produces Figure S13 and S14 in the supplemental materials
# It reads in a dataset containing collaboration intensities between China and partner regions
# It outputs two figures:
## FIGURE S13, an event plot of changes in the number of citations received by Chinese scientists before / after returning to China
## FIGURE S14, an event plot of changes in the mean team size of Chinese scientists before / after returning to China
#####
library(data.table)
library(fixest)
library(ggplot2)
library(dplyr)




# ---- 0) Change WD for where you store the data ----
setwd("YOUR_PATH_HERE/data")



# ---- 1) Read and prepare data ----
DATA <- fread("Chinese_Migrants.csv.gz")
DATA$Treated <- 0
DATA$Treated[DATA$Group=="MI"] <- 1 # MI stands for Migrant. These individuals moved to the US and then returned to China (see paper text)
DATA$Post <- 0
DATA$Post[which(DATA$Relative_Turning_Year >= 0)] <- 1
mean(DATA$Team_Size[which(DATA$Treated==0 & DATA$Post ==0)])
DATA$Academic_Age_Years <- as.factor(floor(DATA$Relative_Turning_Year))
DATA <- DATA %>% group_by(Author_ID) %>% mutate(Migration_Year = min(publication_year[Post==1])) %>% as.data.frame()
DATA$YearsToMigration <- as.factor(DATA$publication_year - DATA$Migration_Year)
DATA_AGG <- DATA %>% filter(Country_Set == "CN") %>% group_by(Author_ID, publication_year, Treated, Post, Migration_Year, YearsToMigration) %>% summarize(Mean_Team_Size = mean(Team_Size),
                                                                                                                                                         Total_Collaborators = sum(Team_Size),
                                                                                                                                                         Mean_Forward_Citations = mean(cited_by_count),
                                                                                                                                                         Total_Citations = sum(cited_by_count)) %>% as.data.frame()

# ---- 2) Produce Figure S13 ----
MOD <- summary(feols(log(Mean_Forward_Citations+1) ~ Treated*relevel(YearsToMigration, "-1") | Author_ID + publication_year, data=DATA_AGG[which(DATA_AGG$YearsToMigration %in% -10:15),]))
summary(MOD)
MOD  <- cbind.data.frame(names(MOD$coefficients), MOD$coefficients, MOD$se)
names(MOD ) <- c("VAR","COEFF","SE")
MOD  <- MOD[which(grepl("Treated:", MOD$VAR)),]
MOD$YearsToReturn <- c(-10:-2, 0:15)
MOD$VAR <- as.character(MOD$VAR)
MOD <- rbind(MOD, c(0,0,0,-1))
TEXT_SIZE <- 14
ggplot(MOD, aes(x=YearsToReturn, y=COEFF)) + 
  geom_point(size=2) +
  geom_errorbar(aes(ymin=(COEFF)-(1.96*SE), ymax=(COEFF)+(1.96*SE))) + geom_vline(xintercept=-1) + geom_hline(yintercept=0) + coord_cartesian(ylim=c(-.15, .5)) +
  theme_classic() + labs(title="", x="Years to Return", y = "Δ Log Mean Forward Citations") +
  theme(axis.text.x = element_text(size=TEXT_SIZE),
        axis.text.y = element_text(size=TEXT_SIZE),
        axis.title.y = element_text(size=TEXT_SIZE),
        axis.title.x = element_text(size=TEXT_SIZE),
        title = element_text(size=TEXT_SIZE)) 
#ggsave("/Users/cresposito/Library/CloudStorage/Dropbox/Chinese Scientific Leadership/Renli_Revisions/PNG/Migrations_Fwd_Cites.png", height=150, width=150, units="mm", dpi=400)



# ---- 3) Produce Figure S14 ----
MOD <- summary(feols(log(Mean_Team_Size) ~ Treated*relevel(YearsToMigration, "0") | Author_ID + publication_year, data=DATA_AGG[which(DATA_AGG$YearsToMigration %in% -15:15),]))
summary(MOD)
MOD  <- cbind.data.frame(names(MOD$coefficients), MOD$coefficients, MOD$se)
names(MOD ) <- c("VAR","COEFF","SE")
MOD  <- MOD[which(grepl("Treated:", MOD$VAR)),]
MOD$YearsToReturn <- c(-10:-2, 0:15)
MOD$VAR <- as.character(MOD$VAR)
MOD <- rbind(MOD, c(0,0,0,-1))
TEXT_SIZE <- 14
ggplot(MOD, aes(x=YearsToReturn, y=COEFF)) + 
  geom_point(size=2) +
  geom_errorbar(aes(ymin=(COEFF)-(1.96*SE), ymax=(COEFF)+(1.96*SE))) + geom_vline(xintercept=-1) + geom_hline(yintercept=0) + coord_cartesian(ylim=c(-.15, .5)) +
  theme_classic() + labs(title="", x="Years to Return", y = "Δ Log Team Size") +
  theme(axis.text.x = element_text(size=TEXT_SIZE),
        axis.text.y = element_text(size=TEXT_SIZE),
        axis.title.y = element_text(size=TEXT_SIZE),
        axis.title.x = element_text(size=TEXT_SIZE),
        title = element_text(size=TEXT_SIZE)) 
#ggsave("/Users/cresposito/Library/CloudStorage/Dropbox/Chinese Scientific Leadership/Renli_Revisions/PNG/Migrations_TeamSize.png", height=150, width=150, units="mm", dpi=400)







