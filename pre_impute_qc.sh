#!/usr/bin/bash

# NOTE: Dependencies include:
# R, plink for data cleaning
# EIGENSOFT/EIGENSTRAT for PCA
# ShapeIT, IMPUTE2 for imputation

outdir="./out"
tmpdir="./tmp"

data=$1
dataname=$(basename $data)

subinfo=$2
# output data along with any kind of statistics should be stored in out folder
out=$outdir/$3
tmp1=$tmpdir/$3.tmp1
tmp2=$tmpdir/$3.tmp2


mkdir -p $outdir
mkdir -p $tmpdir

# copy all the data to tmp
cp $data.* $tmpdir
rename $dataname $3.tmp1 $tmpdir/$dataname.*

# for refernce, keep an initial QC metric report
plink --bfile $data --missing --freq --het --out $out.pre

# step 1: exclude uncertains
# do nothing--there is no known phenotype associated with the data

# step 2: update/check FAM with AD status
# bypass this step, do it immediately before PCA

# step 3: sex check on X chromosome
# tack on sex information to .fam file
echo "Updating gender information"
Rscript scripts/update_sexinfo.R $tmp1.fam $subinfo $tmp1.fam

plink --noweb --bfile $tmp1 --check-sex --out $tmp1 # generates .sexcheck file
grep PROBLEM $tmp1.sexcheck > $tmp1.sexprobs
plink --bfile $tmp1 --remove $tmp1.sexprobs --make-bed --out $tmp2  # removes ambiguous individuals

# step 4: remove sex chromosomes and mtDNA from SNP arrays
plink --noweb --bfile $tmp2 --chr 1-22 --make-bed --out $tmp1

# step 5: MAF, HWE, MIND, GENO (missingness and HWE based chopping)
plink --noweb --bfile $tmp2 --maf 0.01 --hwe 0.000005 --mind 0.05 --geno 0.05 --make-bed --out $tmp1

# step 6: heterozygosity statistics and het-based filtering
plink --noweb --bfile $tmp1 --het --out $tmp1 # creates .het file
plink --noweb --bfile $tmp1 --missing --out $tmp1 # creates .imiss and .lmiss files
Rscript ./scripts/imiss-vs-het-custom.R $tmp1.imiss $tmp1.het $tmp1.imiss-vs-het.pdf # created a plot showing heterozygosity cutoffs
# het-based chop
Rscript ./scripts/het-cut.R $tmp1.het $tmp1.hetcuts
plink --noweb --bfile $tmp1 --remove $tmp1.hetcuts --make-bed --out $out

# step 6: LD-Based Pruning, setting up for IBD and PCA
plink --noweb --bfile $tmp2 --indep-pairwise 1500 150 0.1 --out $out
plink --noweb --bfile $tmp2 --extract $out.prune.in --mind 0.1 --make-bed --out $tmp1.pruned

# step 7: cryptic relatedness/IBD check
# IBD check (make .genome file)
plink --noweb --bfile $tmp1.pruned --genome --min 0.05 --make-bed --out $out

# step 8: PCA by EIGENSTRAT
# coming back to step 2, mask all the -9s
Rscript scripts/replace_uncertains_fam.R $tmp1.pruned $tmp1.pruned

# step 8b: remove outliers/duplicates from the pruned file
# I'm not sure if this is actually what they mean...
plink --noweb --bfile $tmp1.pruned --list-duplicate-vars ids-only suppress-first --out $tmp1.pruned
plink --noweb --bfile $tmp1.pruned --remove $tmp1.pruned.dupvar --make-bed --out $tmp2.pruned

# recode
plink --noweb --bfile $tmp2.pruned --recode --out $tmp2.pruned

smartpca.perl -i $tmp2.pruned.ped -a $tmp2.pruned.map -b $tmp2.pruned.fam -s 6 \
-e $out.eval -l $out.elog -o $out.pca -p $out.plot

# step 10: frequency check after-the-fact
plink --noweb --bfile $out --freq --out $out

# step 11: split by chromosome and recode into vcf
numchr=22
for i in `seq 1 $numchr`
do
  plink --noweb --bfile $out --chr $i --make-bed --out $out.chr$i
  plink --noweb --bfile $out.chr$i --recode vcf --out $out.chr$i
  # compress
  vcf-sort $out.chr$i.vcf | bgzip -c > $out.chr$i.vcf.gz
done

