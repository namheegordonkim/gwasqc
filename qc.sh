#!/usr/local/bin
# NOTE: Dependencies include:
# R, plink for data cleaning
# EIGENSOFT/EIGENSTRAT for PCA
# ShapeIT, IMPUTE2 for imputation

data=$1
out=$2
tmp1=$out.tmp1
tmp2=$out.tmp2
tmpdir="./tmp"

mkdir $tmpdir

# step 1: exclude uncertains
# do nothing--there is no known phenotype associated with the data

# step 2: update/check FAM with AD status
# no idea how to do this...

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
plink --noweb --bfile $tmp2 --genome --min 0.05 --out $out
# remove relateds
plink --noweb --bfile $tmp2 --rel-cutoff --make-bed --out $out

# before PCA: recode .ped and .map fles
plink --bfile $out --recode --out $out

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

smartpca.pl -i $out.ped -a $out.map -b $out.fam -s 6 \ 
-e $out.eval -l $out.elog -o $out.pca -p $out.plot
