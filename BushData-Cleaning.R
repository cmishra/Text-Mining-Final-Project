setwd("../CS 6501/Course Project/")
# setwd("../../R Working Directory/")
source("BushData-CleaningMethods.R")

bushDocFileNames <- paste0("data/Bush Docs/", list.files("data/Bush Docs")[
  str_detect(list.files("data/Bush Docs"),"doc-pg")])

docsDT <- rbindlist(lapply(bushDocFileNames, readFile))
fileNums <- nrow(docsDT)
docsList <- list(
  docsDT[1:floor(fileNums/4), Content],
  docsDT[ceiling(fileNums/4):floor(fileNums/2), Content],
  docsDT[ceiling(fileNums/2):floor(3*fileNums/4), Content],
  docsDT[ceiling(3*fileNums/4):fileNums, Content])

cl <- makeCluster(mc <- getOption("cl.cores", 4))
clusterEvalQ(cl, {source("BushData-CleaningMethods.R")})
tdm <- parLapply(cl, docsList, genTdm)
tdms <- c(tdm[[1]], tdm[[2]], tdm[[3]], tdm[[4]])
dtm <- pruneWords(tdms)
clusterExport(cl, "dtm")
ldas <- parLapply(cl, seq(100, 400, by=100), function(x) LDA(dtm, x))

stopCluster(cl)

testSample <- genTdm(docsDT[1:1000, Content])
testTfIdf <- weightTfIdf(genTdm(docsDT[1:1000, Content]), normalize=T)
# test.lda <- LDA(testSample, k=30)
# topics(test.lda, 10)

# test foray, I realize I need to reduce the noise
testTfIdf$v[sample(1:11466, 30)]
maxIndex <- which.max(testTfIdf$v)
testTfIdf$dimnames$Terms[testTfIdf$i[maxIndex]]
testTfIdf$dimnames$Docs[testTfIdf$j[maxIndex]]
sum(topTfIdf == testTfIdf$v)

#testing code to reduce noise
test.df <- apply(testSample, 1, function(tf) sum(tf > 0))
sum(test.df > 50)
test.tfidfThres <- apply(testTfIdf, 1, function(tf) quantile(tf, 0.90))
test.max <- apply(testTfIdf, 1, max)
sum(test.tfidfThres > sort(test.tfidfThres, decreasing=T)[2000])
length(union(which(test.tfidfThres > sort(test.tfidfThres, decreasing=T)[2000]),
  which(test.df > 20)))

testSample2 <- as.DocumentTermMatrix(testSample[test.df > 20,])
system.time(test.lda <- LDA(testSample2, 10))


