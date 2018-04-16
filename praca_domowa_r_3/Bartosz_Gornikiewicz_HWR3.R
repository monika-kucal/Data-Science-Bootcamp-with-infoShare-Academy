library(shiny)
library(shinythemes)
library(readr)
library(ggplot2)
library(stringr)
library(plyr)
library(dplyr)
library(DT)
library(tools)
library(nlme)


mtcars_data <- mtcars
mtcars_data$all <- 1
mtcars_data[, c("cyl", "vs", "am", "gear", "carb", "all")] <- lapply(mtcars_data[, c("cyl", "vs", "am", "gear", "carb", "all")], as.character)

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

  output$scatterplot <- renderPlot({
    ggplot(data = mtcars_data, aes_string(x = input$x, y = input$y, color = input$z)) +
      geom_point() +
      geom_smooth(method = "lm")
  })
  
  corr <- reactive({
    
    GROUP <- mtcars_data %>% pull(input$z)
    x <- mtcars_data %>% pull(input$x)
    y <- mtcars_data %>% pull(input$y)
    df <- data.frame(GROUP, x, y)
    df %>% group_by(GROUP) %>% summarise(COR = cor(x, y)) %>% as.data.frame()
    
  })
  
  output$correlation <- renderPrint({
    corr()
  })
  
  lmres <- reactive({
    GROUP <- mtcars_data %>% pull(input$z)
    x <- mtcars_data %>% pull(input$x)
    y <- mtcars_data %>% pull(input$y)
    df <- data.frame(GROUP, x, y)
    models <- dlply(df, "GROUP", function(df) {lm(y ~ x, df)})
    ldply(models, coef)
  })
  
  
  output$lmresults <- renderPrint({
    lmres()
  })
  
}

shinyApp(ui = ui, server = server)