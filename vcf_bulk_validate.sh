for i in "${@%/}"
do
  for j in $i
  do
    vcf-validator $j
  done
done
