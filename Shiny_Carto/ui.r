library(shiny)
library(shinydashboard)
library(RSQLite)
library(rgdal)
library(dplyr)
library(leaflet)

##LA PAGE
dashboardPage(
  #################################################"
  ##L'ENTETE
  #################################################"
  dashboardHeader(
    
    
  ), # Fin dashboardHeader
  
  
  #################################################"
  ##LE MENU
  #################################################"
  dashboardSidebar(
    sidebarMenu(
      menuItem("Carte", tabName = "CartoDefautRail", icon = icon("map"))
    ) # Fin sidebarMenu
  ), # Fin dashboardSidebar
   
  
  #################################################"
  ##LE CORPS DE LA PAGE
  #################################################"
  dashboardBody(
    tabItems(
      
      tabItem(tabName = "CartoDefautRail",
              h2("Carte des défauts (Réseau Nord Ile-de-France)"),
              fluidRow(
                box(width=4,
                  title = "La voie",
                  status = "info",
                  solidHeader = TRUE,
                  collapsible = TRUE,
                  "Choisissez la voie", br(), "à afficher sur la carte",
                  uiOutput("SelectionLignes"),
                  
                  
                  checkboxGroupInput(inputId = "TypeDefaut",label = NULL,inline = TRUE,
                                     choices = c(E = "E",
                                                 NR = "NR",
                                                 O = "O",
                                                 S = "S",
                                                 X1 = "X1",
                                                 X2 = "X2"),
                                     selected = c("E", "NR", "O", "S", "X1", "X2")
                  )
                  
                  
                  ),
                
                
                box(width=8,
                    status = "info",
                    solidHeader = TRUE,
                    uiOutput("iboxE"),
                    uiOutput("iboxNR"),
                    uiOutput("iboxO"),
                    uiOutput("iboxS"),
                    uiOutput("iboxX1"),
                    uiOutput("iboxX2")
                 )

                ),
              fluidRow(
                leafletOutput("CarteLigne", width = "100%")
                )
              )
      )# Fin tabItems
  )# Fin dashboardBody
)#fin dashboardPage