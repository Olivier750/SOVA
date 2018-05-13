function(input, output) {
  
  set.seed(122)
  
 
  
  histdata <- rnorm(500)
  output$plot1 <- renderPlot({
    
    data <- histdata[seq_len(input$slider)]
    hist(data)
    
  })


  
  #===============================================
    output$logi <- renderPlot({
      rdlogi <- switch(input$rd_logi,
                     logi_2 = rnorm,
                     logi_3 = runif
                     )
      
      hist(rdlogi(500))
    })
    
    output$svm <- renderPlot({
      rdsvm <- switch(input$rd_svm,
                      SVM_2 = rlnorm,
                      SVM_3 = rnorm
      )
      
      hist(rdsvm(500))
    })
  
    

  
  #===============================================
  DEFAUTS1<-reactive({
    
    fichier<-input$file_defaut
    
    if(is.null(fichier)){return()}
    
    read.csv2(file=fichier$datapath, sep=";",header = TRUE)
    
  })
  
  
  
  output$contenus <- DT::renderDataTable({
    
    DT::datatable(DEFAUTS1(),rownames = FALSE)
    
  })
  
  
  #============== MCA =================================
  

  #===============================================
  
  # La carte
  
  #output$mymap <- renderLeaflet({
    
   # leaflet() %>%
      
    #  addTiles() %>%  # Add default OpenStreetMap map tiles
      
     # setView(lng=c(2.550), lat=c(48.825) ,zoom=10) 
    
  #})
  
  
  
}