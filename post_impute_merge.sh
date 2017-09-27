#!/usr/bin/bash

# Merge the results of imputation into one dataset
# In case the output of imputation is chromosome-by-chromosome,
# merge across datasets so there is one file per chromosome.
# Perform corrections of errors in Michigan Imputation Server's output
# Including:
# 1. reheadering
# 2. recoding REF and ALT alleles

# Input: folders specifying dataset; assume each folder has chr1 through chr22
#        and each is named chr1.dose.vcf.gz, chr2.dose.vcf.gz, etc.
#        (this is how MIS likes to give you the output)
# Output: 22 chromosome files for the merged dataset

# Required: BCFTools, samtools, tabix, hg19 reference FASTA file
#           (hg19.nochr.fa) where chromosomes are named "1", "2", instead of
#           "chr1", "chr2", etc.

source params/pre_impute_params
missing_header_line_file=scripts/missing_header_lines.txt
missing_header_line_number=11
hg19=~/hg19/hg19.nochr.fa

for $i in `seq 1 22`
do
  merge_args=""
  for $dirname in "${@%/}"
  do
    $dataname=$(basename $dirname)
    chrfname=chr$i.dose.vcf.gz

    # reheader
    tabix -H $dirname/$chrfname > $tmpdir/$chrfname.header
    sed -i "${missing_header_line_number}r $missing_header_line_file" $tmpdir/$dataname.$chrfname.header
    bcftools reheader -h $tmpdir/$dataname.$chrfname.header $dirname/$chrfname -o $tmpdir/$dataname.$chrfname.reheadered
    tabix $tmpdir/$dataname.$chrfname.reheadered

    # recode REF and ALT (mutate the tmp file!)
    bcftools norm -d both -N -c ws -f $hg19 -O z -o $tmpdir/$dataname.$chrfname.reheadered $tmpdir/$dataname.$chrfname.reheadered

    merge_args="$merge_args+$dataname"
  done
  # merge
  merge_args=${merge_args:1}
  bcftools merge $merge_args 
done
