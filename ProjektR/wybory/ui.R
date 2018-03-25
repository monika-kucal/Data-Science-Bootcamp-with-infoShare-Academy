#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

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
      tabItem(tabName = "results"
              
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