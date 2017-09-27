source params/pre_impute_params

dirname=$1

for filename in `ls $dirname | grep \.vcf.gz$`
do
  (
    plink --vcf $dirname/$filename --indep-pairwise 1500 150 0.1 --out $tmpdir/$filename
    plink --vcf $dirname/$filename --extract $tmpdir/$filename.prune.in --mind 0.1 --recode vcf --out $filename.pruned
  ) &
done

wait
