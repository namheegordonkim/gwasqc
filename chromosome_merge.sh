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

for i in `seq 1 $numchr`
do
  merged_file_prefix=""
  merge_args=""
  for dirname in "${@%/}"
  do
    dataname=$(basename $dirname)
    chrfname=chr$i.dose.vcf.gz
    filename=$dirname/reheadered/$chrfname
    merged_file_prefix=$merged_file_prefix+$dataname

    merge_args="$merge_args $filename"
  done
  merged_file_prefix=${merged_file_prefix:1}
  bcftools merge -O z -o $outdir/$merged_file_prefix.chr$i.vcf.gz $merge_args &
done

wait
