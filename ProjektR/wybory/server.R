library(shiny)
source('initData.R')

server <- shinyServer(function(input, output) {
  
  data <- init_data()
   
  output$pisPlot <- renderPlot({
    
    ggplot(filter(data, Osrodek %in% 
                    c("CBOS","Estymator","IBRiS","IPSOS","Kantar MB","Kantar Public","MillwardBrown","Pollster","TNS Polska")),
           aes(x = Publikacja, y = PiS)) +
      ylim(0, 60) +
      geom_point() +
      geom_smooth(se = FALSE) +
      facet_wrap(~ Osrodek)
  })
  
  output$poPlot <- renderPlot({
    
    ggplot(filter(data, Osrodek %in% 
                    c("CBOS","Estymator","IBRiS","IPSOS","Kantar MB","Kantar Public","MillwardBrown","Pollster","TNS Polska")),
           aes(x = Publikacja, y = PO)) +
      ylim(0, 60) +
      geom_point() +
      geom_smooth(se = FALSE) +
      facet_wrap(~ Osrodek)
  })
  
})
