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

candy <- read.csv('../../Regressions/candy-data.csv', header = TRUE)
candy$winpercent <- candy$winpercent / 100
candy
candy$competitorname <- NULL
#Podziel dane na części train/test
set.seed(789)
index_train <- createDataPartition(candy$chocolate, p=0.8, list=FALSE) #80% uczacy
candy_train <- candy[index_train,] 
candy_test <- candy[-index_train,]
labels <- as.data.frame(candy_train$chocolate)
labels2 <- as.data.frame(candy_test$chocolate)
candy_train$chocolate <- NULL

params <- list(booster = "gblinear", objective = "binary:logistic", eta=0.1, gamma=0, max_depth=15, subsample=0.5, colsample_bytree=0.5)
xgbcv <- xgb.cv( params = params, 
                 data = data.matrix(candy_train), 
                 label = data.matrix(labels), 
                 nrounds = 10, 
                 nfold = 5, 
                 showsd = T, 
                 stratified = T, 
                 print.every.n = 10, 
                 early.stop.round = 20, 
                 maximize = F)

xgb <- xgboost(data = data.matrix(candy_train), 
               label = data.matrix(labels), 
               eta = 0.1,
               max_depth = 15, 
               alpha = 0.45,
               nround= 10, 
               subsample = 0.5,
               colsample_bytree = 0.5,
               eval_metric = "auc",
               objective = "binary:logistic",
               nthread = 3
)

# predict values in test set
y_pred <- predict(xgb, data.matrix(candy_test[,-1]))
y_pred <- as.data.frame(ifelse (y_pred > 0.5,1,0))

y_pred_diff <- as.data.frame(as.factor(candy_test[,1]))

# Sample Data
predicted <- as.vector(y_pred$`ifelse(y_pred > 0.5, 1, 0)`)
reference <- as.vector(y_pred_diff$`as.factor(candy_test[, 1])`)

u <- union(predicted, reference)
t <- table(factor(predicted, u), factor(reference, u))
confusionMatrix(t)


#parameter tuning
set.seed(789)
index_train2 <- createDataPartition(candy$chocolate, p=0.8, list=FALSE) #80% uczacy
candy_train2 <- candy[index_train,] 
candy_test2 <- candy[-index_train,]
labels2 <- as.data.frame(candy_train$chocolate)
labels22 <- as.data.frame(candy_test$chocolate)

ml_task <- makeClassifTask(data = candy_train2,
                        target = "chocolate")

# 5-fold cross validation
cv_folds <- makeResampleDesc("CV", iters = 5)

random_tune <- makeTuneControlRandom(maxit = 17000L)
model <- makeLearner("classif.xgboost",predict.type = "prob")

model_Params <- makeParamSet(
  makeIntegerParam("nrounds",lower=3,upper=10),
  makeIntegerParam("max_depth",lower=1L,upper=7L),
  makeNumericParam("eta", lower = 0.001, upper = 0.7),
  makeNumericParam("subsample", lower = 0.3, upper = 0.90),
  makeNumericParam("min_child_weight",lower=1L,upper=5L),
  makeNumericParam("colsample_bytree",lower = 0.5,upper = 0.8),
  makeDiscreteParam("booster",values = c("gbtree","gblinear"))
)

parallelStartSocket(2)
# Tune model to find best performing parameter settings using random search algorithm
tuned_model <- tuneParams(learner = model,
                          task = ml_task,
                          resampling = cv_folds,
                          measures = acc,
                          par.set = model_Params,
                          control = random_tune,
                          show.info = FALSE)

tuned_model

# Apply optimal parameters to model
model <- setHyperPars(learner = model,
                      par.vals = tuned_model$x)

# Verify performance on cross validation folds of tuned model
resample(model,ml_task,cv_folds,measures = list(acc))

# Train final model with tuned parameters
xgBoost <- train(learner = model,task = ml_task)

preds <- predict(xgBoost, newdata = candy_test2)
# Stop parallel instance ~ Good practice to retire cores when training is complete
parallelStop()

str(preds)
preds
predicted <- as.vector(preds$data$response)
reference <- as.vector(preds$data$truth)

u <- union(predicted, reference)
t <- table(factor(predicted, u), factor(reference, u))
confusionMatrix(t)

                