library("dplyr")
args <- commandArgs(TRUE)
bound <- data.frame()
outname <- args[length(args)]
# last argument is the output file
for (i in 1:(length(args)-1)) {
  filename <- args[i]
  dat <- read.table(filename, header=T)
  bound <- rbind(bound, dat)
}

write.table(bound, outname, quote=F, row.names=F, sep="\t")