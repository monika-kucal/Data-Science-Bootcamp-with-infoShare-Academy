
#Praca domowa R 
#Filip Jakubowski

#1
library(devtools)
library(openxlsx)
library(RPostgreSQL)
library(dplyr)

#2
active_packages <- function() {
  library(devtools)
  library(openxlsx)
  library(RPostgreSQL)
  library(dplyr)
}
active_packages

#3
active_packages <- function() {
  library(devtools)
  library(openxlsx)
  library(RPostgreSQL)
  library(dplyr)
  print("packages ready")
}

#4
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "postgres", host = "localhost", port = 5432,user = "postgres",password = "")
df_compensations <- dbGetQuery(con,"select * from szczegoly_rekompensat")

#5
dbExistsTable(con,"tab_1") # nie istnieje

#6
summary(df_compensations)

#7
sample_vector <- c(1,21,41)

#8
sample_vector_seq<-c(seq(from=1,to=41,by=20))

#9
v_combined <- c(sample_vector, sample_vector_seq)

#10
sort(v_combined,decreasing=TRUE)

#11
v_accounts <- c(df_compensations$konto)

#12
length(v_accounts)

#13
v_accounts_unique <- unique(v_accounts)
v_accounts_unique #"PKO PLN"      "BZWBK EUR"    "Pekao SA EUR" "mbank PLN"  
length(v_accounts_unique) #4

#14
sample_matrix <- matrix(c(998,0,1,1),nrow = 2,ncol = 2)
sample_matrix

#15
dimnames(sample_matrix) <- list(c("no cancer", "cancer"),c("no cancer", "cancer"))
sample_matrix

#16
accuracy <- (sample_matrix[1,1] + sample_matrix[2,2]) / sum(sample_matrix)
accuracy
precision <- (sample_matrix[2,2]) / (sample_matrix[2,1]+sample_matrix[2,2])
precision
recall <- (sample_matrix[2,2] / (sample_matrix[1,2] + sample_matrix[2,2]))
recall
fscore  <- 2 * ((precision * recall)/(precision + recall))
fscore                

#17
gen_matrix <- matrix(sample(1:50), nrow = 100, ncol = 10, byrow = TRUE)
gen_matrix

#18
l_persons <- list(lp1 = c(name = 'Monika', surname = 'Kucal', test_results=c(87,93,85),homework_results=c(97,88,93)),
                  lp2 = c(name = 'Bartosz', surname = 'Gornikiewicz', test_results=c(82,88,95), homework_results=c(65,72,83)),
                  lp3 = c(name = 'Piotr', surname = 'Szarmach', test_results=c(77,99,88), homework_results=c(44,92,67)))
l_persons

#19
print(l_persons[1])

#20
print(l_persons$lp1)

#21
l_accounts_unique <- list(unique(df_compensations$konto))
l_accounts_unique
typeof(l_accounts_unique)

#22
df_comp_small <- data.frame(df_compensations[c('id_agenta', 'data_otrzymania', 'kwota', 'konto')])
df_comp_small

#23
aggregated_df_comp <- df_comp_small %>% 
  group_by(konto) %>% 
  summarise(liczba = n(), total = sum(kwota)) %>%
as.data.frame()
aggregated_df_comp

#24


#25
for (i in 1:100) {
  print(sample(1:100, 1))
}

#26
liczba <- 0
while (liczba != 20) {
  liczba<-sample(1:50,1)
  print(liczba)
}

#27
df_comp_small$amount_category <- 'Not Available'

#28
dbWriteTable(con, "df_comp_small", df_comp_small) 
df_comp_small

#29

#30
