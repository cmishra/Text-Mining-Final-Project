library(shiny)
source("methods.R")
load("lda100.RData")

function(input, output) {
  
  output$testTopic <- renderTable({
    obj <- terms(lda.100, input$numWords)
    tab <- data.frame(obj[,1])
    names(tab) <- colnames(obj)[1]
    tab
  })
  
}
