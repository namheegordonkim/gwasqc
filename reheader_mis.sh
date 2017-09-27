source params/pre_impute_params

missing_header_line_file=scripts/missing_header_lines.txt
missing_header_line_number=11

for i in "${@%/}"
do
  for j in $i
  do
    (tabix -H $j > $j.header
    sed -i "${missing_header_line_number}r $missing_header_line_file" $j.header
    bcftools reheader -h $j.header $j -o $j.reheadered
    tabix $j.reheadered) &
  done
done
wait
