require("datasets")
data("mtcars")
?mtcars

#outliers
boxplot(mtcars$mpg, main="MIL/gal")
boxplot(mtcars$cyl, main="Num of cyls")
boxplot(mtcars$disp, main="displacement")
boxplot(mtcars$hp, main="Gross Horsepower")
boxplot(mtcars$drat, main="Rear axle ratio") #outlier
boxplot(mtcars$wt, main="Weight (1000 lbs)") # 2 outliers
boxplot(mtcars$qsec, main="1/4 mile time") # outlier
boxplot(mtcars$vs, main="V/S")
boxplot(mtcars$am, main="Transmission (0 = automatic, 1 = manual)")
boxplot(mtcars$gear, main="Number of forward gears")
boxplot(mtcars$carb, main="Number of carburetors") #outlier

?skewness

#Density
#The skewness range should be between -2 to 2 (George & Mallery, 2010)
plot(density(mtcars$mpg), main="MIL/gal", ylab="Czestotliwosc",
     sub=paste("Skosnosc", round(e1071::skewness(mtcars$mpg), 1)))
polygon(density(mtcars$mpg), col="red") #positive skewness 0.6

plot(density(mtcars$cyl), main="Num of cyls", ylab="Czestotliwosc",
     sub=paste("Skosnosc", round(e1071::skewness(mtcars$cyl), 1)))
polygon(density(mtcars$cyl), col="red") #negative skewness -0.2

plot(density(mtcars$disp), main="displacement", ylab="Czestotliwosc",
     sub=paste("Skosnosc", round(e1071::skewness(mtcars$disp), 1)))
polygon(density(mtcars$disp), col="red") #positive skewness 0.4

plot(density(mtcars$hp), main="Gross Horsepower", ylab="Czestotliwosc",
     sub=paste("Skosnosc", round(e1071::skewness(mtcars$hp), 1)))
polygon(density(mtcars$hp), col="red") #positive skewness 0.7

plot(density(mtcars$drat), main="Rear axle ratio", ylab="Czestotliwosc",
     sub=paste("Skosnosc", round(e1071::skewness(mtcars$drat), 1)))
polygon(density(mtcars$drat), col="red") #positive skewness 0.3

plot(density(mtcars$wt), main="Weight (1000 lbs)", ylab="Czestotliwosc",
     sub=paste("Skosnosc", round(e1071::skewness(mtcars$wt), 1)))
polygon(density(mtcars$wt), col="red") #positive skewness 0.4

plot(density(mtcars$qsec), main="1/4 mile time", ylab="Czestotliwosc",
     sub=paste("Skosnosc", round(e1071::skewness(mtcars$qsec), 1)))
polygon(density(mtcars$qsec), col="red") #positive skewness 0.4

plot(density(mtcars$vs), main="V/S", ylab="Czestotliwosc",
     sub=paste("Skosnosc", round(e1071::skewness(mtcars$vs), 1)))
polygon(density(mtcars$vs), col="red")  #positive skewness 0.2

plot(density(mtcars$am), main="Transmission (0 = automatic, 1 = manual)", ylab="Czestotliwosc",
     sub=paste("Skosnosc", round(e1071::skewness(mtcars$am), 1)))
polygon(density(mtcars$am), col="red") #positive skewness 0.4

plot(density(mtcars$gear), main="Number of forward gears", ylab="Czestotliwosc",
     sub=paste("Skosnosc", round(e1071::skewness(mtcars$gear), 1)))
polygon(density(mtcars$gear), col="red") #positive skewness 0.5

plot(density(mtcars$carb), main="Number of carburetors", ylab="Czestotliwosc",
     sub=paste("Skosnosc", round(e1071::skewness(mtcars$carb), 1)))
polygon(density(mtcars$carb), col="red")  #positive skewness 1.1


#Correlation

install.packages("corrr")
library(corrr)
?focus
mtcars %>% correlate() %>% focus(mpg:drat)

# Check for incomplete data
col1 <- mapply(anyNA, mtcars)
col1

str(mtcars)

##WNIOSKI
#
# Moim podejściem było przprowadzenie poprawnej regresji liniowej oraz gradientu prostego, wraz z prawidłową eliminacją
# cech. Sprawdziłem dane pod kątem outlierów oraz sprawdziłem skośność i obliczyłem korelację między zmiennymi.
# Napotkałem problem przy odsiewaniu cech, gdyż nie byłem w stanie określic które pary cech mają odpowiednią korelacje,
# aby nie zepsuły wyniku dla przeprowadzonej później regresji i gradientu. Po samych wartościach doszedłem do momentu
# gdzie powinienem zostosować PCA, aczkolwiek nie zdążyłem już tego zaimplementować.
#
#
#
#
#

#Prediction and regression

#Normalization

#Prediction by gradient descent


