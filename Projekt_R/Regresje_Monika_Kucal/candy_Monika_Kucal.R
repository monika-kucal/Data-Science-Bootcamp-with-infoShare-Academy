library(ROCR)

candy <- read.table(file="candy-data.csv",sep=",",dec=".",header=TRUE)

# PODZIAL ZBIORU
set.seed(789)
index_train <- createDataPartition(candy$chocolate, p=0.8, list=FALSE) #80% uczacy

candy_train <- candy[index_train,] 

candy_test <- candy[-index_train,]

dim(candy_train)
dim(candy_test)

table(candy_train$chocolate,candy_train$fruity)
table(candy_train$chocolate,candy_train$pricepercent<0.5)

choco<-colMeans(candy_train[which(candy_train$chocolate==1),3:12])
no_choco<-colMeans(candy_train[which(candy_train$chocolate==0),3:12])
variables <- cbind(choco,no_choco,diff=abs(no_choco-choco))
# fruity > bar > pluribus > pricepercent > hard > peanutyalmondy > crispedricewafer > caramel > nougat > sugarpercent

model_logistyczny1 <- glm(chocolate ~ fruity + bar + pluribus + pricepercent + hard + peanutyalmondy + caramel, data=candy_train, family="binomial")
summary(model_logistyczny1)
# AIC: 55.964

chocolate_prob1<-predict(model_logistyczny1, candy_test, type="response")
candy_test<-cbind(candy_test,chocolate_prob1)

scatter.smooth(candy_test$chocolate, candy_test$chocolate_prob1)

table1<-table(candy_test$chocolate, candy_test$chocolate_prob1>0.8)
table1

ROCRpred1<-prediction(candy_test$chocolate_prob1, candy_test$chocolate)
ROCRperf1<-performance(ROCRpred1, 'tpr','fpr')
par(mfrow=c(1,1))
plot(ROCRperf1,colorize=TRUE)

auc1<-performance(ROCRpred1, measure="auc")
auc1<-auc1@y.values[[1]]
auc1

model_logistyczny2 <- glm(chocolate ~ fruity + pricepercent, data=candy_train, family="binomial")
summary(model_logistyczny2)
# AIC: 49.289

model_logistyczny2$coefficients

chocolate_prob2<-predict(model_logistyczny2, candy_test, type="response")
candy_test<-cbind(candy_test,chocolate_prob2)
cbind(candy_test$chocolate,candy_test$chocolate_prob2)

scatter.smooth(candy_test$chocolate, candy_test$chocolate_prob2)

table2<-table(candy_test$chocolate, candy_test$chocolate_prob2>0.8)
table2

ROCRpred2<-prediction(candy_test$chocolate_prob2, candy_test$chocolate)
ROCRperf2<-performance(ROCRpred2, 'tpr','fpr')
par(mfrow=c(1,1))
plot(ROCRperf2, colorize=TRUE, lwd=5)

auc2<-performance(ROCRpred2, measure="auc")
auc2<-auc2@y.values[[1]]
auc2
