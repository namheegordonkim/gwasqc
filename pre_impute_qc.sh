#!/usr/bin/bash

# Author: Nam Hee Kim nhgk@alumni.ubc.ca
# This script is originally for the merging of IMAGEN datasets.
# It is designed to read PLINK BED files and output sorted VCF files for
# imputation using Michigan Imputation Server.

# Usage:
# sh pre_impute_qc.sh <input filename> <subject info> <output filename>
# <input filename>    -- For .bed, .bim, .fam files named exactly the same
#                        except for extensions. Do not include extensions.
#                        e.g. IMAGEN_20110404
# <subject info file> -- For updating sex information.
# <output filename>   -- For .vcf files to be created. Do not include extensions.

# NOTE: Dependencies include: R, PLINK for data cleaning

source ./params/pre_impute_params

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

# step 1: sex check on X chromosome
# tack on sex information to .fam file
echo "Updating gender information"
Rscript scripts/update_sexinfo.R $tmp1.fam $subinfo $tmp1.fam

plink --noweb --bfile $tmp1 --check-sex --out $tmp1 # generates .sexcheck file
grep PROBLEM $tmp1.sexcheck > $tmp1.sexprobs
plink --bfile $tmp1 --remove $tmp1.sexprobs --make-bed --out $tmp2  # removes ambiguous individuals

# step 2: remove sex chromosomes and mtDNA from SNP arrays
plink --noweb --bfile $tmp2 --chr 1-22 --make-bed --out $tmp1

# step 3: heterozygosity statistics and het-based filtering
plink --noweb --bfile $tmp1 --het --out $tmp1 # creates .het file
plink --noweb --bfile $tmp1 --missing --out $tmp1 # creates .imiss and .lmiss files
echo "Performing heterozygosity cut"
Rscript ./scripts/imiss-vs-het-custom.R $tmp1.imiss $tmp1.het $hetcut_multiplier $tmp1.imiss-vs-het.pdf # created a plot showing heterozygosity cutoffs
# het-based chop
Rscript ./scripts/het-cut.R $tmp1.het $hetcut_multiplier $tmp1.hetcuts
plink --noweb --bfile $tmp1 --remove $tmp1.hetcuts --make-bed --out $tmp2

# step 4: MAF, HWE, MIND, GENO (missingness and HWE based chopping)
plink --noweb --bfile $tmp2 --maf 0.01 --hwe 0.000005 --mind 0.05 --geno 0.05 --make-bed --out $out

# step 5: Splitting into chromosomes (MIS requirement)
numchr=22
for i in `seq 1 $numchr`
do
  plink --noweb --bfile $out --chr $i --make-bed --out $out.chr$i
  plink --noweb --bfile $out.chr$i --recode vcf --out $out.chr$i
  # compress
  vcf-sort $out.chr$i.vcf | bgzip -c > $out.chr$i.vcf.gz
done
