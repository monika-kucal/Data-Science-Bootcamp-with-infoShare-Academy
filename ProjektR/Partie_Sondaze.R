# pobranie danych
# zaladowanie pakietow
library(XML)
library(RCurl)
library(ggplot2)
library(tidyverse)
library(ggthemes) #nowy pakiet aby wykresy były ładniejsze - trzeba zainstalować bibliotekę

# zrodlo danych
link <- "https://docs.google.com/spreadsheets/d/1P9PG5mcbaIeuO9v_VE5pv6U4T2zyiRiFK_r8jVksTyk/htmlembed?single=true&gid=0&range=a10:o400&widget=false&chrome=false"
xData <- getURL(link)
dane_z_html <- readHTMLTable(xData, stringsAsFactors = FALSE, skip.rows = c(1, 3), encoding = "UTF-8")
dane_z_html <- as.data.frame(dane_z_html)

# zapisanie nazw kolumn z pierwzego wiersza
nms <- dane_z_html[1,]

# nadanie nazw kolumnom
colnames(dane_z_html) <- nms

# usunięcie pierwszego wiersza i pierwszej kolumny
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

head(dane_z_html)

dane_z_html <- gather(dane_z_html, "PiS":"N/Z", key = "partia", value = "poparcie", na.rm = FALSE)

dane_z_html <- dane_z_html %>%
  group_by(Osrodek, Metoda) %>%
  mutate(liczba = n_distinct(Publikacja))

head(dane_z_html)

# robienie wykresow

# wykres dla PiS
ggplot(filter(dane_z_html, Osrodek %in% 
              c("CBOS","Estymator","IBRiS","IPSOS","Kantar MB","Kantar Public","MillwardBrown","Pollster","TNS Polska")
              & partia == "PiS"),
              aes(x = Publikacja, y = poparcie)) +
  ylim(0, 60) +
  geom_point() +
  geom_smooth(se = FALSE) +
  facet_wrap(~ Osrodek) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y")  +
  theme_gdocs()

ggsave("PiS.png", width = 5, height = 5)

# wykres dla PO
ggplot(filter(dane_z_html, Osrodek %in% 
                c("CBOS","Estymator","IBRiS","IPSOS","Kantar MB","Kantar Public","MillwardBrown","Pollster","TNS Polska")
              & partia == "PO"),
       aes(x = Publikacja, y = poparcie)) +
  ylim(0, 60) +
  geom_point() +
  geom_smooth(se = FALSE) +
  facet_wrap(~ Osrodek) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y")  +
  theme_gdocs()

ggsave("PO.png", width = 5, height = 5)

# wykres dla K15
ggplot(filter(dane_z_html, Osrodek %in% 
                c("CBOS","Estymator","IBRiS","IPSOS","Kantar MB","Kantar Public","MillwardBrown","Pollster","TNS Polska")
              & partia == "K15"),
       aes(x = Publikacja, y = poparcie)) +
  ylim(0, 60) +
  geom_point() +
  geom_smooth(se = FALSE) +
  facet_wrap(~ Osrodek) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y")  +
  theme_gdocs()

ggsave("K15.png", width = 5, height = 5)

# wykres dla PSL
ggplot(filter(dane_z_html, Osrodek %in% 
                c("CBOS","Estymator","IBRiS","IPSOS","Kantar MB","Kantar Public","MillwardBrown","Pollster","TNS Polska")
              & partia == "PSL"),
       aes(x = Publikacja, y = poparcie)) +
  ylim(0, 60) +
  geom_point() +
  geom_smooth(se = FALSE) +
  facet_wrap(~ Osrodek) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y")  +
  theme_gdocs()

ggsave("PSL.png", width = 5, height = 5)

# wykres osrodek_metoda

ggplot(filter(dane_z_html, Osrodek %in% c("CBOS","Estymator","IBRiS","IPSOS","Kantar MB","Kantar Public","MillwardBrown","Pollster","TNS Polska")),
       aes(Metoda, Osrodek)) +
  geom_tile(aes(fill = liczba))

# zadanie 45

ggplot(filter(dane_z_html, Osrodek %in% 
                c("CBOS","Estymator","IBRiS","IPSOS","Kantar MB","Kantar Public","MillwardBrown","Pollster","TNS Polska")
              & Metoda == "CATI" & partia %in% c("PiS", "PO", "K15", "PSL")),
       aes(x = Publikacja, y = poparcie)) +
  ylim(0, 60) +
  geom_point() +
  geom_smooth(se = FALSE) +
  facet_grid(partia ~ Osrodek) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y")  +
  theme_gdocs()
