#!/usr/local/bin
# NOTE: Dependencies include:
# R, plink for data cleaning
# EIGENSOFT/EIGENSTRAT for PCA
# ShapeIT, IMPUTE2 for further QC steps

data=$1
out=$2

# step 1: exclude uncertains
plink --file $data --prune --make-bed --out $out

# step 2: update/check FAM with AD status
# no idea how to do this...

# step 3: sex check on X chromosome
plink --bfile $out --check-sex --out $out # generates .sexcheck file
# exclude non-OKs
plink --bfile $out --exclude $out.sexcheck

#
