library(stringr)
library(tm)
library(data.table)
library(lubridate)
library(parallel)
library(SnowballC)
library(topicmodels)
library(slam)

readFile <- function(title) {
  fileStuff <- readLines(title)
  date <- mdy(fileStuff[7])
  content <- gsub("<.*?>", "", 
    paste(fileStuff[12:length(fileStuff)], collapse=" "))
  content <- str_replace_all(content, "\\[\\[.+?\\]\\]", "")
  data.table(Date=date, Content=content)
}

genTdm <- function(docs){  
  ctrl <- list(tokenize="MC",
    tolower=T,
    removePunctation=T,
    removeNumbers=T,
    stopwords=T,
    stemming=wordStem,
    wordLengths=c(1,Inf)
  )
  dtm <- DocumentTermMatrix(VCorpus(VectorSource(docs)), control = ctrl)
  dtm[,setdiff(colnames(dtm), intersect(colnames(dtm), stpwrds))]
}

pruneWords <- function(dtm) {
  terms.df <- colapply_simple_triplet_matrix(dtm, function(tf) {sum(tf > 0)})
  dtm[,terms.df > 50]
}

stpwrds <- wordStem(scan(file="stopwords.txt", what=character())); 




# extractDate <- 
