library("dplyr")
args <- commandArgs(TRUE)
hetname <- args[1]
outname <- args[2]
het=read.table(hetname,h=T)
het$meanHet = (het$N.NM. - het$O.HOM.)/het$N.NM.
mean.meanHet <- mean(het$meanHet)
sd.meanHet <- sd(het$meanHet)
lo <- mean.meanHet - 2*sd.meanHet
hi <- mean.meanHet + 2*sd.meanHet
het.filtered <- het %>% filter(meanHet < lo | meanHet > hi)
het.selected <- het.filtered %>% select(FID, IID)
write.table(het.selected, outname, col.names=F, row.names=F)


