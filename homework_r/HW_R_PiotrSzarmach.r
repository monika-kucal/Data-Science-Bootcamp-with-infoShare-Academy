#1) load packages devtools, openxlsx, RPostgreSQL, dplyr
library(devtools)
library(openxlsx)
library(RPostgreSQL)
library(dplyr)

#2) read and build fnction active_packages, which will read all packages from prvious point
active_packages <- function()
{
  library(devtools)
  library(openxlsx)
  library(RPostgreSQL)
  library(dplyr)
}
active_packages()

#3) run function active_packages in concolse and check whether "packages ready" text appreared
active_packages <- function()
{
  library(devtools)
  library(openxlsx)
  library(RPostgreSQL)
  library(dplyr)
  print("packages ready")
}

#4) load all data from szczegoly_rekompensat table into data frame called df_compensations
loadData <- function(table)
{
  drv <- dbDriver("PostgreSQL")
  auth <- Sys.getenv(c("POSTGRESQL_LOGIN", "POSTGRESQL_PASSW"))
  con <- dbConnect(drv, dbname = "pg_2", host = "localhost", port = 5432, user = auth[[1]], password = auth[[2]])
  frame <- dbGetQuery(con, paste("SELECT * from ", table))
  return(as.data.frame(frame))
}
df_compensations <- loadData('szczegoly_rekompensat')

#5) check if table tab_1 exists in a connection defined in previous point
drv <- dbDriver("PostgreSQL")
auth <- Sys.getenv(c("POSTGRESQL_LOGIN", "POSTGRESQL_PASSW"))
con <- dbConnect(drv, dbname = "pg_2", host = "localhost", port = 5432, user = auth[[1]], password = auth[[2]])
exists <- dbExistsTable(con, 'tab_1')

#6) print df_compensations data frame summary
summary(df_compensations)

#VECTORS
#7) create vector sample_vector which contains numbers 1,21,41 (don't use seq function)
sample_vector <- c(1,21,41)

#8) create vector sample_vector_seq which contains numbers 1,21,41 (use seq function)
sample_vector_seq <- seq(from = 1, to = 41, by = 20)

#9) Combine two vectors (sample_vector, sample_vector_seq) into new one: v_combined
v_combined <- c(sample_vector, sample_vector_seq)
v_combined

#10) Sort data descending in vector v_combined
sort(v_combined)

#11) Create vector v_accounts created from df_compensations data frame, which will store data from 'konto' column
v_accounts <- c(df_compensations$konto)

#12) Check v_accounts vector length
length(v_accounts)

#13) Because previously created vector containst duplicated values, we need a new vector (v_accounts_unique), with unique values.
#Print vector and check its length
v_accounts_unique <- unique(v_accounts)
v_accounts_unique
length(v_accounts_unique)

#MATRIX
#14) Create sample matrix called sample_matrix, 2 columns, 2 rows. Data: first row (998, 0), second row (1,1)
sample_matrix <- matrix(c(998,0,1,1), nrow =2, ncol=2)
sample_matrix
  
#15) Assign row and column names to sample_matrix. Rows: ("no cancer", "cancer"), Columns: ("no cancer", "cancer")
column_names <- c("no cancer", "cancer")
row_names <- c("no cancer", "cancer")
rownames(sample_matrix) <- row_names
colnames(sample_matrix) <- column_names
sample_matrix

#16) Create 4 variables: precision, recall, acuracy, fscore and calculate their result based on data from sample_matrix
accuracy <- (sample_matrix[1,1] + sample_matrix[2,2]) / sum(sample_matrix)
precision <- (sample_matrix[2,2]) / (sample_matrix[2,1]+sample_matrix[2,2])
recall <- (sample_matrix[2,2]) / (sample_matrix[1,2]+sample_matrix[2,2])
fscore <- 2*precision*recall/(precision+recall)

#17) Create matrix gen_matrix with random data: 10 columns, 100 rows, random numbers from 1 to 50 inside
gen_matrix <- matrix(seq(from = 1, to = 50, by = 1), nrow = 100, ncol = 10, byrow = TRUE)

#LIST
#18) Create list l_persons with 3 members from our course. Each person has: name, surname, test_results (vector), homework_results (vector)
#aliasy utworzone na potrzebe 20.
l_persons <- list(first = c(name = "Bartosz", surname = "Górnikiewicz", test_results=c(92,88), homework_results=c(15,22)),
                  second = c(name = "Piotr", surname = "Szarmach", test_results=c(91,78), homework_results=c(24,22)),
                  third = c(name = "Monika", surname = "Kucal", test_results=c(92,99), homework_results=c(25,6)))

#19) Print first element from l_persons list (don't use $ sign)
print(l_persons[[1]])

#20) Print first element from l_persons list (use $ sign)
print(l_persons$first)

#21) Create list l_accounts_unique with unique values of 'konto' column from df_compensations data frame. Check l_accounts_unique type
l_accounts_unique <- list(unique(df_compensations$konto))
typeof(l_accounts_unique)

#DATA FRAME
#22) Create data frame df_comp_small with 4 columns from df_compensations data frame (id_agenta, data_otrzymania, kwota, konto)
df_comp_small <- data.frame(id_agenta = df_compensations$id_agenta,
                            data_otrzymania = df_compensations$data_otrzymania,
                            kwota = df_compensations$kwota,
                            konto = df_compensations$konto)

#23) Create new data frame with aggregated data from df_comp_small (how many rows we have per each account, 
#and what's the total value of recompensations in each account)
df_comp_aggregated <- df_comp_small %>% group_by(konto) %>% summarise(ilosc = n(), total = sum(kwota)) %>% as.data.frame()

#24) Which agent recorded most recompensations (amount)? Is this the same who recorded most action?
df_recomp_agent <- df_compensations %>% group_by(id_agenta) %>% summarise(ilosc_akcji = n(), total_compensation = sum(kwota)) %>% arrange(desc(total_compensation)) %>% as.data.frame()
#yes it was the same person (agent_id = 168)

#LOOPS and conditional instructions
#25) Create loop (for) which will print random 100 values
for(i in 1:100)
{
   print(sample(1:1000, 1))
}

#26) Create loop (while) which will print random values (between 1 and 50) until 20 wont' appear
a <- 0
while(a != 20)
{
  a <- sample(1:50, 1)
  print(a)
}

#27) Add extra column into df_comp_small data frame called amount_category. 
df_comp_small$amount_category <- ""

#28) Store data from df_comp_small into new table in DB
dbWriteTable(con, "df_comp_small", df_comp_small)
dbExistsTable(con, 'df_comp_small')

#29) Fill values in amount_category. All amounts below average: 'small', All amounts above avg: 'high'
mean_amount <- mean(df_comp_small$kwota)
for(i in 1:dim(df_comp_small[1]))
{
  if(df_comp_small$kwota[i] > mean_amount)
    df_comp_small$amount_category[i] <- "high"
  else 
    df_comp_small$amount_category[i] <- "low"
}

#30) Create function f_agent_stats which for given agent_id, will return total number of actions in all tables (analiza_wniosku, analiza_operatora etc)
f_agent_stats <- function(p_agent_id)
{
  
}