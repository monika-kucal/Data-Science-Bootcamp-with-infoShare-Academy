library(shiny)
library(ggplot2)
library(plyr)
library(dplyr)
library(nlme)
library(DT)
library(lazyeval)

mtcars <- cbind(mtcars, "all" = 1)
mtcars_data <- mtcars
mtcars_data[, c("cyl", "vs", "am", "gear", "carb")] <- lapply(mtcars_data[, c("cyl", "vs", "am", "gear", "carb")], factor)
mtcars_data$all <- factor(1)

ui <- fluidPage(
  
  sidebarLayout(
    
    sidebarPanel(
    
    selectInput(inputId = "x",
                label = "X-axis",
                choices = c(
                  "Miles/(US) gallon" = "mpg",
                  "Displacement (cu.in.)" = "disp",
                  "Gross horsepower" = "hp",
                  "Rear axle ratio" = "drat",
                  "Weight (1000 lbs)" = "wt",
                  "1/4 mile time" = "qsec"),
                selected = "mpg"),
    
    selectInput(inputId = "y",
                label = "Y-axis",
                choices = c(
                  "Miles/(US) gallon" = "mpg",
                  "Displacement (cu.in.)" = "disp",
                  "Gross horsepower" = "hp",
                  "Rear axle ratio" = "drat",
                  "Weight (1000 lbs)" = "wt",
                  "1/4 mile time" = "qsec"),
                selected = "disp"),
    
    selectInput(inputId = "z",
                label = "Group by:",
                choices = c(
                  "All" = "all",
                  "Number of cylinders" = "cyl",
                  "Straight engine" = "vs",
                  "Manual transmission" = "am",
                  "Number of forwar gears" = "gear",
                  "Number of carburetors" = "carb"),
                selected = "all")
    
    ),
    
    mainPanel(
    
      h3("Scatterplot:"),
      
      plotOutput(outputId = "scatterplot"),
      
      h3("Correlation:"),
      
      verbatimTextOutput(outputId = "correlation"),
      
      h3("Linear regression:"),
      
      verbatimTextOutput(outputId = "lmresults")
    )
  )
)

server <- function(input, output) {
  
  corr <- reactive({
    z <- mtcars %>% pull(input$z)
    x <- mtcars %>% pull(input$x)
    y <- mtcars %>% pull(input$y)
    r <- cbind(z, x, y)
    print(r)
  })
  
  lmres <- reactive({
    x <- mtcars_data %>% pull(input$x)
    y <- mtcars_data %>% pull(input$y)
    summ <- lm(y ~ x, mtcars_data)
    print(summ)
  })
  
  output$scatterplot <- renderPlot({
    ggplot(data = mtcars_data, aes_string(x = input$x, y = input$y, color = input$z)) +
      geom_point() +
      geom_smooth(method = "lm")
  })
  
  output$lmresults <- renderPrint({
    lmres()
  })
  
  output$correlation <- renderPrint({
    corr()
  })

}

shinyApp(ui = ui, server = server)