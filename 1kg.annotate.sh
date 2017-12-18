for i in seq '1 22'
rm -f 1kg.annotations.txt
do
  gunzip -c ALL.chr$i.phase3_shapeit2_mvncall_integrated_v5_func_anno.20130502.sites.vcf.gz | grep -v '^#' | awk '{if($3!=".") print($3,$1,$2);}' >> 1kg.annotations.txt
done
