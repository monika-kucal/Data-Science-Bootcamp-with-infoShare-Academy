library(shiny)
library(shinydashboard)

# Define UI for application that draws a histogram
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
      # Results TAB
      ################################################################################################
      tabItem(tabName = "results",
              fluidRow(
                column(width = 6, plotOutput("pisPlot")),
                column(width = 6, plotOutput("poPlot"))
              ),
      
      # Parties TAB
      ################################################################################################
      tabItem(tabName = "parties"
              
      ),
      
      # SENTIMENT TAB
      ################################################################################################
      tabItem(tabName = "text_mining"
              
      )
    )
  )
)
)