library(XML)
library(RCurl)
library(tidyverse)

init_data <- function()
{
  # zrodlo danych
  link <- "https://docs.google.com/spreadsheets/d/1P9PG5mcbaIeuO9v_VE5pv6U4T2zyiRiFK_r8jVksTyk/htmlembed?single=true&gid=0&range=a10:o400&widget=false&chrome=false"
  xData <- getURL(link)
  dane_z_html <- readHTMLTable(xData, stringsAsFactors = FALSE, skip.rows = c(1, 3), encoding = "UTF-8")
  dane_z_html <- as.data.frame(dane_z_html)
  
  # zapisanie nazw kolumn z pierwzego wiersza
  nms <- dane_z_html[1,]
  
  # nadanie nazw kolumnom
  colnames(dane_z_html) <- nms
  
  # usunięcie pierwszego wiersza
  dane_z_html <- dane_z_html[-1, -1]
  
  # zastąpienie pzecinkow kropkami w wybranych kolumnach
  dane_z_html[, 7:15] <- apply(apply(dane_z_html[,7:15], 2, gsub, patt=",", replace="."), 2, as.numeric)
  
  # zamiana formatu daty z character na date
  dane_z_html[, 3]
  daty_ch <-dane_z_html[,3]
  daty_dat <- as.Date(daty_ch, format = "%d.%m.%Y")
  dane_z_html[, 3] <- daty_dat
  
  # wyczyszczenie naw kolumn
  colnames(dane_z_html)[1] <- "Osrodek"
  colnames(dane_z_html)[4] <- "Metoda"
  colnames(dane_z_html)[9] <- "K15"
  
  dane_z_html <- gather(dane_z_html, "PiS":"N/Z", key = "partia", value = "poparcie", na.rm = FALSE)
  
  #dane_z_html <- dane_z_html %>%
  #  group_by(Osrodek, Metoda) %>%
  #  mutate(liczba = n_distinct(Publikacja))
  
  return(dane_z_html)
}