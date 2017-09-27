#!/usr/bin/bash

# Perform a chromosome-wise concat for each chromosome of different imputed
# datasets.

# Requirements:
# * vcf format chromosome-wise GWAS files of the specified name must exist
# * each chromosome-wise vcf file must be put into a directory whose name
#   matches the name of the corresponding experiment
# * each chromosome-wise vcf file should be gzipped and named like
#   chr1.dose.vcf.gz, chr2.dose.vcf.gz, etc.

# Output: <dataset 1>.<dataset 2>...chr<num> in .bed, .bim, .fam format in
#         output directory
source params/pre_impute_params

dirname=$1
outname=$outdir/$2

numchr=22

concat_args=""
for i in `seq 1 $numchr`
do
  chrfname=$dirname/chr$i.dose.vcf.gz
  concat_args="$concat_args $chrfname"
done

bcftools concat $concat_args -a -D -O z -o $outname
