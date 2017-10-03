source params/pre_impute_params

missing_header_line_file=scripts/missing_header_lines.txt
missing_header_line_number=11

for i in "${@%/}"
do
  for j in $i
  do
    (
      sed -i "${missing_header_line_number}r $missing_header_line_file" $j
      tabix $j
    ) &
  done
done
wait
