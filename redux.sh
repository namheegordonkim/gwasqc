#!/usr/bin/bash

source params/pre_impute_params

input=$1
out=$outdir/$2
tmp1=$tmpdir/$2.tmp1
tmp2=$tmpdir/$2.tmp2

# === LD-Based Pruning and PCA steps (don't use for imputation) ===

# step 7: LD-Based Pruning, setting up for IBD and PCA
plink --vcf $input --indep-pairwise 1500 150 0.1 --out $out
plink --vcf $input --extract $out.prune.in --mind 0.1 --recode vcf --out $tmp1.pruned

# step 8: cryptic relatedness/IBD check
# IBD check (make .genome file)
plink --noweb --bfile $tmp1.pruned --genome --min 0.05 --make-bed --out $out

# step 9: PCA by EIGENSTRAT
# coming back to step 2, mask all the -9s
Rscript scripts/replace_uncertains_fam.R $tmp1.pruned $tmp1.pruned

# step 9b: remove outliers/duplicates from the pruned file
# I'm not sure if this is actually what they mean...
plink --noweb --bfile $tmp1.pruned --list-duplicate-vars ids-only suppress-first --out $tmp1.pruned
plink --noweb --bfile $tmp1.pruned --remove $tmp1.pruned.dupvar --make-bed --out $tmp2.pruned

# === End of PCA Steps ===
