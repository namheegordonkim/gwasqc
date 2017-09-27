#!/usr/bin/bash

# Perform a chromosome-wise merge for each chromosome of different imputed
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

mkdir -p $tmpdir

numchr=22

missing=(5 12 8 7 21 20 10 2)

for i in ${missing[@]}
do
  for dirname in "${@%/}"
  do
    dataname=$(basename $dirname)
    chrfname=chr$i.dose.vcf.gz
    filename=$dirname/reheadered/$chrfname
    outname=$outdir/$dataname.normed.$chrfname
    bcftools norm -N -d both -c ws -O z -o $outname -f ~/hg19/hg19.nochr.fa $filename &
  done
done

wait
