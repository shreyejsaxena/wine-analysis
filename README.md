# What makes wine "good"?
Exploration of wine characteristics to understand what attributes make wine good. 

Available data
# fixed acidity: tartaric acid, most acids involved with wine or fixed or nonvolatile (do not evaporate readily)
# volatile acidity: acetic acid, too high of levels can lead to an unpleasant, vinegar taste
# citric acid: found in small quantities, citric acid can add 'freshness' and flavor to wines
# astrigency rating: sensory attribute described as drying-out, roughening, and puckery sensation
# residual sugar: the amount of sugar remaining after fermentation stops
# chlorides: amount of salt in the wine
# free sulfur dioxide: prevents microbial growth and the oxidation of wine
# total sulfur dioxide: in low concentrations, SO2 is mostly undetectable in wine, but at free SO2 concentrations over 50 ppm, SO2 becomes evident in the nose and taste of wine
# density: depends on the percent alcohol and sugar content
# pH: describes how acidic or basic a wine is
# sulphates: antimicrobial and antioxidant
# alcohol: percent alcohol content
# vintage: year made

Resulting ordinal logistic regression models (analyzing red and white wine separately)

Red wine coefficients: 
                     Estimate Std. Error z value Pr(>|z|)    
    volatile.acidity -4.00078    0.60872  -6.572 4.95e-11 ***
    pH               -1.82235    0.65680  -2.775  0.00553 ** 
    sulphates         3.67138    0.67462   5.442 5.26e-08 ***
    alcohol           0.86978    0.09496   9.160  < 2e-16 ***
    
            Estimate Std. Error z value
 bad|okay   -0.8529     2.2055  -0.387
 okay|good   5.9398     2.2180   2.678
 
 
White wine coefficients: 
                      Estimate Std. Error z value Pr(>|z|)    
   volatile.acidity     -4.089825   0.501022  -8.163 3.27e-16 ***
   astringency.rating   -2.094886   0.559890  -3.742 0.000183 *** 
   chlorides           -18.390826   4.696769  -3.916 9.02e-05 ***
   free.sulfur.dioxide   0.018712   0.002906   6.438 1.21e-10 ***
   density             123.737550  28.606445   4.326 1.52e-05 ***
   sulphates             1.089220   0.369836   2.945 0.003228 ** 
   alcohol               1.006875   0.067484  14.920  < 2e-16 ***
   
             Estimate Std. Error z value
 bad|okay    127.46      28.76   4.432
 okay|good   132.92      28.78   4.619
 
 
 Also.. it should be noted that "experts" may not be the best people to ask about what makes wine good. 
 https://www.theguardian.com/lifeandstyle/2013/jun/23/wine-tasting-junk-science-analysis
 A clustering algorithm run on highly rated wines would be a good way to figure out if we (or some group of people) agree with the experts... happy hour anyone?
