# based on https://www.cog-genomics.org/plink2/formats#fam

args <- commandArgs(TRUE)
infile <- paste(args[1], ".fam", sep="")
outfile <- paste(args[2], ".fam", sep="")

fam <- read.table(infile)
fam$V6 <- rep(1, nrow(fam))


write.table(fam, outfile, col.names=F, row.names=F)
