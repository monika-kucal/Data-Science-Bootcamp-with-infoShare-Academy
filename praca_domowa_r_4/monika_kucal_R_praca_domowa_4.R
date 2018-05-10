# Monika Kucal
# PRACA DOMOWA R [3]

# Eager to have more insights from mtcars dataset?
# Please do a correspondence analysis on this dataset, to show CA for 3 pairs of fields.
# What should be the result?
# Your analysis as a data scientist (code + few comments for me, how you understand corplots, contribcharts, screeplot and biplot). I'm the stakeholder for this point
# Insights and clear business suggestions. Please make this section as actionable as it is possible. 
# Imagine you will present it to BMW, Ford etc Director, who don't understand statistics, but is only business focused
# Please send me your analysis in english!

# DATA
data(mtcars)

# LIBRARIES
library(FactoMineR) # CA
library(factoextra) # Visualize CA
library(mltools) # bin_data
library(corrplot) # corrplot

# COPY DATA
cars <- mtcars 

# BINS - VARIABLES
cars$car <- rownames(cars) # cars from rownames to variable
cars$car_group <- sapply(strsplit(cars$car," "),'[',1) # only car brand to variable
cars$mpg_group <- bin_data(cars$mpg, bins=5, binType = "quantile") # bins of mpg
cars$cyl_group <- cars$cyl # no change - 3 integer values
cars$disp_group <- bin_data(cars$disp, bins=5, binType = "quantile") # bins of disp
cars$hp_group <- bin_data(cars$hp, bins=5, binType = "quantile") # bins of hp
cars$drat_group <- bin_data(cars$drat, bins=5, binType = "quantile") # bins of drat
cars$wt_group <- bin_data(cars$wt, bins=5, binType = "quantile") # bins of wt
cars$qsec_group <- bin_data(cars$qsec, bins=5, binType = "quantile") # bins of qsec
cars$gear_group <- cars$gear # no change - 3 integer values
cars$carb_group <- cars$carb # no chnage - 6 integer values

# CORRPLOT
corr <- cor(mtcars)
corrplot(corr, method='number', type='lower', tl.col='black')
# Interpretation:
# There is the highest negative correlation between mpg and variables: wt, cyl, disp, hp.
# It means that INCREASE of wt, cyl, disp and hp causes significant DECREASE of mpg. 
# There is the highest positive correlation between mpg and variables: drat, vs, am.
# It means that INCREASE of drat, vs and am causes significant DECREASE of mpg.
# Qsec and gear do not influence very much on mpg.

# CONTINGENCY TABLES
cars_table_1 <- table(cars$mpg_group, cars$hp_group)
cars_table_2 <- table(cars$mpg_group, cars$drat_group)
cars_table_3 <- table(cars$mpg_group, cars$wt_group)

# CORRESPONDENCE ANALYSIS
ca_1 <- CA(cars_table_1, graph=FALSE) # MPG & HP
ca_2 <- CA(cars_table_2, graph=FALSE) # MPG & DRAT
ca_3 <- CA(cars_table_3, graph=FALSE) # MPG & WT

# SCREEPLOTS
fviz_screeplot(ca_1, addlabels=TRUE, ylim=c(0,100)) # MPG & HP
# Interpretation:
# First Dimension explains 45.7% of variance.
# Second Dimension explains 35.4% of variance
# First and second dimensions explain 81.1% of variance.
  
fviz_screeplot(ca_2, addlabels=TRUE, ylim=c(0,100)) # MPG & DRAT
# Interpretation:
# First Dimension explains 51.1% of variance.
# Second Dimension explains 32.5% of variance
# First and second dimensions explain 83.6% of variance.

fviz_screeplot(ca_3, addlabels=TRUE, ylim=c(0,100)) # MPG & WT
# Interpretation:
# First Dimension explains 51.8% of variance.
# Second Dimension explains 35.3% of variance
# First and second dimensions explain 87.1% of variance.

# CONTRIBUTION CHARTS
fviz_contrib(ca_1, choice="row", axes=1, top=10) # MPG & HP
fviz_contrib(ca_1, choice="row", axes=2, top=10)
# Interpretation:
# First Dimension allows to point one very unique group of cars with MPG betwen 10 and 15.
# Second Dimension allow to point one very unique group of cars with MPG between 24 and 34.

fviz_contrib(ca_2, choice="row", axes=1, top=10) # MPG & DRAT
fviz_contrib(ca_2, choice="row", axes=2, top=10)
# Interpretation:
# First Dimension allows to point one very unique group of cars with MPG betwen 24 and 34.
# Second Dimension allow to point one very unique group of cars with MPG between 21 and 24.

fviz_contrib(ca_3, choice="row", axes=1, top=10) # MPG & WT
fviz_contrib(ca_3, choice="row", axes=2, top=10)
# Interpretation:
# First Dimension allows to point one very unique group of cars with MPG betwen 24 and 34.
# Second Dimension allow to point one very unique group of cars with MPG between 21 and 24.


# BIPLOTS
fviz_ca_biplot(ca_1, col.row="contrib", repel=TRUE) # MPG & HP
# Interpretation:
# On the plot it is possible to see three or even four groups of cars.
# There is a group of cars with high MPG (above 24) - these cars have the lowest hp (below 93).
# There is a group of cars with medium MPG (between 15 and 24) - these cars have medium hp (between 93 and 200).
# There is a group of cars with low MPG (below 15) - these cars have the highest hp (above 200).
# Medium group can be split for two parts with MPG between 15 and 21 and with MPG between 21 and 24.

fviz_ca_biplot(ca_2, col.row="contrib", repel=TRUE) # MPG & DRAT
# Interpretation:
# On the plot it is possible to see four groups of cars.
# There is a group of cars with high MPG (above 24) - these cars have the highest drat (above 4).
# There is a group of cars with high-medium MPG (between 21 and 24) - these cars have high-medium drat (between 3.8 and 4).
# There is a group of cars with low-medium MPG (between 18 and 21) - these cars have low-medium drat (between 3 and 3.4).
# There is a group of cars with low MPG (below 18) - these cars have the lowest drat (below 3).

fviz_ca_biplot(ca_3, col.row="contrib", repel=TRUE) # MPG & WT
# Interpretation:
# On the plot it is possible to see three or even four groups of cars.
# There is a group of cars with high MPG (above 24) - these cars have the lowest wt (below 2.3).
# There is a group of cars with medium MPG (between 21 and 24) - these cars have medium wt (between 2.3 and 3.2).
# There is a group of cars with low MPG (below 18) - these cars have the highest wt (above 3.4)
# Low group can be split for two parts with MPG between 10 and 15 and with MPG between 15 and 18.