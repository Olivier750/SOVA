function(input, output) {
  set.seed(122)
  histdata <- rnorm(500)
  
  output$plot1 <- renderPlot({
    data <- histdata[seq_len(input$slider)]
    hist(data)
  })
  
  
  DEFAUTS1<-reactive({
    fichier<-input$DEF1
    if(is.null(fichier)){return()}
    read.csv2(file=fichier$datapath, sep=";",header = TRUE)
  })
  
  output$contenus <- DT::renderDataTable({
    DT::datatable(DEFAUTS1(),rownames = FALSE)
  })
  
  # La carte
  output$mymap <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%  # Add default OpenStreetMap map tiles
      setView(lng=c(2.550), lat=c(48.825) ,zoom=10) 
  })
  
}