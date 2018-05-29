library(caret)
library(mlbench)
library(corrplot)
library(ggplot2)
library(memisc)
library(chron)
library(Metrics)
library(xgboost)
library(mlr)         # Machine learning library
library(parallelMap) # Parrelization of ML models

weather_data <- read.csv('../../Regressions/weatherHistory.csv', header = TRUE)

#Przejrzyj dane - wymiary, typy danych, wartości,statystyki
dim(weather_data)

#sprawdzenie typów
sapply(weather_data, class)
mapply(anyNA, weather_data)
head(weather_data)
summary(weather_data)

#Zwizualizuj dane - gęstość, boxplot, featurePlot

boxplot(weather_data$Temperature..C.)
boxplot(weather_data$Apparent.Temperature..C.)
boxplot(weather_data$Humidity) #false data for 0 
boxplot(weather_data$Wind.Speed..km.h.)
boxplot(weather_data$Wind.Bearing..degrees.)
boxplot(weather_data$Visibility..km.) #false data for 0
boxplot(weather_data$Pressure..millibars.) # false data for 0

ggplot(data = weather_data, aes(x=Apparent.Temperature..C., y=Temperature..C.)) + geom_point(col='blue') 
+ geom_smooth(method = "lm", se=FALSE, color="black", aes(group=1))

ggplot(data = weather_data, aes(x=Humidity, y=Temperature..C.)) + geom_point(col='blue') 
+ geom_smooth(method = "lm", se=FALSE, color="black", aes(group=1))

ggplot(data = weather_data, aes(x=Wind.Speed..km.h., y=Temperature..C.)) + geom_point(col='blue') 
+ geom_smooth(method = "lm", se=FALSE, color="black", aes(group=1))

ggplot(data = weather_data, aes(x=Wind.Bearing..degrees., y=Temperature..C.)) + geom_point(col='blue') 
+ geom_smooth(method = "lm", se=FALSE, color="black", aes(group=1))

ggplot(data = weather_data, aes(x=Visibility..km., y=Temperature..C.)) + geom_point(col='blue') 
+ geom_smooth(method = "lm", se=FALSE, color="black", aes(group=1))

ggplot(data = weather_data, aes(x=Pressure..millibars., y=Temperature..C.)) + geom_point(col='blue') 
+ geom_smooth(method = "lm", se=FALSE, color="black", aes(group=1))

weather_data$Pressure_Normalized <- exp(weather_data$Pressure..millibars.)
weather_data$Pressure_Normalized2 <- log(weather_data$Pressure..millibars.)

plot(weather_data$Summary)
plot(weather_data$Precip.Type) # nulls to fill
plot(weather_data$Daily.Summary)

plot(density(weather_data$Temperature..C.), main="Temp", ylab="Czestotliwosc",
     sub=paste("Skosnosc", round(e1071::skewness(weather_data$Temperature..C.), 1)))
polygon(density(weather_data$Temperature..C.), col="red") #positive skewness 0.1

plot(density(weather_data$Apparent.Temperature..C.), main="Apparent temp", ylab="Czestotliwosc",
     sub=paste("Skosnosc", round(e1071::skewness(weather_data$Apparent.Temperature..C.), 1)))
polygon(density(weather_data$Apparent.Temperature..C.), col="red") #negative skewness -0.1

plot(density(weather_data$Humidity), main="Humidity", ylab="Czestotliwosc",
     sub=paste("Skosnosc", round(e1071::skewness(weather_data$Humidity), 1)))
polygon(density(weather_data$Humidity), col="red") #negative skewness -0.7

plot(density(weather_data$Wind.Speed..km.h), main="Wind Speed", ylab="Czestotliwosc",
     sub=paste("Skosnosc", round(e1071::skewness(weather_data$Wind.Speed..km.h), 1)))
polygon(density(weather_data$Wind.Speed..km.h), col="red") #positive skewness 1.1

plot(density(weather_data$Wind.Bearing..degrees.), main="Wind Bearing", ylab="Czestotliwosc",
     sub=paste("Skosnosc", round(e1071::skewness(weather_data$Wind.Bearing..degrees.), 1)))
polygon(density(weather_data$Wind.Bearing..degrees.), col="red") #negative skewness -0.2

plot(density(weather_data$Visibility..km.), main="Visibility", ylab="Czestotliwosc",
     sub=paste("Skosnosc", round(e1071::skewness(weather_data$Visibility..km.), 1)))
polygon(density(weather_data$Visibility..km.), col="red") #negative skewness -0.5

plot(density(weather_data$Pressure..millibars.), main="Pressure", ylab="Czestotliwosc",
     sub=paste("Skosnosc", round(e1071::skewness(weather_data$Pressure..millibars.), 1)))
polygon(density(weather_data$Pressure..millibars.), col="red") #negative skewness -8.4!!!!!

#Czyszczenie danych i feature engineering

visibility_ids <- which(weather_data$Visibility..km. == 0)

for(i in visibility_ids)
{
   weather_data$Visibility..km.[[i]] <- mean(weather_data$Visibility..km.)
}

pressure_ids <- which(weather_data$Pressure..millibars. == 0)

for(i in pressure_ids)
{
  weather_data$Pressure..millibars.[[i]] <- mean(weather_data$Pressure..millibars.)
}

humidity_ids <- which(weather_data$Humidity == 0)

for(i in pressure_ids)
{
  weather_data$Humidity[[i]] <- mean(weather_data$Humidity)
}

weather_data$Loud.Cover <- NULL
weather_data$Pressure_Normalized <- NULL
weather_data$Pressure_Normalized2 <- NULL

snow_ratio <- 85224 / (10712+85224) * 100

precip_ids <- which(weather_data$Precip.Type == 'null')

for(i in precip_ids)
{
    if(runif(1, 1, 100) > snow_ratio)
      weather_data$Precip.Type[[i]] <- "rain"
    else weather_data$Precip.Type[[i]] <- "snow"
}
summary(weather_data)

set.seed(7)
correlationMatrix <- cor(weather_data[,4:10])
corrplot(correlationMatrix, method = "number") #apparent temp to remove
weather_data$Apparent.Temperature..C. <- NULL

#stworzenie wymiarów z daty, plus korekta innych zmiennych kategorycznych
table(weather_data$Summary)
median(weather_data$Temperature..C.)
ggplot(weather_data, aes(x=reorder(Summary, Temperature..C., FUN=mean), y=Temperature..C.)) +
  geom_bar(stat='summary', fun.y = "mean", fill='blue') + labs(x='Summary', y="Mean Temperature..C.") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_y_continuous(breaks= seq(0, 30, by=5))+
  geom_hline(yintercept=12, linetype="dashed", color = "red")

#Binning summary and daily summary into few bins
weather_data$SummaryBinned[weather_data$Summary %in% c('Dry', 'Windy and Dry', 'Dry and Mostly Cloudy', 'Dry and Partly Cloudy')] <- 5
weather_data$SummaryBinned[weather_data$Summary %in% c('Humid and Partly Cloudy', 'Humid and Overcast', 'Breezy and Dry', 'Humid and Mostly Cloudy', 'Partly Cloudy')] <- 4
weather_data$SummaryBinned[!weather_data$Summary %in% c('Dry', 'Windy and Dry', 'Dry and Mostly Cloudy', 'Dry and Partly Cloudy', 
                                                  'Humid and Partly Cloudy', 'Humid and Overcast', 'Breezy and Dry', 
                                                  'Humid and Mostly Cloudy', 'Partly Cloudy','Windy', 'Breezy and Overcast', 
                                                  'Overcast', 'Breezy', 'Windy and Overcast', 'Breezy and Foggy', 'Foggy')] <- 3
weather_data$SummaryBinned[weather_data$Summary %in% c('Windy', 'Breezy and Overcast', 'Overcast', 'Breezy', 'Windy and Overcast')] <- 2
weather_data$SummaryBinned[weather_data$Summary %in% c('Breezy and Foggy', 'Foggy')] <- 1
table(weather_data$SummaryBinned)
weather_data$Summary <- NULL

table(weather_data$Daily.Summary)
ggplot(weather_data, aes(x=reorder(Daily.Summary, Temperature..C., FUN=mean), y=Temperature..C.)) +
  geom_bar(stat='summary', fun.y = "mean", fill='blue') + labs(x='Daily Summary', y="Mean Temperature..C.") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_y_continuous(breaks= seq(-10, 30, by=5))+
  geom_hline(yintercept=12, linetype="dashed", color = "red")

weather_data$DailySummaryBinned[weather_data$Daily.Summary %in% 
                                  as.vector(aggregate(Temperature..C.~Daily.Summary, data=weather_data, mean)
                                            [which(aggregate(Temperature..C.~Daily.Summary, 
                                                             data=weather_data, mean)[,2] < 0),1])] <- 1

weather_data$DailySummaryBinned[weather_data$Daily.Summary %in% 
                                  as.vector(aggregate(Temperature..C.~Daily.Summary, data=weather_data, mean)
                                            [which(aggregate(Temperature..C.~Daily.Summary, data=weather_data, mean)[,2] >= 0 
                                                   & aggregate(Temperature..C.~Daily.Summary, data=weather_data, mean)[,2] < 5),1])] <- 2

weather_data$DailySummaryBinned[weather_data$Daily.Summary %in% 
                                  as.vector(aggregate(Temperature..C.~Daily.Summary, data=weather_data, mean)
                                            [which(aggregate(Temperature..C.~Daily.Summary, data=weather_data, mean)[,2] >= 5 
                                                   & aggregate(Temperature..C.~Daily.Summary, data=weather_data, mean)[,2] < 10),1])] <- 3

weather_data$DailySummaryBinned[weather_data$Daily.Summary %in% 
                                  as.vector(aggregate(Temperature..C.~Daily.Summary, data=weather_data, mean)
                                            [which(aggregate(Temperature..C.~Daily.Summary, data=weather_data, mean)[,2] >= 10 
                                                   & aggregate(Temperature..C.~Daily.Summary, data=weather_data, mean)[,2] < 15),1])] <- 4

weather_data$DailySummaryBinned[weather_data$Daily.Summary %in% 
                                  as.vector(aggregate(Temperature..C.~Daily.Summary, data=weather_data, mean)
                                            [which(aggregate(Temperature..C.~Daily.Summary, data=weather_data, mean)[,2] >= 15 
                                                   & aggregate(Temperature..C.~Daily.Summary, data=weather_data, mean)[,2] < 20),1])] <- 5

weather_data$DailySummaryBinned[weather_data$Daily.Summary %in% 
                                  as.vector(aggregate(Temperature..C.~Daily.Summary, data=weather_data, mean)
                                            [which(aggregate(Temperature..C.~Daily.Summary, data=weather_data, mean)[,2] >= 20 
                                                   & aggregate(Temperature..C.~Daily.Summary, data=weather_data, mean)[,2] < 25),1])] <- 6

weather_data$DailySummaryBinned[weather_data$Daily.Summary %in% 
                                  as.vector(aggregate(Temperature..C.~Daily.Summary, data=weather_data, mean)
                                            [which(aggregate(Temperature..C.~Daily.Summary, 
                                                             data=weather_data, mean)[,2] >= 25),1])] <- 7

table(weather_data$DailySummaryBinned)
weather_data$Daily.Summary <- NULL

weather_data$Precip.Type <- as.factor(weather_data$Precip.Type)

correlationMatrix <- cor(weather_data[,3:10])
corrplot(correlationMatrix, method = "number")

#Binning date 
weather_data$Formatted.Date <- as.Date(weather_data$Formatted.Date)

#Stworzenie dummy variables dla zmiennych kategorycznych
dummy_weather_data <- as.data.frame(model.matrix(~.-1, weather_data))

#Podziel dane na części train/test
set.seed(789)
index_train <- createDataPartition(dummy_weather_data$Temperature..C., p=0.8, list=FALSE) #80% uczacy
dummy_weather_data_train <- dummy_weather_data[index_train,] 
dummy_weather_data_test <- dummy_weather_data[-index_train,]
labels <- as.data.frame(dummy_weather_data_train$Temperature..C.)
labels2 <- as.data.frame(dummy_weather_data_test$Temperature..C.)
dummy_weather_data_train$Temperature..C. <- NULL

params <- list(booster = "gbtree", objective = "reg:linear", eta=0.1, gamma=0, max_depth=15, subsample=0.5, colsample_bytree=0.5)
xgbcv <- xgb.cv( params = params, 
                 data = data.matrix(dummy_weather_data_train), 
                 label = data.matrix(labels), 
                 nrounds = 1000, 
                 nfold = 5, 
                 showsd = T, 
                 stratified = T, 
                 print.every.n = 10, 
                 early.stop.round = 20, 
                 maximize = F)

xgb <- xgboost(data = data.matrix(dummy_weather_data_train), 
               label = data.matrix(labels), 
               eta = 0.1,
               max_depth = 15, 
               alpha = 0.45,
               nround= 1000, 
               subsample = 0.5,
               colsample_bytree = 0.5,
               eval_metric = "rmse",
               objective = "reg:linear",
               nthread = 3
)

# predict values in test set
y_pred <- predict(xgb, data.matrix(dummy_weather_data_test[,-5]))

y_pred_diff <- as.data.frame(dummy_weather_data_test$Temperature..C. - y_pred)

caret::postResample(dummy_weather_data_test$Temperature..C., y_pred)




#parameter tuning
set.seed(789)
index_train <- createDataPartition(dummy_weather_data$Temperature..C., p=0.8, list=FALSE) #80% uczacy
dummy_weather_data_train2 <- dummy_weather_data[index_train,] 
dummy_weather_data_test2 <- dummy_weather_data[-index_train,]
labels2 <- as.data.frame(dummy_weather_data_train$Temperature..C.)
labels22 <- as.data.frame(dummy_weather_data_test$Temperature..C.)

ml_task <- makeRegrTask(data = dummy_weather_data_train2,
                        target = "Temperature..C.")

# 5-fold cross validation
cv_folds <- makeResampleDesc("CV", iters = 5)

random_tune <- makeTuneControlRandom(maxit = 100L)
model <- makeLearner("regr.xgboost")

model_Params <- makeParamSet(
  makeIntegerParam("nrounds",lower=1000,upper=1001),
  makeIntegerParam("max_depth",lower=1,upper=25),
  makeNumericParam("lambda",lower=0,upper=0.60),
  makeNumericParam("eta", lower = 0.001, upper = 0.5),
  makeNumericParam("subsample", lower = 0.10, upper = 0.80),
  makeNumericParam("min_child_weight",lower=1,upper=5),
  makeNumericParam("colsample_bytree",lower = 0.2,upper = 0.8)
)

parallelStartSocket(2)
# Tune model to find best performing parameter settings using random search algorithm
tuned_model <- tuneParams(learner = model,
                          task = ml_task,
                          resampling = cv_folds,
                          measures = rmse,
                          par.set = model_Params,
                          control = random_tune,
                          show.info = FALSE)

tuned_model

# Apply optimal parameters to model
model <- setHyperPars(learner = model,
                      par.vals = tuned_model$x)

# Verify performance on cross validation folds of tuned model
resample(model,ml_task,cv_folds,measures = list(rsq,rmse))

# Train final model with tuned parameters
xgBoost <- train(learner = model,task = ml_task)

preds <- predict(xgBoost, newdata = dummy_weather_data_test2)

# Stop parallel instance ~ Good practice to retire cores when training is complete
parallelStop()

str(preds)
preds

caret::postResample(preds$data$truth, preds$data$response)
