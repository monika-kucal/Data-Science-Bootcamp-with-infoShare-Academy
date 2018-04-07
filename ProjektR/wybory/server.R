library(shiny)
library(ggthemes)
source('initData.R')

server <- shinyServer(function(input, output) {
  
  data <- init_data()
  
  output$filteredPlot <- renderPlot({
    ggplot(filter(data, Osrodek %in% 
                    c("CBOS","Estymator","IBRiS","IPSOS","Kantar MB","Kantar Public","MillwardBrown","Pollster","TNS Polska")),
           aes(x = Publikacja, y = input$partyTypeSelector)) +
      ylim(0, 60) +
      geom_point() +
      geom_smooth(se = FALSE) +
      facet_wrap(~ Osrodek) +
      scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
      theme_hc()
  })
  
  output$results_table <- renderDataTable({
    filter(data, data$Osrodek == input$pollCenterTypeSelector & data$Zleceniodawca == input$principalTypeSelector)
  })
  
})
