source params/pre_impute_params

filename=$1
threshold=$2
dataname=$(basename $filename)

plink --vcf $filename --indep-pairwise 1500 150 $threshold --out $tmpdir/$dataname
plink --vcf $filename --extract $tmpdir/$dataname.prune.in --mind 0.1 --recode vcf --out $outdir/$dataname.pruned.vcf.gz
