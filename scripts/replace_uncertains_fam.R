# based on https://www.cog-genomics.org/plink2/formats#fam

args <- commandArgs(TRUE)
infile <- args[1]
outfile <- args[2]

fam <- read.table(infile)
fam$V6 <- rep(1, nrow(fam))


write.table(fam, outfile, col.names=F, row.names=F)
