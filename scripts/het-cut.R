library("dplyr")
args <- commandArgs(TRUE)
hetname <- args[1]
hetcut.multiplier <- as.numeric(args[2])
outname <- args[3]
het=read.table(hetname,h=T)
het$meanHet = (het$N.NM. - het$O.HOM.)/het$N.NM.
mean.meanHet <- mean(het$meanHet)
sd.meanHet <- sd(het$meanHet)
lo <- mean.meanHet - hetcut.multiplier*sd.meanHet
hi <- mean.meanHet + hetcut.multiplier*sd.meanHet
het.filtered <- het %>% filter(meanHet < lo | meanHet > hi)
het.selected <- het.filtered %>% select(FID, IID)
write.table(het.selected, outname, col.names=F, row.names=F)
