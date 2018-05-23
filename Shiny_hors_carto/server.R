function(input, output) {
  
  set.seed(122)
  
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
  
  # La carte
  
  #output$mymap <- renderLeaflet({
    
   # leaflet() %>%
      
    #  addTiles() %>%  # Add default OpenStreetMap map tiles
      
     # setView(lng=c(2.550), lat=c(48.825) ,zoom=10) 
    
  #})
  
  
  
}