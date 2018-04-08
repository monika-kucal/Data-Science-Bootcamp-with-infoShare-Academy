library(shiny)
library(ggthemes)
source('initData.R')

server <- shinyServer(function(input, output) {
  
  data <- init_data()
  
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
  
  
  
})
