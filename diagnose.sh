#!/usr/bin/bash

numargs=$#
diagdir="./diag"

rm -rf $diagdir
mkdir -p $diagdir

while [ $# -gt 0 ]
do
	outname=$(basename $1)
	plink --bfile $1 --missing --het --out $diagdir/$outname
	shift
done

Rscript ./scripts/merge-reports-with-header.R $diagdir/*.imiss $diagdir/all.imiss
Rscript ./scripts/merge-reports-with-header.R $diagdir/*.het $diagdir/all.het
Rscript ./scripts/imiss-vs-het-custom.R $diagdir/all.imiss $diagdir/all.het diag-graph.pdf

