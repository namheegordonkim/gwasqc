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
hrc=~/hrc/HRC.r1-1.GRCh37.wgs.mac5.sites.vcf.gz

start=$1
end=$2

for i in `seq $start $end`
do
  (
  onekg=~/1kg/ALL.chr$i.phase3_shapeit2_mvncall_integrated_v5_func_anno.20130502.sites.vcf.gz
  merge_args=""
  outputFilename=""
  for dirname in "${@:3}"
  do
    dataname=$(basename $dirname)
    chrfname=chr$i.dose

    # reheader
    tabix -H $dirname/$chrfname.vcf.gz > $tmpdir/$dataname.$chrfname.header
    sed -i "${missing_header_line_number}r $missing_header_line_file" $tmpdir/$dataname.$chrfname.header
    bcftools reheader -h $tmpdir/$dataname.$chrfname.header -o $tmpdir/$dataname.$chrfname.reheadered.vcf.gz $dirname/$chrfname.vcf.gz
    tabix $tmpdir/$dataname.$chrfname.reheadered.vcf.gz

    # annotate with 1000 genomes phase 3 reference panel
    # bcftools annotate -a $hrc -c CHROM,POS,ID -O z -o $tmpdir/$dataname.$chrfname.annotated.vcf.gz $tmpdir/$dataname.$chrfname.normed.vcf.gz
    # rm -f $tmpdir/$dataname.$chrfname.normed*
    # tabix $tmpdir/$dataname.$chrfname.annotated.vcf.gz

    bcftools annotate -a $hrc -c CHROM,POS,ID -O z -o $tmpdir/$dataname.$chrfname.annotated.vcf.gz $tmpdir/$dataname.$chrfname.reheadered.vcf.gz
    rm -f $tmpdir/$dataname.$chrfname.reheadered*
    tabix $tmpdir/$dataname.$chrfname.annotated.vcf.gz

    #recode REF and ALT (mutate the tmp file!)
    bcftools norm -d both -N -c ws -f $hg19 -O z -o $tmpdir/$dataname.$chrfname.normed.vcf.gz $tmpdir/$dataname.$chrfname.annotated.vcf.gz
    rm -f $tmpdir/$dataname.$chrfname.annotated*
    tabix $tmpdir/$dataname.$chrfname.normed.vcf.gz

    merge_args="$merge_args $tmpdir/$dataname.$chrfname.normed.vcf.gz"
    outputFilename="$outputFilename+$dataname"
  done
  # merge
  merge_args=${merge_args:1}
  outputFilename=${outputFilename:1}.$chrfname.vcf.gz
  time bcftools merge $merge_args -O z -o $outdir/$outputFilename
  # rm -f $tmpdir/$dataname.$chrname.annotated*
  ) &
done
wait
