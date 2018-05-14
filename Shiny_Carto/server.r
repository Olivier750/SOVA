library(shiny)
library(shinydashboard)
library(RSQLite)
library(rgdal)
library(dplyr)
library(leaflet)

sqldrv <- dbDriver("SQLite")
con <- dbConnect(sqldrv, dbname = "C:/Users/D75275/Documents/OneDrive - EDF/Projet SOVA/Database/SOVA_db.sqlite", loadable.extensions = TRUE)
Map_From_DB = readOGR(dsn="C:/Users/D75275/Documents/OneDrive - EDF/Projet SOVA/Database/SOVA_db.sqlite",layer="defauts", require_geomType = "wkbPoint")
Liste_des_Lignes <- RSQLite::dbGetQuery(conn = con, "SELECT DISTINCT LIGNE_VOIE FROM DEFAUTS UNION SELECT \"'Toutes les voies'\" ORDER BY LIGNE_VOIE DESC")

function(input, output, session)
  {
  #Liste déroulante des lignes
  output$SelectionLignes <- renderUI({
    selectInput("LIGNE", "Selection de la ligne", Liste_des_Lignes)
    })
  
  #Filtre sur les lignes
  FiltreLigne2 <- reactive({
    if(input$LIGNE == "'Toutes les voies'"){
      Map_From_DB
    } else {
        subset(Map_From_DB, Map_From_DB$LIGNE_VOIE == input$LIGNE)}
    })
  
  #Filtre sur les types de défaut
  FiltreLigne <- reactive({
    subset(FiltreLigne2(), FiltreLigne2()$TYPE_CLASSEMENT %in% input$TypeDefaut)
    })
  
  Rail_Icone <- iconList(
    NR = makeIcon("NR.png", "NR.png", 50, 50),
    E = makeIcon("E.png", "E.png", 50, 50),
    O = makeIcon("O.png", "O.png", 50, 50),
    X1 = makeIcon("X1.png", "X1.png", 50, 50),
    X2 = makeIcon("X2.png", "X2.png", 50, 50),
    S = makeIcon("S.png", "S.png", 50, 50)
    )
  
  pal <- colorFactor(c("green", "yellow", "orange","navy","red","black"), 
                     domain = c("NR", "E", "O","X1", "X2", "S"))
  
  output$iboxNR <- renderUI({
    infoBox(
      "NR",
      sum(FiltreLigne()$TYPE_CLASSEMENT=="NR"),
      icon = icon("credit-card"),
      color="green"
    )})  
  
  output$iboxE <- renderUI({
    infoBox(
      "E",
      sum(FiltreLigne()$TYPE_CLASSEMENT=="E"),
      icon = icon("credit-card"),
      color = "yellow"
      )})  
  
  output$iboxO <- renderUI({
      infoBox(
      "O",
      sum(FiltreLigne()$TYPE_CLASSEMENT=="O"),
      icon = icon("credit-card"),
      color="orange"
      )})  
  
    output$iboxX1 <- renderUI({
      infoBox(
      "X1",
      sum(FiltreLigne()$TYPE_CLASSEMENT=="X1"),
      icon = icon("credit-card"),
      color="navy"
      )})  

    output$iboxX2 <- renderUI({
      infoBox(
      "X2",
      sum(FiltreLigne()$TYPE_CLASSEMENT=="X2"),
      icon = icon("credit-card"),
      color="red"
      )})
  
    output$iboxS <- renderUI({
      infoBox(
        "S",
        sum(FiltreLigne()$TYPE_CLASSEMENT=="S"),
        icon = icon("exclamation-triangle"),
        color="black"
      )})      

    output$CarteLigne <- renderLeaflet({
      leaflet() %>%
        addTiles() %>%
        addCircleMarkers(data = FiltreLigne(),
                         color = ~pal(FiltreLigne()$TYPE_CLASSEMENT),
                         popup = paste(sep = "<br/>",
                                       paste0("<b>Défaut de type  : ", as.character(FiltreLigne()$TYPE_CLASSEMENT),"</b>"),"",
                                       paste0("Nom de la ligne : ",  as.character(FiltreLigne()$LIGNE_VOIE)),
                                       paste0("Mètre depuis le départ : ", as.character(FiltreLigne()$METRE), " mètres"),
                                       paste0("Année de pose : ", as.character(FiltreLigne()$ANNEE_POSE )),
                                       paste0("Profil du rail : ", as.character(FiltreLigne()$PROFIL_RAIL)),
                                       paste0("Vitesse maximum : ", as.character(FiltreLigne()$VITESSE), "km/h"),
                                       paste0("Fréquence : ", as.character(FiltreLigne()$GROUPE_UIC)),
                                       paste0("Rayon courbure : ", as.character(FiltreLigne()$RAYON_COURBE)),
                                       paste0("Emplacement : ", as.character(FiltreLigne()$EMPLACEMENT)),
                                       paste0("Année de découverte : ", as.character(FiltreLigne()$ANNEE_DECOUVERTE)),
                                       paste0("Age du rail : ", as.character(FiltreLigne()$AGE), " ans"),
                                       paste0("Longitude : ", as.character(FiltreLigne()$LONGITUDE)),
                                       paste0("Latitude : ", as.character(FiltreLigne()$LATITUDE))
                                       ))%>%
        addLegend(pal = pal, values = FiltreLigne()$TYPE_CLASSEMENT, opacity = 0.9)
      })

}#Fin function