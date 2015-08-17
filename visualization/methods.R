library(stringr)
library(tm)
library(data.table)
library(lubridate)
library(parallel)
library(SnowballC)
library(topicmodels)
library(slam)
library(shiny)
library(tidyr)
library(ggplot2)
load("bushClinDTM.RData")
load("bushClintonDT.RData")

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

write.lda <- function(dtmToWrite, title="write_lda_output") {
  vocab <- dtmToWrite$dimnames$Terms
  cat(file = paste0(title, "_vocab.txt"), vocab, sep="\n")
  dtmFile <- file(paste0(title, ".dat"), "wt")
  rowapply_simple_triplet_matrix(dtmToWrite, function(wordFreqs) {
    docHas <- which(wordFreqs != 0)
    cat(file=dtmFile, length(docHas), " ", sep="")
    invisible(lapply(docHas, function(wordIndex) {
      cat(file=dtmFile, wordIndex-1, ":", wordFreqs[wordIndex], " ", 
        sep="")
    }))
    cat(file=dtmFile, "\n")
  })
  close(dtmFile)
}

write.plda <- function(dtmToWrite, title="write_plda_output") {
  vocab <- dtmToWrite$dimnames$Terms
  dtmFile <- file(paste0(title, ".dat"), "wt")
  rowapply_simple_triplet_matrix(dtmToWrite, function(wordFreqs) {
    docHas <- which(wordFreqs != 0)
    invisible(lapply(docHas, function(wordIndex) {
      cat(file=dtmFile, vocab[wordIndex], " ", wordFreqs[wordIndex], " ", 
        sep="")
    }))
    cat(file=dtmFile, "\n")
  })
  close(dtmFile)
}

topicTableGen <- function(topics) {
  tables <- list()
  tables <- lapply(seq(1, ncol(topics), by=15), function(i) {
    tables[[length(tables)+1]] <- renderTable({
      maxIndex <- min(i+14, ncol(topics))
      df <- data.frame(topics[,i:maxIndex])
      names(df) <- colnames(topics[,i:maxIndex])
      return(df)
    })
  })
  return(tables)
}

topicsOutput <- system(
  paste("python topics.py output2/025.beta bushAndClinton_vocab.txt", 
    100), intern=T)

myTopics <- function(numWords) {
  if (numWords > 100)
    topicsOutput <- system(
      paste("python topics.py output2/025.beta bushAndClinton_vocab.txt", 
        numWords), intern=T)
  printedOutput <- str_trim(topicsOutput)
  printedOutput <- printedOutput[printedOutput != ""]
  topicNames <- str_replace(printedOutput[str_detect(printedOutput, "\\d+")], "[t]", "T")
  printedOutput <- printedOutput[!str_detect(printedOutput, "\\d+")]
  testMat <- matrix(printedOutput, nrow=length(printedOutput)/length(topicNames),
    ncol=length(topicNames), dimnames=list(c(), topicNames))
  testMat[1:numWords,]
}

lda.40.gamma <- read.table("output2/025.gamma", sep=" ", quote="")
colnames(lda.40.gamma) <- 1:ncol(lda.40.gamma)
