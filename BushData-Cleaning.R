setwd("../CS 6501/Course Project/")
# setwd("../../R Working Directory/")
# setwd("Dropbox/College/3_Third Year/06_Sixth Semester/CS 6501/Course Project/")
source("BushData-CleaningMethods.R")

bushDocFileNames <- paste0("data/Bush Docs/", list.files("data/Bush Docs")[
  str_detect(list.files("data/Bush Docs"),"doc-pg")])

cl <- makeCluster(mc <- getOption("cl.cores", 4))
clusterEvalQ(cl, {source("BushData-CleaningMethods.R")})

docsDT <- rbindlist(lapply(bushDocFileNames, readFile))
fileNums <- nrow(docsDT)
docsList <- list(
  docsDT[1:floor(fileNums/4), Content],
  docsDT[ceiling(fileNums/4):floor(fileNums/2), Content],
  docsDT[ceiling(fileNums/2):floor(3*fileNums/4), Content],
  docsDT[ceiling(3*fileNums/4):fileNums, Content])

tdm <- parLapply(cl, docsList, genTdm)
tdms <- c(tdm[[1]], tdm[[2]], tdm[[3]], tdm[[4]])
# rm(tdm, docsList, docsDT)
dtm <- pruneWords(tdms)
stopCluster(cl)
clusterExport(cl, list("dtm"))

system.time(
  ldasGibbs <- parLapply(cl, seq(200, 400, by=100), 
    function(x) LDA(k=x, method="Gibbs", x=dtm))
)

system.time(lda.100 <- LDA(dtm, 100))
save(lda.100, file="lda100.RData")
# system.time(lda.200 <- LDA(dtm, 200, method="Gibbs"))
# save(lda.200, file="lda200.RData")
# system.time(lda.300 <- LDA(dtm, 300))
# save(lda.300, file="lda300.RData")
# system.time(lda.400 <- LDA(dtm, 400))
# save(lda.400, file="lda400.RData")

ldaFormat <- dtm2ldaformat(dtm)
ldaGibbs.200 <- lda.collapsed.gibbs.sampler(ldaFormat, 200, dtm$dimnames$Terms,
  num.iterations=5000)

lda.temp <- LDA(dtm, 10)
save(lda.temp, file = "output.RData")
stopCluster(cl)

# testSample <- genTdm(docsDT[1:1000, Content])