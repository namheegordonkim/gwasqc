snps=$1
chunksize=128
nlines=`wc -l < $snps`
nc=$((nlines/chunksize))
i=1
cat $snps | while read line
  do
    (
      echo $line \
      | perl batchUCSC.pl -d hg19 -p snp150::: \
      | cut -f5 \
      | xargs printf "$line %s\n" >> rsid.txt
    ) &
    i=$((i+1))
    if [ $i -gt $chunksize ]
      then
        wait
        i=1
    fi
done
