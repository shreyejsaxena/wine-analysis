# What makes wine "good"?
Exploration of wine characteristics to understand what attributes make wine good.

P. Cortez, A. Cerdeira, F. Almeida, T. Matos and J. Reis. Modeling wine preferences by data mining from physicochemical properties. In Decision Support Systems, Elsevier, 47(4):547-553, 2009.

- fixed acidity: tartaric acid, most acids involved with wine or fixed or nonvolatile (do not evaporate readily)
- volatile acidity: acetic acid, too high of levels can lead to an unpleasant, vinegar taste
- citric acid: found in small quantities, citric acid can add 'freshness' and flavor to wines
- astrigency rating: sensory attribute described as drying-out, roughening, and puckery sensation
- residual sugar: the amount of sugar remaining after fermentation stops
- chlorides: amount of salt in the wine
- free sulfur dioxide: prevents microbial growth and the oxidation of wine
- total sulfur dioxide: in low concentrations, SO2 is mostly undetectable in wine, but at free SO2 concentrations over 50 ppm, SO2 becomes evident in the nose and taste of wine
- density: depends on the percent alcohol and sugar content
- pH: describes how acidic or basic a wine is
- sulphates: antimicrobial and antioxidant
- alcohol: percent alcohol content
- vintage: year made
- quality: rating of 1 to 10 by wine experts where 0 is terrible and 10 is excellent

Using ordinal logistic regression model to identify significant variables for quality ratings...

## Significant red wine variables: 
- volatile.acidity
- pH
- sulphates
- alcohol
 
## Significant white wine variables: 
- volatile.acidity
- astringency.rating
- chlorides
- free.sulfur.dioxide
- density
- sulphates
- alcohol

 
 Also.. it should be noted that "experts" may not be the best people to ask about what makes wine good. 
 https://www.theguardian.com/lifeandstyle/2013/jun/23/wine-tasting-junk-science-analysis
 A clustering algorithm run on highly rated wines would be a good way to figure out if we (or some group of people) agree with the experts... happy hour anyone?
