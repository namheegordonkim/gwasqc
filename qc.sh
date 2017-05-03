#!/usr/local/bin
# NOTE: Dependencies include:
# R, plink for data cleaning
# EIGENSOFT/EIGENSTRAT for PCA
# ShapeIT, IMPUTE2 for imputation

data=$1
out=$2
tmpdir="./tmp"

mkdir $tmpdir

# step 1: exclude uncertains
# do nothing--there is no known phenotype associated with the data

# step 2: update/check FAM with AD status
# no idea how to do this...

# step 3: sex check on X chromosome
plink --noweb --bfile $data --check-sex --out $out # generates .sexcheck file
# exclude non-OKs
plink --noweb --bfile $out --exclude $out.sexcheck --make-bed --out $out

# step 4: remove sex chromosomes and mtDNA from SNP arrays
plink --noweb --bfile $out --chr 1-22 --make-bed --out $out

# step 5: heterozygosity statistics
plink --noweb --bfile $out --het  --out $out

# step 5: SNP pruning by LD (specified in the doc)
plink --noweb --bfile $out --indep-pairwise 1500 150 0.1 --out $out
plink --noweb --bfile $out --extract $out.prune.in --recode --mind 0.1 --make-bed --out $out

# step 6: cryptic relatedness/IBD check
# IBD check (make .genome file)
plink --noweb --bfile $out --genome --min 0.05 --out $out
# remove relateds
plink --noweb --bfile $out --rel-ctoff --out $out

# step 7: PCA by EIGENSTRAT

# step 7a: PACKEDPED -> PACKEDANCESTRYMAP
echo genotypename:    $out.bed > $tmpdir/par.PACKEDPED.EIGENSTRAT
echo snpname:         $out.bim >> $tmpdir/par.PACKEDPED.EIGENSTRAT # or example.map, either works
echo indivname:       $out.fam >> $tmpdir/par.PACKEDPED.EIGENSTRAT # or example.ped, either works
echo outputformat:    PACKEDANCESTRYMAP >> $tmpdir/par.PACKEDPED.EIGENSTRAT
echo genotypeoutname: $out.packedancestrymapgeno >> $tmpdir/par.PACKEDPED.EIGENSTRAT
echo snpoutname:      $out.snp >> $tmpdir/par.PACKEDPED.EIGENSTRAT
echo indivoutname:    $out.ind >> $tmpdir/par.PACKEDPED.EIGENSTRAT
echo familynames:     NO >> $tmpdir/par.PACKEDPED.EIGENSTRAT

# step 7b: PACKEDANCESTRYMAP -> ANCESTRYMAP
echo genotypename:    $out.packedancestrymapgeno > $tmpdir/par.PACKEDANCESTRYMAP.ANCESTRYMAP
echo snpname:         $out.snp >> $tmpdir/par.PACKEDANCESTRYMAP.ANCESTRYMAP
echo indivname:       $out.ind >> $tmpdir/par.PACKEDANCESTRYMAP.ANCESTRYMAP
echo outputformat:    ANCESTRYMAP >> $tmpdir/par.PACKEDANCESTRYMAP.ANCESTRYMAP
echo genotypeoutname: $out.ancestrymapgeno >> $tmpdir/par.PACKEDANCESTRYMAP.ANCESTRYMAP
echo snpoutname:      $out.snp >> $tmpdir/par.PACKEDANCESTRYMAP.ANCESTRYMAP
echo indivoutname:    $out.ind >> $tmpdir/par.PACKEDANCESTRYMAP.ANCESTRYMAP

# step 7c: ANCESTRYMAP -> EIGENSTRAT
echo genotypename:    $out.ancestrymapgeno > $tmpdir/par.ANCESTRYMAP.EIGENSTRAT
echo snpname:         $out.snp >> $tmpdir/par.ANCESTRYMAP.EIGENSTRAT
echo indivname:       $out.ind >> $tmpdir/par.ANCESTRYMAP.EIGENSTRAT
echo outputformat:    EIGENSTRAT >> $tmpdir/par.ANCESTRYMAP.EIGENSTRAT
echo genotypeoutname: $out.eigenstratgeno >> $tmpdir/par.ANCESTRYMAP.EIGENSTRAT
echo snpoutname:      $out.snp >> $tmpdir/par.ANCESTRYMAP.EIGENSTRAT
echo indivoutname:    $out.ind >> $tmpdir/par.ANCESTRYMAP.EIGENSTRAT
