#!/usr/bin
# NOTE: Dependencies include:
# R, plink for data cleaning
# EIGENSOFT/EIGENSTRAT for PCA
# ShapeIT, IMPUTE2 for imputation

outdir="./out"
tmpdir="./tmp"

data=$1
out=$outdir/$2
tmp1=$tmpdir/$2.tmp1
tmp2=$tmpdir/$2.tmp2

mkdir -p $outdir
mkdir -p $tmpdir

# step 1: exclude uncertains
# do nothing--there is no known phenotype associated with the data

# step 2: update/check FAM with AD status
Rscript replace_uncertains_fam.R $data $tmp1

# step 3: sex check on X chromosome
plink --noweb --bfile $data --check-sex --out $out # generates .sexcheck file
# exclude non-OKs
plink --noweb --bfile $data --exclude $out.sexcheck --make-bed --out $tmp2

# step 4: remove sex chromosomes and mtDNA from SNP arrays
plink --noweb --bfile $tmp2 --chr 1-22 --make-bed --out $tmp1

# step 5: heterozygosity statistics
plink --noweb --bfile $tmp1 --het --out $out

# step 5: SNP pruning by LD (specified in the doc)
plink --noweb --bfile $tmp1 --indep-pairwise 1500 150 0.1 --out $out
plink --noweb --bfile $tmp1 --extract $out.prune.in --mind 0.1 --make-bed --out $tmp2

# step 6: cryptic relatedness/IBD check
# IBD check (make .genome file)
plink --noweb --bfile $tmp2 --genome --min 0.05 --make-bed --out $tmp1
# remove relateds
plink --noweb --bfile $tmp1 --rel-cutoff --make-bed --out $out

# step 7: PCA by EIGENSTRAT
# echo genotypename:    $out.ped > ./par.PED.EIGENSTRAT
# echo snpname:         $out.map >> ./par.PED.EIGENSTRAT
# echo indivname:       $out.fam >> ./par.PED.EIGENSTRAT
# echo outputformat:    EIGENSTRAT >> ./par.PED.EIGENSTRAT
# echo genotypeoutname: $out.eigenstratgeno >> ./par.PED.EIGENSTRAT
# echo snpoutname:      $out.snp >> ./par.PED.EIGENSTRAT
# echo indivoutname:    $out.ind >> ./par.PED.EIGENSTRAT
# echo familynames:     NO >> ./par.PED.EIGENSTRAT
#
# convertf -p ./par.PED.EIGENSTRAT

smartpca.perl -i $out.bed -a $out.bim -b $out.fam -s 6 \
-e $out.eval -l $out.elog -o $out.pca -p $out.plot

# step 7b: remove outliers/duplicates from the pruned file
# plink --noweb --list-duplicate-vars

# step 8: MAF, HWE, MND, GENO
