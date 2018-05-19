library(shiny)
library(shinydashboard)
source('initData.R')

data <- init_data()

ui <- dashboardPage(
  # HEADER
  ################################################################################################
  dashboardHeader(title = "Poll results"),
  # SIDEBAR
  ################################################################################################
  dashboardSidebar(
    sidebarMenu(
      menuItem("Results", tabName = "results", icon = icon("dashboard"), badgeLabel = "new", badgeColor = "green"),
      menuItem("Parties", tabName = "parties", icon = icon("th")),
      menuItem("Text mining", tabName = "text_mining", icon = icon("th")),
      menuItem("Text mining - sentiment", tabName = "text_mining_sentiment", icon = icon("th")),
      menuItem("Twitter", tabName = "twitter_hashtags", icon = icon("th"))
    )
  ),
  
  # BODY
  ################################################################################################
  dashboardBody(
    tabItems(
      # Parties TAB
      ################################################################################################
      tabItem(tabName = "parties",
              fluidRow(
                column(width = 12, 
                       selectInput(inputId = "partyTypeSelector",
                                              label = "Choose a party type:",
                                              choices = (c("PiS", "PO", "PSL", "K15"))),
                       plotOutput("filteredPlot")
              ))),
      
      # Results TAB
      ################################################################################################
      tabItem(tabName = "results",
              fluidRow(
                column(width = 6, 
                       selectInput(inputId = "principalTypeSelector",
                                   label = "Choose a principal type:",
                                   choices = (data$Zleceniodawca)),
                       selectInput(inputId = "pollCenterTypeSelector",
                                   label = "Choose a poll center type:",
                                   choices = (data$Osrodek)),
                       dataTableOutput("results_table")
                )
              )
      ),
      
      # SENTIMENT TAB
      ################################################################################################
      tabItem(tabName = "text_mining",
              fluidRow(
                column(width = 6, plotOutput("frequencies")),
                column(width = 6, plotOutput("wordcloud"))
              ),
              fluidRow(width = 6, numericInput(inputId = 'frequency', label='Number of occurencies:', value = 5),
                       dataTableOutput("freqTerms")),
              fluidRow(width = 6, 
                       textInput(inputId = 'word', label='Word: '),
                       numericInput(inputId = 'correlationValue', label='Correlation value:', value = 0.5),
                       dataTableOutput("correlation"))
      ),
      # TEST MINING - SENTIMENT TAB
      ################################################################################################
      tabItem(tabName = "text_mining_sentiment",
              fluidRow(
                column(
                  width = 6,
                  plotOutput("emotions")
                ),
                column(width = 6,
                      verbatimTextOutput("sentiment")))
              ),
      # TWITTER
      ################################################################################################
      tabItem(tabName = "twitter_hashtags",
              fluidRow(
                ))
      )
      )
    )