##### Chinese leadership counterfactual calculations
# This script produces TABLE 1 of the main text
# It reads in a dataset containing collaboration intensities between China and partner regions
# It outputs TABLE 1, which shows Chinese global scientific leadership under counterfactual scenarios
#####
library(data.table)




# ---- 0) Change WD for where you store the data ----
setwd("YOUR_PATH_HERE/data")

# ---- 1) Read & get 2023 shares ----
dt <- fread("China_Collaboration_Frequencies.csv.gz")
row23 <- dt[publication_year == 2023]
drop <- c("publication_year","total_articles","china_domestic","collaboration_count","china_domestic_pct")
partners <- setdiff(names(dt), drop)

shares <- c(
  as.list(unlist(row23[, ..partners])),
  list(Domestic = row23$china_domestic_pct)
)
shares <- unlist(shares)  # named numeric vector
stopifnot(abs(sum(shares) - 100) < 1e-6)

# ---- 2)  2030 lead shares ----
lead2030 <- data.table(
  Category = c("Africa","BeltRoad_HighIncome","BeltRoad_LowIncome","EU+","East Asia",
               "Latin America","Middle East North Africa","Non-EU Eastern Europe",
               "Oceania","Other Regions","Russia","South Asia","U.K.","U.S.","Domestic"),
  lead_share_2030 = c(
    NA, 0.639042558, 0.560045204, 0.563636889, NA,
    NA, NA, NA,
    NA, NA, NA, NA, 0.752631801, 0.532592418, NA  # Domestic excluded anyway
  )
)

# ---- 3) Decoupling (proportional reallocation incl. Domestic) ----
reallocate <- function(w, target = "U.S.", keep_frac = 1) {
  w <- w / sum(w) * 100
  freed <- w[target] * (1 - keep_frac)
  w[target] <- w[target] * keep_frac
  idx <- names(w) != target
  w[idx] <- w[idx] + freed * (w[idx] / sum(w[idx]))
  w * (100 / sum(w))
}

w0  <- shares
w50 <- reallocate(w0,  "U.S.", keep_frac = 0.5)
w00 <- reallocate(w0,  "U.S.", keep_frac = 0.0)

# ---- 4) Global Lead Share (exclude Domestic; drop NA lead shares; renormalize) ----
lead_score <- function(w, lead_dt) {
  x <- data.table(Category = names(w), weight = as.numeric(w))
  x <- x[Category != "Domestic"]
  x <- merge(x, lead_dt, by = "Category", all.x = TRUE)
  x <- x[!is.na(lead_share_2030)]
  x[, weight := weight / sum(weight)]              # renormalize over non-Domestic with known lead shares
  sum(x$weight * x$lead_share_2030)
}

gl0  <- lead_score(w0,  lead2030)
gl50 <- lead_score(w50, lead2030)
gl00 <- lead_score(w00, lead2030)

# ---- 5) Output table in requested format ----
fmt <- function(x) sprintf("%.2f", x)
out <- data.table(
  Metric = c("Global Lead Share", "% Domestic", "% Collabs with U.S."),
  `No Decoupling`        = c(fmt(gl0),  fmt(w0["Domestic"]),  fmt(w0["U.S."])),
  `Partial Decoupling`   = c(fmt(gl50), fmt(w50["Domestic"]), fmt(w50["U.S."])),
  `Complete Decoupling`  = c(fmt(gl00), fmt(w00["Domestic"]), fmt(w00["U.S."]))
)

# Outputs TABLE 1
print(out) 
