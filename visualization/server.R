library(shiny)
source("methods.R")

function(input, output) {
  
  docDates <- docsDT[,Date]
  
  oldFullTopicCount <- -1
  
  selectedTopics <- reactive({
    input$resetTopics
    if (oldFullTopicCount == input$showAllTopics) {
      topicStringInputs <- isolate(
        str_split(str_trim(input$topicsToShow, "both"), " ")[[1]])
      if (any(sapply(topicStringInputs, function(str) str_detect(str,  "[^ 0123456789]")))) {
        return(renderText(strong(paste0("Error - invalid character in Selected Topics."))))
      }
      topicStringInputs[!topicStringInputs == ""]
      termsMatrix <- myTopics(input$numWords)
      return(as.integer(topicStringInputs) + 1)
    } else {
        oldFullTopicCount <<- input$showAllTopics 
        return(1:40)
    }
  })
    
  output$topicsTables <- renderUI({
    termsMatrix <- myTopics(input$numWords)
    topicTableGen(termsMatrix[,selectedTopics()])
  })
  
  output$TOTgraph <- renderPlot({
      grphDT <- data.table(Date=docDates)
    grphDT[,Date:=Date-(yday(Date) %% input$numDays)*60*60*24]
    lapply(selectedTopics(), function(topicIndex) {
      grphDT[,c(as.character(topicIndex)):=list(lda.40.gamma[,topicIndex])]
    })
    grphDT <- data.table(gather(data.frame(grphDT), "Topic", "RelevanceScore", -Date))
    grphDT <- grphDT[,.(RelevanceScore=sum(RelevanceScore)),by=.(Date, Topic)]
    ggplot(grphDT, aes(y=RelevanceScore, x=Date, col=Topic))+
      geom_line() +
      scale_x_datetime(limits=c(as.POSIXct(format(input$dateRange[1])), as.POSIXct(format(input$dateRange[2]))))
  })
  
}
