
setwd("E:/Others/Formation Data Science/Projet/Nouveau dossier/Shiny_App/")
library(shinydashboard)

dashboardPage(
  dashboardHeader(title = "Prevision des Defauts "),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Tableau de donnees", tabName = "dashboard2",icon=icon("table")),
      menuItem("Modelisation", tabName = "glyphicon-edit",icon=icon("bar-chart-o")),
      menuSubItem("Logistique",tabName ="MOD1"),
      menuSubItem("XGBoost",tabName ="MOD2"),
      menuSubItem("Neural Network",tabName ="MOD3"),
      menuItem("Cartographie", tabName = "font-awesome",icon=icon("map"))
      
    )
  ),
  dashboardBody(
    
    tags$head(tags$style(HTML('
     /* other links in the sidebarmenu when hovered */
         .skin-blue .main-sidebar .sidebar .sidebar-menu a:hover{
                              background-color: #ff69b4;
         }
 /* toggle button when hovered  */                    
         .skin-blue .main-header .navbar .sidebar-toggle:hover{
                              background-color: blue;
         }
  /* active selected tab in the sidebarmenu */
        .skin-blue .main-sidebar .sidebar .sidebar-menu .active a{
                              background-color: #ff69b4;
        }

                              
                              '))),
    tabItems(
      tabItem(tabName = "dashboard2",
              fluidRow(column(2,
                              dashboardSidebar(
                                # Sidebar panel for inputs ----
                                
                                # Input: Select a file ----
                                fileInput("DEF1", "Upload file",
                                          multiple = TRUE,
                                          accept = c("text/csv",
                                                     "text/comma-separated-values,text/plain",
                                                     ".csv")))
              )), br(), br(), br(), br(), br(), br(), br(), br(), br(), br(),
              column(12,
                     div(DT::dataTableOutput("contenus"), style = "font-size:80%")
              )
              )
      ,
      tabItem(tabName = "glyphicon-edit",
              # Boxes need to be put in a row (or column)
              fluidRow(
                box(plotOutput("plot1", height = 250)),
                
                box(
                  title = "Controls",
                  sliderInput("slider", "Number of observations:", 1, 100, 50)
                )
              )
      )
      ,
      tabItem(tabName = "font-awesome",
              fluidRow(
              dashboardBody(leafletOutput("mymap"))
      )),
      tabItem(tabName = "MOD1",
              "MOD1"
      ),
      tabItem(tabName = "MOD2",
              "MOD2"
      ),
      tabItem(tabName = "MOD3",
              "MOD3"
      )
    )
  )
  
)