library(tm)
library(SnowballC)
library(wordcloud)
library(RColorBrewer)
library(tidyverse)
library(scales)


filepath<-"https://raw.githubusercontent.com/infoshareacademy/jdsz1-materialy-r/master/20180323_ellection_pools/parties_en.txt?token=Ah08CiinvlMOWhE5MCqg_UyAvTVF7z8Dks5awLUmwA%3D%3D"

text<-readLines(filepath)

docs<-Corpus(VectorSource(text))

inspect(docs)

docs[[1]]$content
docs[[3]]$content

docs<-tm_map(docs,tolower)
docs<-tm_map(docs,removeNumbers)
docs<-tm_map(docs,removeWords, stopwords("english"))
docs<-tm_map(docs,removePunctuation)
docs<-tm_map(docs,stripWhitespace)
docs<-tm_map(docs,removeWords,c("th"))


dtm<-TermDocumentMatrix(docs)
m<-as.matrix(dtm)
v<-sort(rowSums(m),decreasing=TRUE)
d<-data.frame(word=names(v),freq=v)

wordcloud(words=d$word, freq=d$freq, min.freq=1, max.words=50, 
          random.order=TRUE, rot.per=0.1, colors=brewer.pal(8,"Dark2"))



# flip coordinates
ggplot(data = filter(d, freq > 1), mapping = aes(x = reorder(word, freq), y = freq)) +
  geom_bar(stat = "identity") +
  xlab("Word") +
  ylab("Word frequency") +
  coord_flip()
# rotate label
ggplot(data = filter(d, freq > 1), mapping = aes(x = reorder(word, freq), y = freq)) +
  geom_bar(stat = "identity") +
  xlab("Word") +
  ylab("Word frequency") +
  theme(axis.text.x=element_text(angle=90, hjust=1))
