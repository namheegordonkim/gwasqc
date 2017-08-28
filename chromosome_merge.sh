#!/usr/bin/bash

# Perform a chromosome-wise merge for each chromosome of different imputed
# datasets.

# Requirements:
# * vcf format chromosome-wise GWAS files of the specified name must exist
# * each chromosome-wise vcf file must be put into a directory whose name
#   matches the name of the corresponding experiment
# * each chromosome-wise vcf file should be named like chr1.vcf, chr2.vcf, etc.

# Output: <dataset 1>.<dataset 2>...chr<num> in .bed, .bim, .fam format in
#         output directory

outdir="./out"
tmpdir="./tmp"

mkdir -p $tmpdir

numchr=22

for i in `seq 1 $numchr` do
  mergelist=$tmpdir/chr$i.mergelist
  merged_file_prefix=""
  for dirname in "$@" do
    merged_file_prefix=dirname.$merged_file_prefix
    plink --bfile $dirname/chr$i.vcf --make-bed --out $dirname/chr$i
    echo $dirname/chr$i >> $mergelist
  done
  plink --merge-list $mergelist --out $outdir/$merged_file_prefix.chr$i
done
