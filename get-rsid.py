# Take a newline-delimited list of chr:pos strings and output a
# corresponding list of SNPs with dbSNP rsid.

# python get-rsid.py <reference snp list> <input snp list>

import sys

CHROM_COLNO = 0
CHROMSTART_COLNO = 1
CHROMEND_COLNO = 2
RSID_COLNO = 3
CHROM_CHR = "chr"

refSnpFilename = sys.argv[1]
mySnpFilename = sys.argv[2]

refSnpFile = open(refSnpFilename,"r")
mySnpFile = open(mySnpFilename,"r")
outputFile = open(mySnpFilename + ".rsid", "w")

for line in mySnpFile:
    stripped = line.strip('\n')
    while 1:
        try:
            refNext = refSnpFile.next()
            splitted = refNext.split('\t')
            if len(splitted) < 4:
                continue
            chrpos = splitted[CHROM_COLNO].strip("chr") + ":" + splitted[CHROMEND_COLNO]
            rsid = splitted[RSID_COLNO].strip('\n')
            if chrpos == stripped:
                outputFile.write(rsid + "\t" + stripped)
                outputFile.write("\n")
                break
        except StopIteration:
            break

refSnpFile.close()
mySnpFile.close()
outputFile.close()
