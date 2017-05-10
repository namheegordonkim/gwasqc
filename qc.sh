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

# step 1: exclude uncertains
# do nothing--there is no known phenotype associated with the data

# step 2: update/check FAM with AD status
# bypass this step, do it immediately before PCA

# step 3: sex check on X chromosome
# tack on sex information to .fam file
echo "Updating gender information"
Rscript scripts/update_sexinfo.R $tmp1.fam $subinfo $tmp1.fam
Rscript scripts/update_sexinfo.R $tmp1.fam $subinfo $tmp1.fam
Rscript scripts/update_sexinfo.R $tmp1.fam $subinfo $tmp1.fam
Rscript scripts/update_sexinfo.R $tmp1.fam $subinfo $tmp1.fam
Rscript scripts/update_sexinfo.R $tmp1.fam $subinfo $tmp1.fam
Rscript scripts/update_sexinfo.R $tmp1.fam $subinfo $tmp1.fam
Rscript scripts/update_sexinfo.R $tmp1.fam $subinfo $tmp1.fam
Rscript scripts/update_sexinfo.R $tmp1.fam $subinfo $tmp1.fam
Rscript scripts/update_sexinfo.R $tmp1.fam $subinfo $tmp1.fam
Rscript scripts/update_sexinfo.R $tmp1.fam $subinfo $tmp1.fam

plink --noweb --bfile $tmp1 --check-sex --out $out # generates .sexcheck file
# exclude non-OKs
plink --noweb --bfile $tmp1 --must-have-sex --exclude $out.sexcheck --make-bed --out $tmp2

# step 4: remove sex chromosomes and mtDNA from SNP arrays
plink --noweb --bfile $tmp2 --chr 1-22 --make-bed --out $tmp1

# step 5: heterozygosity statistics
plink --noweb --bfile $tmp1 --het --out $out

# step 5: SNP pruning by LD (specified in the doc)
plink --noweb --bfile $tmp1 --indep-pairwise 1500 150 0.1 --out $out
plink --noweb --bfile $tmp1 --extract $out.prune.in --mind 0.1 --make-bed --out $tmp2

# step 6: cryptic relatedness/IBD check
# IBD check (make .genome file)
plink --noweb --bfile $tmp2 --genome --min 0.05 --make-bed --out $tmp1
# remove relateds
plink --noweb --bfile $tmp1 --rel-cutoff --make-bed --out $tmp2

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

# coming back to step 2, mask all the -9s
Rscript scripts/replace_uncertains_fam.R $tmp2 $tmp2

# recode
plink --noweb --bfile $tmp2 --recode --out $tmp2

smartpca.perl -i $tmp2.ped -a $tmp2.map -b $tmp2.fam -s 6 \
-e $out.eval -l $out.elog -o $out.pca -p $out.plot

# step 7b: remove outliers/duplicates from the pruned file
# plink --noweb --list-duplicate-vars

# step 8: MAF, HWE, MND, GENO
plink --noweb --bfile $tmp2 --maf 0.01 --hwe 0.000005 --mind 0.05 --geno 0.05 --make-bed --out $out

# step 9: frequency check after-the-fact
plink --noweb --bfile $out --freq --out $out

# step 10: split by chromosome and recode into vcf
numchr=22
for i in `seq 1 $numchr`
do
  plink --noweb --bfile $out --chr $i --make-bed --out $out.chr$i
  plink --noweb --bfile $out.chr$i --recode vcf --out $out.chr$i
  # compress
  vcf-sort $out.chr$i.vcf | bgzip -c > $out.chr$i.vcf.gz
done

# step 11: ShapeIT for each chromosome
for i in `seq 1 $numchr`
do
  if (($i % 2 == 0))
  then
    wait
  fi
  shapeit -B $out.chr$i -O $out.chr$i.phased -T 4 &
  # chunk 2 shapeit jobs at a time
done

wait
