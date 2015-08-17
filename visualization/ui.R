 library(shiny)

navbarPage("Presidential Attention over Time",
  tabPanel("Select Topics",
    withMathJax(),
    fluidRow(
      column(3, offset=1,
        em("Please allow 10 seconds for the topics to load"),
        numericInput("numWords", 
          "Number of words to display per topic:",
          3, 2, 500),
        actionButton("showAllTopics", "Show All Topics")
      ),
      column(3, offset=1, 
        textInput("topicsToShow",
          "List topics numbers separated by spaces: (at least 2)", 
          ""),
        actionButton("resetTopics", "Select Listed Topics")
      )
    ),
    fluidRow(
      br(),
      column(10, offset=1,
        uiOutput("topicsTables")
      )
    )
  ),
  tabPanel("Attention over Time",
    fluidRow(
      column(3, offset=1,
        dateRangeInput("dateRange", 
          "View topic(s) change between:",
          start="1993-01-20",
          end="2009-01-19",
          min="1993-01-20",
          max="2009-01-19",
          startview="year"
        )
      ),
      column(3, offset=1,
        numericInput("numDays", 
          "Average over how many days?",
          7, 1, 100))
    ),
    fluidRow(
      column(12,
        h2("Presidential attention on selected topics", align="center")
      ),
      column(12,
        plotOutput("TOTgraph")
      )
    ),
    fluidRow(
      column(12,
        h3("Technical details", align="center")),
      column(10, offset=1, tags$i("Powerpoint presentation available ",
        a("here", href="https://github.com/cmishra/Text-Mining-Final-Project/blob/master/presentation.pptx"))),
      column(10, offset=1,
        strong("Data set:"), 
        a(" Compiled Presidential Documents", href="http://www.gpo.gov/fdsys/browse/collection.action?collectionCode=CPD"),
        " (Bill Clinton and George W. Bush)"),
      column(10, offset=1,
        strong("Purpose:"),
        " How can we quantitatively measure what the administration was ",
        "focused on and how the focus change over time?"),
      column(10, offset=1,
        strong("Methodology: "),
        "Use Latent Dirichlet Allocation (LDA) to find a set of topics on the",
        "data. Model selection is done with a greedy heuristic (using the Log-Likelihood)."),
      column(10, offset=1,
        strong("Metric: "), "Recall that within LDA, ",
        "\\(\\theta_d\\) is the distribution of topics in document \\(d\\).",
        " During a unit of time, the set of public interactions, statements,",
        " and documents released are \\(i\\).",
        " Of a topic \\(t\\), the relevance score",
        " \\(S_{t, i} = \\sum_{d \\in i} \\theta_{d, t} \\)."
      )
    )
    
  )
)