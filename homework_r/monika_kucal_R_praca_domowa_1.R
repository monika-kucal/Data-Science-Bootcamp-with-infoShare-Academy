# PRACA DOMOWA - R
# Monika Kucal


# 1) load packages devtools, openxlsx, RPostgreSQL, dplyr
library(devtools)
library(openxlsx)
library(RPostgreSQL)
library(dplyr)


# 2) read and build fnction active_packages, which will read all packages from prvious point. 
#    Print the text "packages ready" at the end of function
active_packages <- function(){
  library(devtools)
  library(openxlsx)
  library(RPostgreSQL)
  library(dplyr)
  print("packages ready")
}


# 3) run function active_packages in concolse and check whether "packages ready" text appreared
active_packages() #"packages ready" text appeared


# 4) load all data from szczegoly_rekompensat table into data frame called df_compensations

drv<-dbDriver("PostgreSQL") #driver
con<-dbConnect(drv,dbname="postgres",host="localhost",port=5432,
               user="postgres",password="") #connection

df_compensations<-dbGetQuery(con,"select * from szczegoly_rekompensat") #loaded
is.data.frame(df_compensations) # check if it is data.frame


# 5) check if table tab_1 exists in a connection defined in previous point
dbExistsTable(con,"tab_1") #tab_1 does not exist


# 6) print df_compensations data frame summary
summary(df_compensations)


# VECTORS

# 7) create vector sample_vector which contains numbers 1,21,41 (don't use seq function)
sample_vector<-c(1,21,41)


# 8) create vector sample_vector_seq which contains numbers 1,21,41 (use seq function)
sample_vector_seq<-c(seq(1,41,20))


# 9) Combine two vectors (sample_vector, sample_vector_seq) into new one: v_combined
v_combined<-c(sample_vector,sample_vector_seq)


# 10) Sort data descending in vector v_combined
v_combined<-sort(v_combined, decreasing=TRUE)


# 11) Create vector v_accounts created from df_compensations data frame, 
# which will store data from 'konto' column
v_accounts<-c(df_compensations$konto)


# 12) Check v_accounts vector length
length(v_accounts) # 38643


# 13) Because previously created vector containst duplicated values, 
# we need a new vector (v_accounts_unique), with unique values. 
# Print vector and check its length
v_accounts_unique<-unique(v_accounts)
v_accounts_unique
length(v_accounts_unique) # 4


# MATRIX

# 14) Create sample matrix called sample_matrix, 2 columns, 2 rows. 
# Data: first row (998, 0), second row (1,1)
sample_matrix<-matrix(c(998,0,1,1), nrow = 2, byrow = TRUE)


# 15) Assign row and column names to sample_matrix. 
# Rows: ("no cancer", "cancer"), Columns: ("no cancer", "cancer")
dimnames(sample_matrix)<-list(c('no cancer','cancer'),c('no cancer','cancer'))


# 16) Create 4 variables: precision, recall, acuracy, fscore 
# and calculate their result based on data from sample_matrix
precision<-sample_matrix[4]/sum(sample_matrix[,2]) # 100%
recall<-sample_matrix[4]/sum(sample_matrix[2,]) # 50%
accuracy<-sum(diag(sample_matrix))/sum(sample_matrix) # 99.9%
fscore<-2*precision*recall/(precision+recall) # 66.7%


# 17) Create matrix gen_matrix with random data: 
# 10 columns, 100 rows, random numbers from 1 to 50 inside
gen_matrix<-matrix(sample(1:50), nrow = 100, ncol = 10, byrow = TRUE)


# LIST

# 18) Create list l_persons with 3 members from our course. 
# Each person has: name, surname, test_results (vector), homework_results (vector)
l_persons<-list(x1=c(name='Bartosz',
                  surname='Górnikiewicz',
                  test_results=c(100,90,100),
                  homework_results=c(99,99,98,98)),
                x2=c(name='Filip',
                  surname='Jakubowski',
                  test_results=c(90,100,100),
                  homework_results=c(98,99,98,99)),
                x3=c(name='Piotr',
                  surname='Szarmach',
                  test_results=c(100,100,90),
                  homework_results=c(99,98,99,98)))

# 19) Print first element from l_persons list (don't use $ sign)
l_persons[[1]]


# 20) Print first element from l_persons list (use $ sign)
l_persons$x1


# 21) Create list l_accounts_unique with unique values of 'konto' column from df_compensations data frame. 
# Check l_accounts_unique type
l_accounts_unique<-list(unique(df_compensations$konto))
typeof(l_accounts_unique) # list


# DATA FRAME

# 22) Create data frame df_comp_small with 4 columns from df_compensations data frame 
# (id_agenta, data_otrzymania, kwota, konto)
df_comp_small<-data.frame(df_compensations[c('id_agenta','data_otrzymania','kwota','konto')])


# 23) Create new data frame with aggregated data from df_comp_small 
# (how many rows we have per each account, 
# and what's the total value of recompensations in each account)
aggr_df_comp_small <- df_comp_small %>% group_by(konto) %>% summarise(n_rows=n(),total_recompensation=sum(kwota)) %>% as.data.frame()


# 24) Which agent recorded most recompensations (amount)? 
# Is this the same who recorded most action?
df_comp_small %>% group_by(id_agenta) %>% summarise(recompensation=sum(kwota),action=n()) %>% arrange(desc(recompensation))
# most recompensations: id_agenta 168      10035650.  33735
df_comp_small %>% group_by(id_agenta) %>% summarise(recompensation=sum(kwota),action=n()) %>% arrange(desc(action))
# most action: id_agenta 168      10035650.  33735
# so the same agent 168
 

# LOOPS and conditional instructions

# 25) Create loop (for) which will print random 100 values
# assumption: 100 different random integer numbers between 1 and 10000
for (i in 1:100) {
  i<-sample(1:10000,1)
  print(i)
}


# 26) Create loop (while) which will print random values (between 1 and 50) until 20 wont' appear
i<-0
while (i!=20){
  i<-sample(1:50,1)
  print(i)
}


# 27) Add extra column into df_comp_small data frame called amount_category.
df_comp_small$amount_category <- NA


# 28) Store data from df_comp_small into new table in DB
dbWriteTable(con, "df_comp_small", df_comp_small) # new table in DB
dbExistsTable(con,"df_comp_small") # check if new table exists
dbReadTable(con,"df_comp_small") # show table


# 29) Fill values in amount_category. 
# All amounts below average: 'small', All amounts above avg: 'high'
avg_kwota <- mean(df_comp_small$kwota) # avg amount
df_comp_small$amount_category <- ifelse (df_comp_small$kwota<avg_kwota, 'small' ,'high')
dbWriteTable(con, "df_comp_small", df_comp_small, overwrite = TRUE) # overwrite
dbReadTable(con,"df_comp_small") # show table


# 30) Create function f_agent_stats which for given agent_id, 
# will return total number of actions in all tables (analizy_wnioskow, analiza_operatora etc)

# based on 5 tables in DB
db_analizy_wnioskow<-dbReadTable(con,"analizy_wnioskow")
db_analiza_operatora<-dbReadTable(con,"analiza_operatora")
db_analiza_prawna<-dbReadTable(con,"analiza_prawna")
db_dokumenty<-dbReadTable(con,"dokumenty")
db_rekompensaty<-dbReadTable(con,"rekompensaty")

#function: input - agent_id, output - records in 5 tables for each agent
f_agent_stats <- function(id){
  # number of records in each table for specific agent - exception! null values for some agents
  df_analizy_wnioskow<-as.data.frame(db_analizy_wnioskow %>% group_by(id_agenta) %>% summarise(liczba_analiz_wnioskow=n()) %>% filter(id_agenta==id))
  df_analiza_operatora<-as.data.frame(db_analiza_operatora %>% group_by(agent_id) %>% summarise(liczba_analiz_operatora=n()) %>% filter(agent_id==id))
  df_analiza_prawna<-as.data.frame(db_analiza_prawna %>% group_by(agent_id) %>% summarise(liczba_analiz_prawnych=n()) %>% filter(agent_id==id))
  df_dokumenty<-as.data.frame(db_dokumenty %>% group_by(agent_id) %>% summarise(liczba_analiz_dokumentow=n()) %>% filter(agent_id==id))
  df_rekompensaty<-as.data.frame(db_rekompensaty %>% group_by(id_agenta) %>% summarise(liczba_rekompensat=n()) %>% filter(id_agenta==id))
  
  # sum of number of records for specific agent
  total<-  ifelse (length(row_number(df_analizy_wnioskow))==0,0,df_analizy_wnioskow$liczba_analiz_wnioskow)+
    ifelse (length(row_number(df_analiza_operatora))==0,0,df_analiza_operatora$liczba_analiz_operatora)+
    ifelse (length(row_number(df_analiza_prawna))==0,0,df_analiza_prawna$liczba_analiz_prawnych)+
    ifelse (length(row_number(df_dokumenty))==0,0,df_dokumenty$liczba_analiz_dokumentow)+
    ifelse (length(row_number(df_rekompensaty))==0,0,df_rekompensaty$liczba_rekompensat)
  
  # output
  return(total)
}

# function check
f_agent_stats(1) # =8: agent with no legal/recompensation analysis - exception!
f_agent_stats(168) # =127 642: agent with values in each table
