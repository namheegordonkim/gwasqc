library("dplyr")

args <- commandArgs(TRUE)
infile <- args[1]
outfile <- args[2]

thres <- 0.185
genome <- read.table(infile, header=T)
pihat.over.thres <- genome %>% filter(PI_HAT > thres)
rem.ids <- pihat.over.thres %>% mutate(FID=FID2, IID=IID2) %>% select(FID, IID)

write.table(rem.ids, outfile, row.names = F, col.names = F)


