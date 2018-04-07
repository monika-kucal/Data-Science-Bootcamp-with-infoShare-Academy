library(shiny)
library(shinydashboard)
source('initData.R')

data <- init_data()

ui <- dashboardPage(
  # HEADER
  ################################################################################################
  dashboardHeader(title = "Wyniki sondażów"),
  # SIDEBAR
  ################################################################################################
  dashboardSidebar(
    sidebarMenu(
      menuItem("Results", tabName = "results", icon = icon("dashboard"), badgeLabel = "new", badgeColor = "green"),
      menuItem("Parties", tabName = "parties", icon = icon("th")),
      menuItem("Text mining", tabName = "text_mining", icon = icon("th"))
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
                column(width = 6, selectInput(inputId = "partyTypeSelector",
                                              label = "Choose a party type:",
                                              choices = (c("PiS", "PO", "PSL", "K15"))),
                                              plotOutput("filteredPlot"))
                #column(width = 6, plotOutput("pisPlot")),
                #column(width = 6, plotOutput("poPlot")),
                #column(width = 6, plotOutput("k15Plot")),
                #column(width = 6, plotOutput("pslPlot"))
              )),
      
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
      tabItem(tabName = "text_mining"
              
      )
    )
  )
)