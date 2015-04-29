# setwd("../CS 6501/Course Project/")
# setwd("../../R Working Directory/")
# setwd("Dropbox/College/3_Third Year/06_Sixth Semester/CS 6501/Course Project/")
setwd("../ubuntu/finalProj")
install.packages(c("stringr", "tm", "data.table", "lubridate", "parallel", "SnowballC", 
                    "topicmodels", "slam"))
source("BushData-CleaningMethods.R")

bushDocFileNames <- paste0("data/Bush Docs/", list.files("data/Bush Docs")[
  str_detect(list.files("data/Bush Docs"),"doc-pg")])

cl <- makeCluster(mc <- getOption("cl.cores", 2))
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
clusterExport(cl, "dtm")
system.time(lda.test <- LDA(dtm, 10))
ldas <- parLapply(cl, seq(100, 400, length.out=4), function(x) LDA(dtm, x))
save(ldas, file = "output.RData")
stopCluster(cl)

# testSample <- genTdm(docsDT[1:1000, Content])