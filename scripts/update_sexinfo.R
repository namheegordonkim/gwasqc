library(dplyr)

args <- commandArgs(TRUE)
fam <- read.table(args[1])
subinfo <- read.table(args[2], header=T)
outname <- args[3]
colnames(fam)[2] <- "Subject"

updated_fam <- left_join(fam, subinfo)

updated_fam[updated_fam$Gender=="Male"]$V5 <- 1
updated_fam[updated_fam$Gender=="Female"]$V5 <- 2
updated_fam[is.na(updated_fam$Gender)]$V5 <- 0

updated_fam <- subset(updated_fam, select=-Gender)

write.table(updated_fam, outname)