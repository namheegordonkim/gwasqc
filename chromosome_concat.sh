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

mkdir -p $tmpdir

numchr=22

for i in `seq 1 $numchr`
do
  concated_file_prefix=""
  concat_args=""
  for dirname in "${@%/}"
  do
    dataname=$(basename $dirname)
    concated_file_prefix=$concated_file_prefix+$dataname
    concat_args="$concat_args $dirname/chr$i.dose.vcf.gz"
  done
  concated_file_prefix=${concated_file_prefix:1}
  vcf-concat $concat_args | bgzip -c > $outdir/$concated_file_prefix.chr$i.vcf.gz &
done

wait
