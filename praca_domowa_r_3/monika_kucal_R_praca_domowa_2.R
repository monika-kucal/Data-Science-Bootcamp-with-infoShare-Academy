# Monika Kucal
# PRACA DOMOWA R [2]

# Zadanie: zeksploruj dataset mtcars. Poszukaj interesujących zależności pomiędzy danymi, 
# zwizualizuj je. Wynikiem powinien być kod R wraz z opisem interesujących zależności 
# (md/ ppt / pdf / doc)
library(tidyverse)  
library(corrplot)
library(e1071)
library(plot3D)

data("mtcars")
head(mtcars)
?mtcars

str(mtcars)
summary(mtcars)
mapply(anyNA,mtcars) # brak NA


# Transponuje tabele z danymi do wykresow ggplot
mtcars_ggplot_mpg<-mtcars
mtcars_ggplot_mpg$Samochod<-rownames(mtcars_ggplot_mpg)
mtcars_ggplot_mpg<-gather(mtcars_ggplot_mpg, "cyl":"carb", key = "Zmienna", value = "Wartosc", na.rm = FALSE)

mtcars_ggplot_qsec<-mtcars
mtcars_ggplot_qsec$Samochod<-rownames(mtcars_ggplot_qsec)
mtcars_ggplot_qsec<-gather(mtcars_ggplot_qsec, "mpg":"carb", -"qsec", key = "Zmienna", value = "Wartosc", na.rm = FALSE)


# Wykresy
ggplot(data=mtcars_ggplot_mpg)+
  geom_point(mapping=aes(x=Wartosc, y=mpg, color=Samochod))+
  geom_smooth(mapping=aes(x=Wartosc, y=mpg))+
  facet_wrap(~Zmienna, ncol=3, scales="free")+
  ggtitle('Zaleznosc MPG od pozostalych parametrow')

ggplot(data=mtcars_ggplot_qsec)+
  geom_point(mapping=aes(x=Wartosc, y=qsec, color=Samochod))+
  geom_smooth(mapping=aes(x=Wartosc, y=qsec))+
  facet_wrap(~Zmienna, ncol=3, scales="free")+
  ggtitle('Zaleznosc QSEC od pozostalych parametrow')


# Korelacje liniowe
attach(mtcars)
korelacje <- cor(mtcars)
par(mfrow=c(1,1))
corrplot(korelacje, method='circle', type='lower', tl.col='black')


# Funkcja gestosci i BoxPlot
par(mfrow=c(2,2))
plot(density(mtcars$mpg), main="Rozklad - MPG", ylab="Czestotliwosc",
     sub=paste("Skośność", round(e1071::skewness(mtcars$mpg), 1)))
polygon(density(mtcars$mpg), col="lightgreen")
boxplot(mtcars$mpg, main="Box Plot - MPG", col='lightgreen', ylab="MPG")

plot(density(mtcars$qsec), main="Rozklad - QSEC", ylab="Czestotliwosc",
     sub=paste("Skośność", round(e1071::skewness(mtcars$qsec), 1)))
polygon(density(mtcars$qsec), col="lightblue")
boxplot(mtcars$qsec, main="Box Plot - QSEC", col='lightblue', ylab="QSEC")


# Modele regresji liniowej z jedna zmienna objasniajaca
# MPG
model_mpg_wt <- lm(mpg~wt)
model_mpg_wt_sum<-summary(model_mpg_wt)
# R-squared:  0.7528
# wt istotna, bo 1.29e-10 ***<0.05

model_mpg_cyl <- lm(mpg~cyl)
model_mpg_cyl_sum<-summary(model_mpg_cyl)
# R-squared:  0.7262
# cyl istotna, bo 6.11e-10 ***<0.05

model_mpg_disp <- lm(mpg~disp)
model_mpg_disp_sum<-summary(model_mpg_disp)
# R-squared:  0.7183
#  istotna, bo 9.38e-10 ***<0.05

model_mpg_hp <- lm(mpg~hp)
model_mpg_hp_sum<-summary(model_mpg_hp)
# R-squared:  0.6024
#  istotna, bo 1.79e-07 ***<0.05

model_mpg_drat <- lm(mpg~drat)
model_mpg_drat_sum<-summary(model_mpg_drat)
# R-squared:  0.464
#  istotna, bo 1.78e-05 ***<0.05

model_mpg_vs <- lm(mpg~vs)
model_mpg_vs_sum<-summary(model_mpg_vs)
# R-squared:  0.4409
#  istotna, bo 3.42e-05 ***<0.05

# QSEC
model_qsec_hp <- lm(qsec~hp)
model_qsec_hp_sum<-summary(model_qsec_hp)
# R-squared: 0.5016 
#  istotna, bo 5.77e-06 ***<0.05

model_qsec_carb <- lm(qsec~carb)
model_qsec_carb_sum<-summary(model_qsec_carb)
# R-squared:  0.4307
#  istotna, bo 4.54e-05 ***<0.05

model_qsec_vs <- lm(qsec~vs)
model_qsec_vs_sum<-summary(model_qsec_vs)
# R-squared: 0.5543 
#  istotna, bo 1.03e-06 ***<0.05


# Wykresy regresji liniowej z jedna zmienna objasniajaca
par(mfrow=c(2,2))
plot(x=wt, y=mpg, main="MPG ~ WT", 
     sub=paste("R^2=", round(model_mpg_wt_sum$r.squared,2)))
abline(model_mpg_wt, col='red')

plot(x=cyl, y=mpg, main="MPG ~ CYL", 
     sub=paste("R^2=", round(model_mpg_cyl_sum$r.squared,2)))
abline(model_mpg_cyl, col='red')

plot(x=disp, y=mpg, main="MPG ~ DISP", 
     sub=paste("R^2=", round(model_mpg_disp_sum$r.squared,2)))
abline(model_mpg_disp, col='red')

plot(x=hp, y=qsec, main="QSEC ~ HP",
     sub=paste("R^2=", round(model_qsec_hp_sum$r.squared,2)))
abline(model_qsec_hp, col='red')


# Predykcje
predict(model_mpg_wt, data.frame("wt"=2.5))
predict(model_mpg_cyl, data.frame("cyl"=8))
predict(model_mpg_disp, data.frame("disp"=350))
predict(model_qsec_hp, data.frame("hp"=300))


# Modele regresji liniowej wieloma zmiennymi objaśniającymi

# MPG
# zaczynam od modelu z wszystkimi zmiennymi silnie skorelowanymi ze zmienna MPG
model_mpg_multi <- lm(mpg~wt+cyl+disp+hp+drat+vs)
summary(model_mpg_multi)
# wyrzucam najmniej istotna zmienna: vs
model_mpg_multi <- lm(mpg~wt+cyl+disp+hp+drat)
summary(model_mpg_multi)
# wyrzucam najmniej istotna zmienna: drat
model_mpg_multi <- lm(mpg~wt+cyl+disp+hp)
summary(model_mpg_multi)
# wyrzucam najmniej istotna zmienna: disp
model_mpg_multi <- lm(mpg~wt+cyl+hp)
summary(model_mpg_multi)
# wyrzucam najmniej istotna zmienna: hp
model_mpg_multi <- lm(mpg~wt+cyl)
summary(model_mpg_multi)
# stop - obie zmienne wt i cyl sa istotne >> model z dwiema zmiennymi
model_mpg_multi_sum<-summary(model_mpg_multi)
# R-squared:  0.8302

# QSEC
# zaczynam od modelu z wszystkimi zmiennymi silnie skorelowanymi ze zmienna QSEC
model_qsec_multi <- lm(qsec~hp+carb+vs)
summary(model_qsec_multi)
# wyrzucam najmniej istotna zmienna: hp
model_qsec_multi <- lm(qsec~carb+vs)
summary(model_qsec_multi)
# stop - obie zmienne carb i vs sa istotne >> model z dwiema zmiennymi
model_qsec_multi_sum<-summary(model_qsec_multi)
# R-squared:  0.6341


# Wykresy 3D regresji liniowej z dwiema zmiennymi obasniajacymi
# MODEL MPG ~ WT + CYL
x <- mtcars$wt
y <- mtcars$cyl
z <- mtcars$mpg

model_mpg_multi <- lm(z ~ x + y)

x_pred <- seq(min(x), max(x), length.out = 32)
y_pred <- seq(min(y), max(y), length.out = 32)
xy <- expand.grid( x = x_pred, y = y_pred)
z_pred <- matrix(predict(model_mpg_multi, newdata = xy), 
                 nrow = 32, ncol = 32)

fitpoints <- predict(model_mpg_multi)
par(mfrow=c(1,1))
scatter3D(x, y, z, pch = 18, cex = 2, 
          theta = 20, phi = 20, ticktype = "detailed",
          xlab = "wt", ylab = "cyl", zlab = "mpg",  
          surf = list(x = x_pred, y = y_pred, z = z_pred,  
                      facets = NA, fit = fitpoints), main = "MPG ~ WT + CYL")

# MODEL QSEC ~ CARB + VS
x <- mtcars$carb
y <- mtcars$vs
z <- mtcars$qsec

model_qsec_multi <- lm(z ~ x + y)

x_pred <- seq(min(x), max(x), length.out = 26)
y_pred <- seq(min(y), max(y), length.out = 26)
xy <- expand.grid( x = x_pred, y = y_pred)
z_pred <- matrix(predict(model_qsec_multi, newdata = xy), 
                 nrow = 26, ncol = 26)

fitpoints <- predict(model_qsec_multi)
par(mfrow=c(1,1))
scatter3D(x, y, z, pch = 18, cex = 2, 
          theta = 20, phi = 20, ticktype = "detailed",
          xlab = "carb", ylab = "vs", zlab = "qsec",  
          surf = list(x = x_pred, y = y_pred, z = z_pred,  
                      facets = NA, fit = fitpoints), main = "QSEC ~ CARB + VS")


# Predykcje
predict(model_mpg_multi, data.frame("x"=2.5, "y"=8))
predict(model_qsec_multi, data.frame("x"=2, "y"=0))


# GRADIENT
# Wybieram rgeresje liniowa MPG ~ WT
x <- mtcars$wt
y <- mtcars$mpg

# Funkcja kosztu
cost <- function(X,y,theta){
  sum( (X %*% theta - y)^2) / (2*length(y))
}

# learning rate i limit iteracji
alpha <- 0.1 # krok iteracji [zaczelam od 0.01]
num_iters <- 1000 # liczba iteracji [zaczelam od 2000]

# wartosci historyczne z iteracji
cost_history <- double(num_iters)
theta_history <- list(num_iters)

# parametry startowe
theta <- matrix(c(0,0),nrow=2)
X <- cbind(1,matrix(x))

# gradient prosty
for (i in 1:num_iters){
  error <- (X %*% theta - y)
  delta <- t(X) %*% error/length(y)
  theta <- theta - alpha * delta
  cost_history[i] <- cost(X, y, theta)
  theta_history[[i]] <- theta
}

# Wykres regresji
par(mfrow=c(1,2))
plot(x,y, xlab='WT', ylab='MPG', 
     main='Regresja liniowa metodą gradientu prostego',
     sub=paste('Krok=',alpha,'   Liczba iteracji=',num_iters))
for (i in c(1,3,6,10,14,seq(20,num_iters,by=10))) {
  abline(coef=theta_history[[i]], col='lightblue')
}
abline(coef=theta, col='red', lwd=2)


# Wykres funkcji kosztu
plot(cost_history, type='line', col='red', lwd=2, 
     main='Funkcja kosztu dla metody gradientu prostego',
     sub=paste('Krok=',alpha,'   Liczba iteracji=',num_iters),
     ylab='Koszt', xlab='Iteracja')

