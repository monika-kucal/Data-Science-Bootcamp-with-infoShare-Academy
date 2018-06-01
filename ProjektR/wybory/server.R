library(shiny)
library(ggthemes)
source('initData.R')

server <- shinyServer(function(input, output) {
  
  data <- init_data()
  df_mining <- init_mining()
  dtm <- init_dtm()
  df_emotions <- prepare_data_emotions(df_mining)
  df_sentiment <- prepare_data_sentiment(df_mining)
  
  ############PARTIES##################
  
  output$filteredPlot <- renderPlot({
    ggplot(filter(data, Osrodek %in% 
                    c("CBOS","Estymator","IBRiS","IPSOS","Kantar MB","Kantar Public","MillwardBrown","Pollster","TNS Polska")
                  & partia == input$partyTypeSelector),
           aes(x = Publikacja, y = poparcie)) +
      ylim(0, 60) +
      geom_point() +
      geom_smooth(se = FALSE) +
      facet_wrap(~ Osrodek) +
      scale_x_date(date_breaks = "1 year", date_labels = "%Y")  +
      theme_gdocs()
  })
  
  output$IBRISpercentage <- renderPlot({
    ggplot(filter(data, Osrodek %in% 
                    c("CBOS","Estymator","IBRiS","IPSOS","Kantar MB","Kantar Public","MillwardBrown","Pollster","TNS Polska")
                  & Metoda == "CATI" & partia %in% c("PiS", "PO", "K15", "PSL")),
           aes(x = Publikacja, y = poparcie)) +
      ylim(0, 60) +
      geom_point() +
      geom_smooth(se = FALSE) +
      facet_grid(partia ~ Osrodek) +
      scale_x_date(date_breaks = "1 year", date_labels = "%Y")  +
      theme_gdocs()
  })
  
  ###############RESULTS#############
  
  output$results_table <- renderDataTable({
    filter(data, data$Osrodek == input$pollCenterTypeSelector & data$Zleceniodawca == input$principalTypeSelector)
  })
  
  ########TEXT MINING#################
  
  output$frequencies <- renderPlot({
    ggplot(data = filter(df_mining, freq > 1), mapping = aes(x = reorder(word, -freq), y = freq)) +
      geom_bar(stat = "identity") +
      xlab("Word") +
      ylab("Word frequency") +
      theme(axis.text.x=element_text(angle=90, hjust=1))
  })
  
  output$wordcloud <- renderPlot({
    wordcloud(words=df_mining$word, freq=df_mining$freq, min.freq=1, max.words=50, 
              random.order=TRUE, rot.per=0.1, colors=brewer.pal(8,"Dark2"))
  })
  
  output$freqTerms <- renderDataTable({
    data.frame(word=findFreqTerms(dtm, lowfreq = input$frequency))
  })
  
  output$correlation <- renderDataTable({
    data.frame(cbind(rownames(as.data.frame(findAssocs(dtm, terms = input$word, corlimit = input$correlationValue))),as.data.frame(findAssocs(dtm, terms = input$word, corlimit = input$correlationValue))))
  })
  
  output$emotions <- renderPlot({
    ggplot(data = df_emotions, mapping = aes(x = emotions, 
                                             y = sent_value, 
                                             color = emotions, fill = sent_value)) +
      geom_bar(stat = "identity") +
      xlab("emotion") +
      ylab("words count") +
      theme(axis.text.x=element_text(angle=90, hjust=1))
  })
  
  output$sentiment <- renderPrint({
    print(getSentiment(df_mining, df_sentiment))
  })
  
  output$username_table <- renderDataTable({
    twitter_username(input$hashtagTestInput)
  })
  
  output$sources_table <- renderDataTable({
    twitter_sources(input$hashtagTestInput)
  })
  
  output$top_tweets_table <- renderDataTable({
    twitter_top_tweets(input$hashtagTestInput)
  })
  
})
