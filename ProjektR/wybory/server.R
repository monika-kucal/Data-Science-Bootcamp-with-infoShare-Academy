library(shiny)
library(ggthemes)
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
  
  output$k15Plot <- renderPlot({
    ggplot(filter(data, Osrodek %in% 
                    c("CBOS","Estymator","IBRiS","IPSOS","Kantar MB","Kantar Public","MillwardBrown","Pollster","TNS Polska")),
           aes(x = Publikacja, y = K15)) +
      ylim(0, 60) +
      geom_point() +
      geom_smooth(se = FALSE) +
      facet_wrap(~ Osrodek) +
      scale_x_date(date_breaks = "1 year", date_labels = "%Y")
  })
  
  output$pslPlot <- renderPlot({
    ggplot(filter(data, Osrodek %in% 
                    c("CBOS","Estymator","IBRiS","IPSOS","Kantar MB","Kantar Public","MillwardBrown","Pollster","TNS Polska")),
           aes(x = Publikacja, y = PSL)) +
      ylim(0, 60) +
      geom_point() +
      geom_smooth(se = FALSE) +
      facet_wrap(~ Osrodek) +
      scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
      theme_hc()
  })
  
})
