#!/usr/bin/bash

# === LD-Based Pruning and PCA steps (don't use for imputation) ===

# step 5: SNP pruning by LD (specified in the doc)
plink --noweb --bfile $tmp2 --indep-pairwise 1500 150 0.1 --out $out
plink --noweb --bfile $tmp2 --extract $out.prune.in --mind 0.1 --make-bed --out $tmp1.pruned

# step 6: cryptic relatedness/IBD check
# IBD check (make .genome file)
plink --noweb --bfile $tmp1.pruned --genome --min 0.05 --make-bed --out $tmp2.pruned
# remove relateds
plink --noweb --bfile $tmp2.pruned --rel-cutoff --make-bed --out $tmp1.pruned

# step 7: PCA by EIGENSTRAT

# coming back to step 2, mask all the -9s
Rscript scripts/replace_uncertains_fam.R $tmp1.pruned $tmp1.pruned

# step 7b: remove outliers/duplicates from the pruned file
plink --noweb --bfile $tmp1.pruned --list-duplicate-vars ids-only suppress-first --out $tmp1.pruned

plink --noweb --bfile $tmp1.pruned --remove $tmp1.pruned.dupvar --make-bed --out $tmp2.pruned

# recode
plink --noweb --bfile $tmp2.pruned --recode --out $tmp2.pruned

smartpca.perl -i $tmp2.pruned.ped -a $tmp2.pruned.map -b $tmp2.pruned.fam -s 6 \
-e $out.eval -l $out.elog -o $out.pca -p $out.plot

# === End of PCA Steps ===


