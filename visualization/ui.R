library(shiny)

navbarPage("Topic Modeling over Time",
  tabPanel("Select Topics",
    fluidRow(
      column(3, offset=1,
        numericInput("numWords", 
          "Number of words to display: (1-500)",
          3, 1, 500)
      ),
      column(5, offset=1, 
        textInput("topicsToShow",
          "Selected Topics: (* to show all, list topics #'s or have a range signified by X-Y)", 
          "*"),
        actionButton("resetTopics", "Reset Topics")
      )
    )
    ,
    fluidRow(
      tableOutput("testTopic")
    )
  ),
  tabPanel("Topics over Time"
  
  )
)