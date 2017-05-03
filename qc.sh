#!/usr/local/bin
# NOTE: Dependencies include:
# R, plink for data cleaning
# EIGENSOFT/EIGENSTRAT for PCA
# ShapeIT, IMPUTE2 for imputation

data=$1
out=$2
tmpdir="./tmp"

mkdir $tmpdir

# step 1: exclude uncertains
# do nothing--there is no known phenotype associated with the data

# step 2: update/check FAM with AD status
# no idea how to do this...

# step 3: sex check on X chromosome
plink --noweb --bfile $data --check-sex --out $out # generates .sexcheck file
# exclude non-OKs
plink --noweb --bfile $data --exclude $out.sexcheck --make-bed --out $out

# step 4: remove sex chromosomes and mtDNA from SNP arrays
plink --noweb --bfile $out --chr 1-22 --make-bed --out $out

# step 5: heterozygosity statistics
plink --noweb --bfile $out --het  --out $out

# step 5: SNP pruning by LD (specified in the doc)
plink --noweb --bfile $out --indep-pairwise 1500 150 0.1 --out $out
plink --noweb --bfile $out --extract $out.prune.in --mind 0.1 --make-bed --out $out

# step 6: cryptic relatedness/IBD check
# IBD check (make .genome file)
plink --noweb --bfile $out --genome --min 0.05 --out $out
# remove relateds
plink --noweb --bfile $out --rel-cutoff --out $out

# before PCA: recode .ped and .map fles
plink --bfile $out --recode --out $out

# step 7: PCA by EIGENSTRAT
