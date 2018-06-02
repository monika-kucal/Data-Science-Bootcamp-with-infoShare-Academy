library(tidyverse)
library(corrplot)
library(ggplot2)
library(gridExtra)
library(lubridate)
library(caret)
library(lava)

szeged <- read.table(file="weatherHistory.csv",sep=",",dec=".",header=TRUE)

colnames(szeged) <- c('date','summary','precip','temp','app_temp','humidity','wind_speed','wind_bearing','visibility','loud_cover','pressure','daily_summary')

summary(szeged)
str(szeged)

# KORELACJE
macierz_korelacji <- cor(szeged[,c('temp','app_temp','humidity','wind_speed','wind_bearing','visibility','pressure')])
corrplot(macierz_korelacji, method = 'number', type='lower')

# ROZKLADY
par(mfrow=c(2,2))
plot(density(szeged$app_temp), main="Apparent Temperature", ylab="Czestotliwosc",
     sub=paste("Skosnosc", round(e1071::skewness(szeged$app_temp), 1)))
polygon(density(szeged$app_temp), col="red")

boxplot(szeged$app_temp, main="Apparent Temperature")

plot(density(szeged$humidity), main="Humidity", ylab="Czestotliwosc",
     sub=paste("Skosnosc", round(e1071::skewness(szeged$humidity), 1)))
polygon(density(szeged$humidity), col="red")

boxplot(szeged$humidity, main="Humidity")

# OUTLIERS

outliers_app_temp <- c(boxplot.stats(szeged$app_temp)$stats[1],
boxplot.stats(szeged$app_temp)$stats[3],
boxplot.stats(szeged$app_temp)$stats[5])

outliers_temp <- c(boxplot.stats(szeged$temp)$stats[1],
boxplot.stats(szeged$temp)$stats[3],
boxplot.stats(szeged$temp)$stats[5])

outliers_humidity <- c(boxplot.stats(szeged$humidity)$stats[1],
boxplot.stats(szeged$humidity)$stats[3],
boxplot.stats(szeged$humidity)$stats[5])

outliers_wind_bearing <- c(boxplot.stats(szeged$wind_bearing)$stats[1],
boxplot.stats(szeged$wind_bearing)$stats[3],
boxplot.stats(szeged$wind_bearing)$stats[5])

outliers_wind_speed <- c(boxplot.stats(szeged$wind_speed)$stats[1],
boxplot.stats(szeged$wind_speed)$stats[3],
boxplot.stats(szeged$wind_speed)$stats[5])

outliers_visibility <- c(boxplot.stats(szeged$visibility)$stats[1],
boxplot.stats(szeged$visibility)$stats[3],
boxplot.stats(szeged$visibility)$stats[5])

outliers_pressure <- c(boxplot.stats(szeged$pressure)$stats[1],
boxplot.stats(szeged$pressure)$stats[3],
boxplot.stats(szeged$pressure)$stats[5])


szeged_clean <- szeged

szeged_clean$app_temp <- replace(szeged_clean$app_temp, szeged_clean$app_temp<outliers_app_temp[1], outliers_app_temp[2])
szeged_clean$app_temp <- replace(szeged_clean$app_temp, szeged_clean$app_temp>outliers_app_temp[3], outliers_app_temp[2])

szeged_clean$temp <- replace(szeged_clean$temp, szeged_clean$temp<outliers_temp[1], outliers_temp[2])
szeged_clean$temp <- replace(szeged_clean$temp, szeged_clean$temp>outliers_temp[3], outliers_temp[2])

szeged_clean$humidity <- replace(szeged_clean$humidity, szeged_clean$humidity<outliers_humidity[1], outliers_humidity[2])
szeged_clean$humidity <- replace(szeged_clean$humidity, szeged_clean$humidity>outliers_humidity[3], outliers_humidity[2])

szeged_clean$wind_bearing <- replace(szeged_clean$wind_bearing, szeged_clean$wind_bearing<outliers_wind_bearing[1], outliers_wind_bearing[2])
szeged_clean$wind_bearing <- replace(szeged_clean$wind_bearing, szeged_clean$wind_bearing>outliers_wind_bearing[3], outliers_wind_bearing[2])

szeged_clean$wind_speed <- replace(szeged_clean$wind_speed, szeged_clean$wind_speed<outliers_wind_speed[1], outliers_wind_speed[2])
szeged_clean$wind_speed <- replace(szeged_clean$wind_speed, szeged_clean$wind_speed>outliers_wind_speed[3], outliers_wind_speed[2])

szeged_clean$visibility <- replace(szeged_clean$visibility, szeged_clean$visibility<outliers_visibility[1], outliers_visibility[2])
szeged_clean$visibility <- replace(szeged_clean$visibility, szeged_clean$visibility>outliers_visibility[3], outliers_visibility[2])

szeged_clean$pressure <- replace(szeged_clean$pressure, szeged_clean$pressure<outliers_pressure[1], outliers_pressure[2])
szeged_clean$pressure <- replace(szeged_clean$pressure, szeged_clean$pressure>outliers_pressure[3], outliers_pressure[2])


summary(szeged$app_temp)
summary(szeged_clean$app_temp)

summary(szeged$humidity)
summary(szeged_clean$humidity)


# MONTH
szeged_clean$month <- month(szeged_clean$date)
avg_temp <- aggregate(temp ~ month, szeged_clean, mean)
colnames(avg_temp) <- c('month','avg_temp')
szeged_clean <- merge(szeged_clean,avg_temp,by='month')


# ROZKLADY BEZ OUTLIERSOW
par(mfrow=c(2,2))
plot(density(szeged_clean$app_temp), main="Apparent Temperature", ylab="Czestotliwosc",
     sub=paste("Skosnosc", round(e1071::skewness(szeged_clean$app_temp), 1)))
polygon(density(szeged_clean$app_temp), col="red")

boxplot(szeged_clean$app_temp, main="Apparent Temperature")

plot(density(szeged_clean$humidity), main="Humidity", ylab="Czestotliwosc",
     sub=paste("Skosnosc", round(e1071::skewness(szeged_clean$humidity), 1)))
polygon(density(szeged_clean$humidity), col="red")

boxplot(szeged_clean$humidity, main="Humidity")

# WYKRESY
ggplot(data=szeged, mapping=aes(x=humidity,y=app_temp))+
  geom_point()+
  geom_smooth(color='yellow')+
  geom_smooth(method='lm', color='red')

ggplot(data=szeged, mapping=aes(x=humidity,y=app_temp, color=month))+
  geom_point()+
  geom_smooth(color='yellow')+
  geom_smooth(method='lm', color='red')
  
ggplot(data=szeged, mapping=aes(x=humidity,y=app_temp))+
  geom_point(mapping=aes(color=month))+
  geom_smooth(color='yellow')+
  geom_smooth(method='lm', color='red')+
  facet_wrap(~month, nrow=4)

# WYKRESY BEZ OUTLIERSOW
ggplot(data=szeged_clean, mapping=aes(x=humidity,y=app_temp))+
  geom_point()+
  geom_smooth(color='yellow')+
  geom_smooth(method='lm', color='red')

ggplot(data=szeged_clean, mapping=aes(x=humidity,y=app_temp, color=month))+
  geom_point()+
  geom_smooth(color='yellow')+
  geom_smooth(method='lm', color='red')

ggplot(data=szeged_clean, mapping=aes(x=humidity,y=temp))+
  geom_point(mapping=aes(color=avg_temp))+
  scale_colour_gradientn(colors=c('blue','skyblue','green','orange','red'))+
  geom_smooth(color='grey')+
  geom_smooth(method='lm', color='black')+
  facet_wrap(~month, nrow=4)


# PODZIAL ZBIORU
set.seed(789)
index_train <- createDataPartition(szeged_clean$app_temp, p=0.8, list=FALSE) #80% uczacy

szeged_clean_train <- szeged_clean[index_train,] 

szeged_clean_test <- szeged_clean[-index_train,]

dim(szeged_clean_train)
dim(szeged_clean_test)

# MODEL LINIOWY
model_liniowy1 <- lm(temp ~ humidity, data=szeged_clean_train)
model_liniowy2 <- lm(app_temp ~ humidity, data=szeged_clean_train)

summary(model_liniowy1)
summary(model_liniowy2)

szeged_clean_test$temp_est_1 <- predict(model_liniowy1, szeged_clean_test)
szeged_clean_test$app_temp_est_2 <- predict(model_liniowy2, szeged_clean_test)

szeged_clean_test

par(mfrow=c(1,1))
plot(szeged_clean_test$temp, szeged_clean_test$temp_est_1)

postResample(pred=szeged_clean_test$temp_est_1, obs=szeged_clean_test$temp)
# RMSE  Rsquared       MAE 
# 7.4046489 0.3995327 6.0495848 

plot(szeged_clean_test$app_temp, szeged_clean_test$app_temp_est_2)

postResample(pred=szeged_clean_test$app_temp_est_2, obs=szeged_clean_test$app_temp)
# RMSE  Rsquared       MAE 
# 8.5775350 0.3622393 6.9957746 

# KORELACJE
macierz_korelacji_1 <- cor(szeged_clean[,c('temp','app_temp','humidity','wind_speed','wind_bearing','visibility','pressure')])
corrplot(macierz_korelacji_1, method = 'number', type='lower')

# MODEL LINIOWY 2
# szeged_clean_test$month<-as.factor(as.vector(month))
model_liniowy_multi1 <- lm(temp ~ humidity+wind_speed+wind_bearing+visibility+pressure+avg_temp, data=szeged_clean_train)
model_liniowy_multi2 <- lm(app_temp ~ humidity+wind_speed+wind_bearing+visibility+pressure+avg_temp, data=szeged_clean_train)

summary(model_liniowy_multi1)
summary(model_liniowy_multi2)

model_liniowy_multi1$coefficients

szeged_clean_test$temp_est_multi1 <- predict(model_liniowy_multi1, szeged_clean_test)
szeged_clean_test$app_temp_est_multi2 <- predict(model_liniowy_multi2, szeged_clean_test)

szeged_clean_test

par(mfrow=c(1,1))
plot(szeged_clean_test$temp, szeged_clean_test$temp_est_multi1)

postResample(pred=szeged_clean_test$temp_est_multi1, obs=szeged_clean_test$temp)
# RMSE  Rsquared       MAE 
# 4.0945163 0.8163959 3.2164588 

par(mfrow=c(1,1))
plot(szeged_clean_test$temp, szeged_clean_test$app_temp_est_multi2)

postResample(pred=szeged_clean_test$temp_est_multi2, obs=szeged_clean_test$temp)
# RMSE  Rsquared       MAE 
# 4.3827862 0.8125988 3.4670389 

# PROGNOZA POGODY

szeged_clean_prognoza<-data.frame(humidity=0.40,
                                  wind_speed=10,
                                  wind_bearing=28,
                                  visibility=50,
                                  pressure=1010,
                                  avg_temp=16.87369)
predict(model_liniowy_multi1, szeged_clean_prognoza)

