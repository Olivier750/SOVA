

setwd("C:/Users/sophie/Documents/Projet_SNCF/Shiny")
#install.packages("shinydashboard")
library(shinydashboard)



dashboardPage(
  dashboardHeader(title = "Prevision des Defauts "),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Projet SOVA", icon = icon("file-code-o"), href = "https://github.com/Olivier750/SOVA/blob/master/Readme.md"),
      
      menuItem("Tableau de donnees", tabName = "list_donnees",icon=icon("table")),
      
      menuItem("Statistiques Descriptives",icon=icon("bar-chart-o"),
               menuSubItem("ACM",tabName ="ACM"),
               menuSubItem("AFC",tabName ="AFC")
               #menuSubItem("Profil",tabName ="D1"),
               #menuSubItem("AGE",tabName ="D2"),
               #menuSubItem("Vitesse",tabName ="D3"),
               #menuSubItem("Rayon Courbure",tabName ="D4"),
               #menuSubItem("Ligne",tabName ="D5"),
               #menuSubItem("Voie",tabName ="D6"),
               #menuSubItem("Position",tabName ="D7")
      ),
      menuItem("Modelisation", tabName = "glyphicon-edit",icon=icon("fal fa-calculator"),
               menuSubItem("Logistique",tabName ="MOD1"),
               menuSubItem("XGBoost",tabName ="MOD2"),
               menuSubItem("Neural Network",tabName ="MOD3"),
               menuSubItem("SVM",tabName ="MOD4")
      ),
      menuItem("Cartographie", tabName = "font-awesome",icon=icon("map"))
    )# fin sidebarMenu
  ), # fin dashboardSidebar
  
  dashboardBody(
   
    
    tabItems(
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
            br(), column(12, div(DT::dataTableOutput("contenus"), style = "font-size:80%"))
    ), # fin tabItem
      
      tabItem(tabName = "glyphicon-edit",
            # Boxes need to be put in a row (or column)
            fluidRow(
                box(plotOutput("plot1", height = 250)),
                box(
                  title = "Controls",
                  sliderInput("slider", "Number of observations:", 1, 100, 50)
                )
              )
      ),
    
    #tabItem(tabName = "font-awesome",
        #fluidRow(
        #dashboardBody(leafletOutput("mymap"))
        #)),
    tabItem(tabName = "ACM","ACM"),
    
    
    tabItem(tabName = "MOD1",radioButtons("rd_logi",
                                          label = "Choix :",
                                          choices=c("2 modalites"="logi_2","3 modalites"="logi_3"),
                                          selected = "logi_2"),
                    plotOutput("logi")
    ),

    tabItem(tabName = "MOD2","MOD2"),
    tabItem(tabName = "MOD3","MOD3"),
    tabItem(tabName = "MOD4",radioButtons("rd_svm",
                                          label = "Choix :",
                                          choices=c("2 modalites"="SVM_2","3 modalites"="SVM_3"),
                                          selected = "SVM_2"),
            plotOutput("svm")
    )
    
    ) # fin tabItems
    
    

      
    )
    
    )
  
