sqldrv <- dbDriver("SQLite")
con <- dbConnect(sqldrv, dbname = "C:/Users/D75275/Documents/OneDrive - EDF/Projet SOVA/Database/SOVA_db.sqlite", loadable.extensions = TRUE)
Map_From_DB = readOGR(dsn="C:/Users/D75275/Documents/OneDrive - EDF/Projet SOVA/Database/SOVA_db.sqlite",layer="defauts", require_geomType = "wkbPoint")
Liste_des_Lignes <- RSQLite::dbGetQuery(conn = con, "SELECT DISTINCT LIGNE_VOIE FROM DEFAUTS_WK UNION SELECT \"'Toutes les voies'\" ORDER BY LIGNE_VOIE DESC")



function(input, output) {
  
  set.seed(122)
  
  #--------- Liste déroulante des lignes
  output$SelectionLignes <- renderUI({
    selectInput("LIGNE", "Selection de la ligne", Liste_des_Lignes)
  })
  
  #--------- Filtre sur les lignes
  FiltreLigne2 <- reactive({
    if(input$LIGNE == "'Toutes les voies'"){
      Map_From_DB
    } else {
      subset(Map_From_DB, Map_From_DB$LIGNE_VOIE == input$LIGNE)}
  })
  
  #--------- Filtre sur les types de defaut
  FiltreLigne <- reactive({
    subset(FiltreLigne2(), FiltreLigne2()$TYPE_CLASSEMENT %in% input$TypeDefaut)
  })
  
  
  
  
  #--------- read me ---------------------------------------
  
  getPage_readme<-function() {
    return(includeHTML("Readme.htm"))
  }
  output$readme_html<-renderUI({getPage_readme()} )
  
  #-----------------------------------
  
  # histdata <- rnorm(500)
  # output$plot1 <- renderPlot({
  #   
  #   data <- histdata[seq_len(input$slider)]
  #   hist(data)
  #   
  # })

  #-------- Chargement du fichier de travail --------------------------   
  DEFAUTS1<-reactive({
    
    fichier<-input$file_defaut
    
    if(is.null(fichier)){return()}
    
    read.csv2(file=fichier$datapath, sep=";",header = TRUE)
    
  })
  
  
  
  output$contenus <- DT::renderDataTable({
    
    DT::datatable(DEFAUTS1(),rownames = FALSE)
    
  })
  
  #-------- affiche une page html---------------------------------------
  getPage<-function(nom_fichier) {
    return(includeHTML(nom_fichier))
  }
  
  #--------- Stats descriptives ---------------------------------------
  #--------- ACM ---------------------------------------

  output$acm_html<-renderUI({getPage("TAB_BIS_Gestion_des_NA_et_Anafac.html")})

  
  #---------------------------------------------------------------------------
  #--------- Modelisation 3 modalites  ---------------------------------------
  
  
  output$mod_3 <- renderUI({
    rd3 <- switch(input$rd_mod3,
                  logi3 = "MULTI_LOGISTIC.html",
                  elnet3 = "MULTI_ELASTIC_NET.html",
                  xgb3 = xgb3,
                  resneur3=resneur3,
                  svm3="MULTI_SVM.html"
    )
    
    getPage(rd3)
  })
   
   
  #--------- 2 modalites  ---------------------------------------    
    output$mod_2 <- renderUI({
      rd2 <- switch(input$rd_mod2,
                      logi2 = "BIN_LOGISTIC.html",
                      elnet2 = "BIN_ELASTIC_NET.html",
                      xgb2 = "BIN_XGBOOST.html",
                      resneur2=rlnorm,
                      svm2="BIN_SVM.html",
                      rd_forest2 = "BIN_RF.nb.html"
      )
      
      getPage(rd2)
    })
  
    
  #===============================================
  
  pal <- colorFactor(c("green", "yellow", "orange","navy","red","black"), 
                     domain = c("NR", "E", "O","X1", "X2", "S"))
  
  output$iboxNR <- renderUI({
    infoBox(
      "NR",
      sum(FiltreLigne()$TYPE_CLASSEMENT=="NR"),
      icon = icon("train"),
      color="green"
    )})  
  
  output$iboxE <- renderUI({
    infoBox(
      "E",
      sum(FiltreLigne()$TYPE_CLASSEMENT=="E"),
      icon = icon("train"),
      color = "yellow"
    )})  
  
  output$iboxO <- renderUI({
    infoBox(
      "O",
      sum(FiltreLigne()$TYPE_CLASSEMENT=="O"),
      icon = icon("train"),
      color="orange"
    )})  
  
  output$iboxX1 <- renderUI({
    infoBox(
      "X1",
      sum(FiltreLigne()$TYPE_CLASSEMENT=="X1"),
      icon = icon("subway"),
      color="navy"
    )})  
  
  output$iboxX2 <- renderUI({
    infoBox(
      "X2",
      sum(FiltreLigne()$TYPE_CLASSEMENT=="X2"),
      icon = icon("subway"),
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
                                     paste0("<b>Defaut de type  : ", as.character(FiltreLigne()$TYPE_CLASSEMENT),"</b>"),"",
                                     paste0("Nom de la ligne : ",  as.character(FiltreLigne()$LIGNE_VOIE)),
                                     paste0("Metre depuis le depart : ", as.character(FiltreLigne()$METRE), " metres"),
                                     paste0("Annee de pose : ", as.character(FiltreLigne()$ANNEE_POSE )),
                                     paste0("Profil du rail : ", as.character(FiltreLigne()$PROFIL_RAIL)),
                                     paste0("Vitesse maximum : ", as.character(FiltreLigne()$VITESSE), "km/h"),
                                     paste0("Frequence : ", as.character(FiltreLigne()$GROUPE_UIC)),
                                     paste0("Rayon courbure : ", as.character(FiltreLigne()$RAYON_COURBE)),
                                     paste0("Emplacement : ", as.character(FiltreLigne()$EMPLACEMENT)),
                                     paste0("Annee de decouverte : ", as.character(FiltreLigne()$ANNEE_DECOUVERTE)),
                                     paste0("Age du rail : ", as.character(FiltreLigne()$AGE), " ans"),
                                     paste0("Longitude : ", as.character(FiltreLigne()$LONGITUDE)),
                                     paste0("Latitude : ", as.character(FiltreLigne()$LATITUDE))
                       ))%>%
      addLegend(pal = pal, values = FiltreLigne()$TYPE_CLASSEMENT, opacity = 0.9)
  })
  
  
  
}