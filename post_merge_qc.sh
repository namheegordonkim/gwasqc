# start with the merged mega dataset (100+ GB)
# and do all necessary QC steps before LD based pruning

in=$1
out=./out/$2
tmp1=./tmp/$out.tmp1
tmp2=./tmp/$out.tmp2

mkdir -p ./tmp
mkdir -p ./out

# step 1: strand flip
plink --bfile $in --flip-scan


# step 2: LD-based pruning
plink --noweb --bfile $in --indep-pairwise 1500 150 0.1 --out $out
plink --noweb --bfile $in --extract $out.prune.in --mind 0.1 --make-bed --out $tmp1.pruned

# step 3: cryptic relatedness/IBD check
# IBD check (make .genome file)
plink --noweb --bfile $tmp1.pruned --genome --min 0.05 --out $tmp1.pruned
Rscript ./ibd-cut.R $tmp1.pruned.genome $tmp1.pruned.ibdcuts
plink --bfile $tmp1.pruned --remove $tmp1.pruned.ibdcuts --make-bed --out $tmp2.pruned

# step 4: divergent ancestry chopping

# coming back to step 2, mask all the -9s
Rscript scripts/replace_uncertains_fam.R $tmp2.pruned $tmp2.pruned
# recode
plink --noweb --bfile $tmp2.pruned --recode --out $tmp2.pruned

smartpca.perl -i $tmp2.pruned.ped -a $tmp2.pruned.map -b $tmp2.pruned.fam -s 6 \
-e $tmp2.eval -l $tmp2.elog -o $tmp2.pca -p $tmp2.plot

Rscript scripts/pca-cut.R $tmp2.pruned.fan $tmp2.pca $tmp2.pruned.pcacuts
plink --bfile $tmp2.pruned --remove $tmp2.pruned.pcacuts --make-bed --out $tmp1.pruned


