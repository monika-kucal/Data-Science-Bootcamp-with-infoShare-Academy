library(tm)
library(SnowballC)
library(wordcloud)
library(RColorBrewer)
library(tidyverse)
library(scales)
library(syuzhet)

# TEXT MINING

filepath<-"https://raw.githubusercontent.com/infoshareacademy/jdsz1-materialy-r/master/20180323_ellection_pools/parties_en.txt?token=Ah08CotCp9MtwF5sLnNwYV4o2afRCDdMks5a0eDIwA%3D%3D"

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



# JDSZ1RA-77
# plot bar chart which show frequencies for top 50 words in file mentioned above
barplot <- ggplot(data = filter(d, freq > 1), mapping = aes(x = reorder(word, -freq), y = freq)) +
  geom_bar(stat = "identity") +
  xlab("Word") +
  ylab("Word frequency") +
  theme(axis.text.x=element_text(angle=90, hjust=1))


# JDSZ1RA-78
# wordcloud for words menetioned in previous file
wordcloud <- wordcloud(words=d$word, freq=d$freq, min.freq=1, max.words=50, 
          random.order=TRUE, rot.per=0.1, colors=brewer.pal(8,"Dark2"))

# JDSZ1RA-79

#input:
#  numericInput
#output:
#  data table with min. frequency according to numbericInput

frequency <- data.frame(word=findFreqTerms(dtm, lowfreq = 5))


# JDSZ1RA-80
#Goal: I need to check associations between words. I'd like to input text (terms) to and correlation limit, to check their association with words imported in text file from previous file
#input:
#    textInput (to input terms)
#    numericInput (to input corLimit)
#output:
#    data table with results from findAssocs

associations <- data.frame(findAssocs(dtm, terms = c("politics"), corlimit = 0.5))


# JDSZ1RA-81
# Goal: I need to see emotions from text
# please create a new tab "text mining - sentiment"
# please add plot to show emotions from a text imported in previous task


df_sentiment<-get_nrc_sentiment(as.String(d$word)) 

df_sentiment_transposed <- t(df_sentiment) # transpose data frame from columns to rows
df_sentiment_final <- data.frame(emotions=row.names(df_sentiment_transposed), 
                                 sent_value=df_sentiment_transposed, row.names=NULL) # prepare final data frame with emotions in 1st column, values in 2nd
df_emotions <- df_sentiment_final[1:8,]
df_sentiments <- df_sentiment_final[9:10,]


# plot emotions
ggplot(data = df_emotions, mapping = aes(x = emotions, 
                                         y = sent_value, 
                                         color = emotions, fill = sent_value)) +
  geom_bar(stat = "identity") +
  xlab("emotion") +
  ylab("words count") +
  theme(axis.text.x=element_text(angle=90, hjust=1))


# JDSZ1RA-82
# Goal: I need to see % sentiment from text
# please add data to "text mining - sentiment" tab:
# infoBoxOutput (% of positives)
# infoBoxOutput (% of negatives)

negative_perc <- df_sentiments[1,2]/sum(df_sentiments[,2])
positive_perc <- df_sentiments[2,2]/sum(df_sentiments[,2])
not_classified_perc <- (dim(d)[1] - sum(df_sentiments[,2]))/dim(d)[1]
    