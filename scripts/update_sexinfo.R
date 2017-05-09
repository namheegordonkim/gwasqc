library(dplyr)

args <- commandArgs(TRUE)
fam <- read.table(args[1])
subinfo <- read.table(args[2], header=T) %>% select(Subject, Gender)
outname <- args[3]
colnames(fam)[2] <- "Subject"

updated_fam <- left_join(fam, subinfo, by="Subject")

newsex <- rep(0, nrow(fam))
newsex[updated_fam$Gender=="Male"] <- 1
newsex[updated_fam$Gender=="Female"] <- 2

updated_fam$V5 <- newsex

updated_fam <- updated_fam %>% select(-Gender)

write.table(updated_fam, outname, col.names=F, row.names=F)