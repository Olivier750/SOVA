setwd("C:/Users/D75275/Documents/OneDrive - EDF/Projet SOVA/Shiny")

packages <- c("shiny", "shinydashboard", "RSQLite", "rgdal", "dplyr", "leaflet")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))  
}

library(shinydashboard)
library(leaflet)
library(RSQLite)
library(rgdal)
library(dplyr)
library(shiny)

#-------------------- MENU------------------------------------------------------

dashboardPage(skin = "blue",
  dashboardHeader(title = "Prevision des Defauts "),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Projet SOVA", tabName = "README", icon = icon("file-code-o")),
      
      menuItem("Tableau de donnees", tabName = "list_donnees",icon=icon("table")),
      
      menuItem("Statistiques Descriptives",icon=icon("bar-chart-o"),
               menuSubItem("ACM",tabName ="ACM"),
               menuSubItem("AFC",tabName ="AFC")
      ),
      menuItem("Modelisation", tabName = "MODEL",icon=icon("fal fa-calculator"),
               menuSubItem("3 modalites",tabName ="MOD3"),
               menuSubItem("2 modalites",tabName ="MOD2")
      ),
      menuItem("Cartographie", tabName = "CartoDefautRail",icon=icon("map"))
    )# fin sidebarMenu
  ), # fin dashboardSidebar
  
  
#-------------------- BODY ------------------------------------------------------  
  
  dashboardBody(
     tabItems(
       #--------- Affichage read me ---------------------------------------
       tabItem(tabName = "README",
               fluidPage(
                 dashboardBody(htmlOutput("readme_html"),
                               width = "100%", height = "100%",side="left")
               )
       ),
       
       #-------- Chargement du fichier de travail --------------------------   
       tabItem(tabName = "list_donnees",
            fluidRow(column(2,
                            dashboardSidebar(  # Sidebar panel for inputs ----
                                                # Input: Select a file ----
                                                fileInput("file_defaut", "Upload file", multiple = TRUE,
                                                          accept = c("text/csv", "text/comma-separated-values,text/plain",".csv")
                                                ) # fin fileInput
                             ) #fin dashboardSidebar
             ) # fin column
             ), # fin fluidRow
             br(), br(),br(),br(),br(),br(),br(),br(),br(),column(12, div(DT::dataTableOutput("contenus"), style = "font-size:80%"))
     ), # fin tabItem

     #-------- Chargement du fichier de travail --------------------------         
      # tabItem(tabName = "MODEL",
      #       # Boxes need to be put in a row (or column)
      #       fluidRow(
      #           box(plotOutput("plot1", height = 250)),
      #           box(
      #             title = "Controls",
      #             sliderInput("slider", "Number of observations:", 1, 100, 50)
      #           )
      #         )
      # ),
    
  #--------- Stats descriptives ---------------------------------------
  #--------- ACM ---------------------------------------
    #tabItem(tabName = "ACM",
            #titlePanel("ACM", width=4),
            #mainPanel(htmlOutput("acm_html"),
                      #width = "100%", height = "100%",side="left"
                      #)
    #),
    
    tabItem(tabName = "ACM",
            fluidPage(
              dashboardBody(htmlOutput("acm_html"),
                            width = "100%", height = "100%",side="left")
            )
    ),
  
  #--------- Modelisation 3 modalites  ---------------------------------------          
    tabItem(tabName = "MOD3",radioButtons("rd_mod3",
                                          label = "Choix :",
                                          choices=c("Logistique"="logi3",
                                                    "Elastic net"="elnet3",
                                                    "XGBoost"="xgb3",
                                                    "Neural Network"="resneur3",
                                                    "SVM"="svm3"),
                                          selected = "logi3"),
            dashboardBody(htmlOutput("mod_3"),
                          width = "100%", height = "100%",side="left")
    ),
    #--------- 2 modalites  ---------------------------------------   
    tabItem(tabName = "MOD2",radioButtons("rd_mod2",
                                          label = "Choix :",
                                          choices=c("Logistique"="logi2",
                                                    "Elastic net"="elnet2",
                                                    "XGBoost"="xgb2",
                                                    "Neural Network"="resneur2",
                                                    "SVM"="svm2",
                                                    "Random Forest"="rd_forest2"),
                                          selected = "logi2"),
            dashboardBody(htmlOutput("mod_2"),
                          width = "100%", height = "100%",side="left")
    ),
    
    
    
    #--------- Cartographie ---------------------------------------
    
  tabItem(tabName = "CartoDefautRail",
          h2("Carte des défauts (Réseau Nord Ile-de-France)"),
          #1ere Ligne
          fluidRow(
            box(width=4,
                title = "La voie",
                status = "info",
                solidHeader = TRUE,
                collapsible = TRUE,
                "Choisissez la voie", br(), "à afficher sur la carte",
                uiOutput("SelectionLignes"),
                checkboxGroupInput(inputId = "TypeDefaut",label = NULL,inline = TRUE,
                                   choices = c(NR = "NR",
                                               E = "E",
                                               O = "O",
                                               X1 = "X1",
                                               X2 = "X2",
                                               S = "S"),
                                   selected = c("NR", "E", "O", "X1", "X2", "S")
                )
            ),
            box(width=8,
                status = "info",
                solidHeader = TRUE,
                uiOutput("iboxNR"),
                uiOutput("iboxE"),
                uiOutput("iboxO"),
                uiOutput("iboxX1"),
                uiOutput("iboxX2"),
                uiOutput("iboxS")
            )
          ),
          #2eme Ligne
          fluidRow(
            leafletOutput("CarteLigne", width = "100%")
          )
  )
  
  
  
  
    #tabItem(tabName = "font-awesome",
    #fluidRow(
    #dashboardBody(leafletOutput("mymap"))
    #))
    
    ) # fin tabItems
    
    

      
  )# fin dashboardBody
    
)# fin dashboardPage
  
