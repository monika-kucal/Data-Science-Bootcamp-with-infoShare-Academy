# HW1
# Bartosz Górnikiewicz

# 1

library(devtools)
library(openxlsx)
library(RPostgreSQL)
library(dplyr)

# 2

active_packages <- function() {
  library(devtools)
  library(openxlsx)
  library(RPostgreSQL)
  library(dplyr)
  print("packages ready")
}

# 3

active_packages()

# 4

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "postgres",
                 host = "localhost",
                 port = 5432,
                 user = "postgres",
                 password = "postgres")

df_compensations <- dbGetQuery(con, "SELECT * FROM szczegoly_rekompensat")

# 5

dbExistsTable(con, "tab_1")

# 6

df_compensations

# 7

sample_vector <- c(1, 21, 41)
sample_vector

# 8

sample_vector_seq <- seq(from = 1, by = 20, length.out = 3)
sample_vector_seq

# 9

v_combined <- c(sample_vector, sample_vector_seq)
v_combined

# 10

v_combined <- sort(v_combined)
v_combined

# 11

v_accounts <- df_compensations$konto
v_accounts

# 12

length(v_accounts)

# 13

v_accounts_unique <- unique(v_accounts)
v_accounts_unique
length(v_accounts_unique)

# 14

sample_matrix <- matrix(c(998, 0, 1, 1), 2, 2, byrow = TRUE)
sample_matrix

# 15

nms <- c("no cancer", "cancer")
colnames(sample_matrix) <- nms
rownames(sample_matrix) <- nms
sample_matrix

# 16

precision <- sample_matrix[2, 2]/sum(sample_matrix[, 2])
precision

recall <- sample_matrix[2, 2]/sum(sample_matrix[2,])
recall

accuracy <- (sample_matrix[1, 1] + sample_matrix [2, 2])/sum(sample_matrix)
accuracy

fscore <- 2 * (precision * recall)/(precision + recall)
fscore

# 17

gen_matrix <- matrix(sample(1:50, 1000, replace = TRUE), 100, 10)
gen_matrix

# 18

person_1 <- list("name1", "surname1", c(), c())
person_2 <- list("name2", "surname2", c(), c())
person_3 <- list("name3", "surname3", c(), c())

l_persons <- list(person_1, person_2, person_3)
names(l_persons) <- c("person_1", "person_2", "person3")

l_persons

# 19

l_persons[1]

# 20

l_persons$person_1

# 21

l_accounts_unique <- list(unique(df_compensations$konto))
class(l_accounts_unique)

# 22

df_comp_small <- df_compensations[, c("id_agenta", "data_otrzymania", "kwota", "konto")]
df_comp_small

# 23

df_comp_small_agg <-  df_comp_small %>%
                      group_by(konto) %>%
                      summarise(n = n(), suma = sum(kwota))
df_comp_small_agg

# 24

df_comp_small %>%
  group_by(id_agenta) %>%
  summarise(n = n(), sum = sum(kwota)) %>%
  arrange(desc(n))

# 25

for(i in 1:100) {
  print(sample(1:100, 1))
}

# 26

liczba <- 0
while(liczba != 20) {
  liczba <- sample(1:20, 1)
  print(liczba)
}

# 27

df_comp_small$ammount_category <- NA
head(df_comp_small)

# 28

DB <- df_comp_small

# 29

srednia <- mean(DB$kwota)
srednia

for(i in 1:length(DB$kwota)) {
  if(DB$kwota[i] < srednia) {
    DB$ammount_category[i] <- "low"
  } else {
    DB$ammount_category[i] <- "high"
  }
}

# 30

f_agent_stats <- function(x) {
  drv <- dbDriver("PostgreSQL")
  
  con <- dbConnect(drv, dbname = "postgres",
                   host = "localhost",
                   port = 5432,
                   user = "postgres",
                   password = "postgres")
  
  analiza_operatora <- dbGetQuery(con, paste("SELECT COUNT(*) AS analiza_operatora FROM analiza_operatora WHERE agent_id =", x))
  analiza_prawna <- dbGetQuery(con, paste("SELECT COUNT(*) AS analiza_prawna FROM analiza_prawna WHERE agent_id =", x))
  analiza_wnioskow <- dbGetQuery(con, paste("SELECT COUNT(*) AS analiza_wnioskow FROM analizy_wnioskow WHERE id_agenta =", x))
  dokumenty <- dbGetQuery(con, paste("SELECT COUNT(*) AS dokumenty FROM dokumenty WHERE agent_id =", x))
  
  print(analiza_operatora)
  print(analiza_prawna)
  print(analiza_wnioskow)
  print(dokumenty)
}
