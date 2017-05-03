# install.packages("dplyr")
library(dplyr)

# based on https://www.cog-genomics.org/plink2/formats#fam

fam <- read.table("../example/toy.fam")
colnames(fam)[1:6] <- c("FID", "IID", "FatherID", "MotherID", "Sex", "PhenoVal")
fam$FID <- as.factor(fam$FID)
fam$IID <- as.factor(fam$IID)
fam$FatherID <- as.factor(fam$FatherID)
fam$MotherID <- as.factor(fam$MotherID)
fam$Sex <- as.factor(fam$Sex)
fam$PhenoVal <- as.factor(fam$PhenoVal)

map <- read.table("../example/toy.map")
bed <- read.table("../example/toy.bed")

outmap <- map %>% filter(fam$PhenoVal!=-9)
outbed <- bed %>% filter(fam$PhenoVal!=-9)

write.table(outmap, "../example/toy_excluded_uncertains.map")
write.table(outbed, "../example/toy_excluded_uncertains.bed")
