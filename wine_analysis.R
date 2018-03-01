# what makes a wine 'good'
set.seed(123)
library(corrplot)
library(haven)
library(MASS)
library(ordinal)
library(cluster)


raw = read.csv("C:\\Users\\shrey\\Documents\\Workspace\\SAPio\\SAPio_DataScience_Challenge.csv")
str(raw); summary(raw)

# fixed acidity: tartaric acid, most acids involved with wine or fixed or nonvolatile (do not evaporate readily)
# volatile acidity: acetic acid, too high of levels can lead to an unpleasant, vinegar taste
# citric acid: found in small quantities, citric acid can add 'freshness' and flavor to wines
# astrigency rating: sensory attribute described as drying-out, roughening, and puckery sensation
# residual sugar: the amount of sugar remaining after fermentation stops
# chlorides: amount of salt in the wine

# free sulfur dioxide: prevents microbial growth and the oxidation of wine
# total sulfur dioxide: in low concentrations, SO2 is mostly undetectable in wine, but at free SO2 concentrations over 50 ppm, SO2 becomes evident in the nose and taste of wine
# given more time, would explore this relationship further...

# density: depends on the percent alcohol and sugar content
# pH: describes how acidic or basic a wine is
# sulphates: antimicrobial and antioxidant
# alcohol: percent alcohol content
# vintage: year made

# probably should investigate cause of missing values...
# figure out if imputing makes sense...
# for now just omit residual.sugar and rows with NAs from analysis
raw_cc = na.omit(raw[, -which(names(raw) %in% "residual.sugar")])

# separate red and white wine data for analysis, split into training and validation sets
red = raw_cc[raw_cc$type == "red", -which(names(raw_cc) %in% "type")]
red_train_ind = sample(seq_len(nrow(red)), size = floor(0.8 * nrow(red))) # 80% of data as training, 20% validation
red_t = red[red_train_ind, ]; red_v = red[-red_train_ind, ]

white = raw_cc[raw_cc$type == "white", -which(names(raw_cc) %in% "type")]
white_train_ind = sample(seq_len(nrow(white)), size = floor(0.8 * nrow(white))) # 80% of data as training, 20% validation
white_t = white[white_train_ind, ]; white_v = white[-white_train_ind, ]


##############################
# DATA EXPLORATION - OUTLIERS
##############################

# checking distributions...

for(i in 1:ncol(red_t)){
  par(mfrow=c(1,2))
  hist(red_t[,i], main=colnames(red_t)[i])
  boxplot(red_t[,i], main=colnames(red_t)[i])
}

for(i in 1:ncol(white_t)){
  par(mfrow=c(1,2))
  hist(white_t[,i], main=colnames(white_t)[i])
  boxplot(white_t[,i], main=colnames(white_t)[i])
}

# outliers... to remove or not remove... that is the question...
# probably should explore each outlier and figure out why it is the way it is...
# just remove *extreme* outliers for now
# if i have time, will go back and rerun analysis with outliers in and see if results differ

# identifies row indices of extreme outliers 
# return logic array with "TRUE" for every row that contains an extreme outlier
find_outliers = function(red_t) {
  # define upper and lower limits for "extreme outlier" (+/- 3*IQR)
  red_upper_limits = rep(0,ncol(red_t))
  red_lower_limits = rep(0,ncol(red_t))
  for(i in 1:ncol(red_t)){
    red_upper_limits[i] = quantile(red_t[,i], .75) + 3*IQR(red_t[,i])
    red_lower_limits[i] = quantile(red_t[,i], .25) - 3*IQR(red_t[,i])
  }
  
  # identify which rows need to be omitted
  red_outliers = rep(FALSE, nrow(red_t))
  for(i in 1:nrow(red_t)){
    for(j in 1:ncol(red_t)){
      # if any value exceeds the columns outlier limits, flag the row as an outlier
      if((red_t[i,j] > red_upper_limits[j]) | (red_t[i,j] < red_lower_limits[j])) red_outliers[i] = TRUE
    }
  } 
  return(red_outliers)
}

red_outliers = find_outliers(red_t); sum(red_outliers) # 56 from red
red_1 = red_t[!red_outliers,]

white_outliers = find_outliers(white_t); sum(white_outliers) # 145 from white
white_1 = white_t[!white_outliers,]

##################################
# DATA EXPLORATION - CORRELATIONS
#################################

par(mfrow=c(1,1))

# red wine correlations.. oi vey
corrplot.mixed(cor(red_1), tl.cex=.7) 
# astringency / fixed acidity + .99
# pH / fixed acidity -.7
# pH / astringency -.69
# astringency / density +.69
# fixed acidity / citric acid +.68
# fixed acidity / density +.67

# white wine correlations.. 
corrplot.mixed(cor(white_1), tl.cex=.7)
# astringency / fixed acidity + .99
# density / alcohol -.82

# Some sort of variable reduction may be useful between astringency // fixed acidity //  pH
# They seem semantically similar but could evoke different attributes in whites vs reds
# For now, just exclude fixed.acidity from modeling to remove extreme correlation

############
# MODELING
############
# would likely play around with various stepwise selection methods..
# ask my sommelier friend what she thinks most important attributes are..
# for now just try a few model approaches that can provide quick insight 
# and do simple variable selections along the way


# APPROACH 1: ORDINAL LOGISTIC REGRESSION
# but for now start off with everything in the model and remove variables that make "sense"
red_1.1 = red_1; white_1.1 = white_1
red_1.1$goodness = cut(red_1.1$quality, c(0,4,6,10), labels=c("bad", "okay", "good"))
white_1.1$goodness = cut(white_1.1$quality, c(0,4,6,10), labels=c("bad", "okay", "good"))

# choosing not to rescale for benefit of interpretability... 
# don't think it necessarily mess up the fit... (think it is just the vintage variable...)
# given more time would try scaled/unscaled parameters and see if large differences in scales are problematic

red.ordinal = clm(goodness ~ volatile.acidity + pH + sulphates + alcohol, data = red_1.1); summary(red.ordinal)
# start with everything in the model
# remove fixed.acidity due to correlation with astringency.rating
# remove total.sulfur.dioxide due to highest p value (.90)
# generally similar estimates, remove density next (.88)
# generally similar estimates, remove astringency.rating next (.74)
# generally similar estimates, remove citric.acid next (.56)
# generally similar estimates, remove free.sulfur.dioxide next (.56)
# generally similar estimates, remove vintage next (.43)
# generally similar estimates, remove chlorides next (.36)
# all variables significant at .01 -- this is what make red wine good
# Coefficients:
#   Estimate Std. Error z value Pr(>|z|)    
# volatile.acidity -4.00078    0.60872  -6.572 4.95e-11 ***
#   pH               -1.82235    0.65680  -2.775  0.00553 ** 
#   sulphates         3.67138    0.67462   5.442 5.26e-08 ***
#   alcohol           0.86978    0.09496   9.160  < 2e-16 ***
#   ---
#   Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
# 
# Threshold coefficients:
#   Estimate Std. Error z value
# bad|okay   -0.8529     2.2055  -0.387
# okay|good   5.9398     2.2180   2.678

white.ordinal = clm(goodness ~ volatile.acidity + astringency.rating + chlorides + free.sulfur.dioxide + density + sulphates + alcohol ,data = white_1.1); summary(white.ordinal)
# remove fixed.acidity due to correlation with astringency.rating
# remove citric.acid due to highest p value (.89)
# generally similar estimates, remove total.sulfur.dioxide next (.62)
# generally similar estimates, remove pH next (.58)
# generally similar estimates, remove vintage next (.45)
# all variables significant at .01 -- this is what makes white wine good
# Coefficients:
#   Estimate Std. Error z value Pr(>|z|)    
# volatile.acidity     -4.089825   0.501022  -8.163 3.27e-16 ***
#   astringency.rating   -2.094886   0.559890  -3.742 0.000183 *** (should probably go back and do this again but starting with fixed.acidity in)
#   chlorides           -18.390826   4.696769  -3.916 9.02e-05 ***
#   free.sulfur.dioxide   0.018712   0.002906   6.438 1.21e-10 ***
#   density             123.737550  28.606445   4.326 1.52e-05 ***
#   sulphates             1.089220   0.369836   2.945 0.003228 ** 
#   alcohol               1.006875   0.067484  14.920  < 2e-16 ***
#   ---
#   Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
# 
# Threshold coefficients:
#   Estimate Std. Error z value
# bad|okay    127.46      28.76   4.432
# okay|good   132.92      28.78   4.619
  




# APPROACH 2: multiple linear regression?
# similar process as for ordinal logistic but using quality rating as response variable... 
# compare with ordinal logistic model using holdout validation set...




# APPROACH 3: decision trees?
# easier to interpret and explain




# APPROACH 4: host a happy hour?
# Wine Tasting is a Junk Science
# https://www.theguardian.com/lifeandstyle/2013/jun/23/wine-tasting-junk-science-analysis
# We have to figure out for ourselves what makes wine good or bad
# Use partioning-around-medoids to find the bottles of wine that are most representative of "good wines" and see if they are actually "good"

# function provides list of wines and number of bottles we want to try
# returns a list of wines we should taste from all wines that are rated > 6 by experts
what_wine_should_we_try = function(white_1, bottles){
  white_good = white_1[white_1$quality > 6,] # get the "good" wines (quality rating )
  
  # standardize and perform PCA on all white wines
  pca_cutoff = function(pca_sdev, cutoff=.9){
    num_pc = 0;
    for(i in 1:length(pca_sdev)) {
      num_pc = num_pc+1;
      if((sum(pca_sdev[1:i]^2)/sum(pca_sdev^2)) > cutoff) return(num_pc);
    }
  }
  white_std = data.frame(apply(white_good,2,function(x){center = min(x); spread = max(x) - min(x);list = (x - center)/spread;}))
  white_pca = prcomp(white_std) 
  # use scores of those principal components for clustering
  white_df_pca = data.frame(white_pca$x[,1:pca_cutoff(white_pca$sdev, cutoff=.9)])  # explain 90% of variance in dataset
  white_dist = as.matrix(dist(white_df_pca,method = "euclidean")) 
  
  # identify the representative bottles of wine that minimize pariwise dissimilarities with neighboring observations
  white_pam_fit = pam(white_dist, diss = TRUE, k = bottles) # k is the number of bottles of wine we want to split...
  
  return(white_1[white_pam_fit$medoids,])
}

white_taste_test = what_wine_should_we_try(white_1, 4)  # from outlier trimmed, try 4 bottles of white
red_taste_test = what_wine_should_we_try(red_1, 3)  # from outlier trimmed, try 3 bottles of red

# ask whoever tries them if they agree with experts
rbind(white_taste_test, red_taste_test)

