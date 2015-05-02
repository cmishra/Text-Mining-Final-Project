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


# extractDate <- 
