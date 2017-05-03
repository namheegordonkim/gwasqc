#!/usr/local/bin
# NOTE: Dependencies include:
# R, plink for data cleaning
# EIGENSOFT/EIGENSTRAT for PCA
# ShapeIT, IMPUTE2 for further QC steps

data=$1
out=$2

# step 1: exclude uncertains
plink --noweb --file $data --prune --make-bed --out $out

# step 2: update/check FAM with AD status
# no idea how to do this...

# step 3: sex check on X chromosome
plink --noweb --bfile $out --check-sex --out $out # generates .sexcheck file
# exclude non-OKs
plink --noweb --bfile $out --exclude $out.sexcheck --make-bed --out $out

# step 4: remove sex chromosomes and mtDNA from SNP arrays
plink --noweb --bfile $out --chr 1-22 --make-bed --out $out

# step 5: heterozygosity statistics
plink --noweb --bfile $out --het  --out $out

# step 5: SNP pruning by LD (specified in the doc)
plink --noweb --bfile $out --indep-pairwise 1500 150 0.1 --out $out
plink --noweb --bfile $out --extract $out.prune.in --recode --mind 0.1 --make-bed --out $out

# step 6: cryptic relatedness/IBD check
# IBD check (make .genome file)
plink --noweb --bfile $out --genome --min 0.05 --out $out
# remove relateds
plink --noweb --bfile $out --rel-ctoff --out $out

# step 7: EIGENSTRAT 
