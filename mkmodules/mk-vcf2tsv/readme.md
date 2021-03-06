# mk-vcf2tsv
**Author(s):** Israel Aguilar-Ordoñez (iaguilaror@gmail.com)  
**Date:** September-2019  

---

## Module description:
Convert vcf to tsv format. 


*Outputs will be compressed.

## Module Dependencies:
* bcftools 1.9-220-gc65ba41 >
[Download and compile bcftools](https://samtools.github.io/bcftools/)

### Input(s):

An uncompressed `VCF` file(s) with extension `.vcf`, which mainly contains meta-information lines, a header and data lines with information about each position. The header names the eigth mandatory columns `CHROM, POS, ID, REF, ALT, QUAL, FILTER, INFO`, plus the columns of the VEP annotation process.

For more information about the VCF format, please go to the next link: [Variant Call Format](https://www.internationalgenome.org/wiki/Analysis/Variant%20Call%20Format/vcf-variant-call-format-version-40/)


Example line(s):
```
#CHROM  POS     ID      REF     ALT     QUAL    FILTER  INFO    FORMAT  SM-3MG3L        SM-3MG3M        SM-3MG3N        SM-3MG3O        SM-3MG3P        SM-3MG3R        SM-3MG3U        SM-3MG3V        SM-3
chr21   5227536 .       C       CTCTCCTCTCT     .       PASS    AC=3;AF=0.019;AN=152;DP=1699;ANN=TCTCCTCTCT|intergenic_variant|MODIFIER|||||||||||||||||||insertion|||||||||||||||||chr21:g.5227537_5227538i
```

### Output:

A compressed `TSV` file format.

Example line(s):

```
CHROM   POS     REF     ALT     AF_natmx        Allele  Consequence     IMPACT  SYMBOL  Gene    Feature_type    Feature BIOTYPE EXON    INTRON  HGVSc   HGVSp   cDNA_position   CDS_position    Protein_posi
chr21   5227536 C       CTCTCCTCTCT     0.019   TCTCCTCTCT      intergenic_variant      MODIFIER        .       .       .       .       .       .       .       .       .       .       .       .       .
...
```
Note that VEP annotations are now separated by tabs in an independent column.

## Module parameters:
NONE

## Testing the module:

1. Test this module locally by running,
```
bash testmodule.sh
```

2. `[>>>] Module Test Successful` should be printed in the console...

## mk-vcf2tsv

````
mk-vcf2tsv /    	               		    ## Module main directory
├── mkfile						   		    ## File in mk format, specifying the rules for building every result requested by runmk.sh
├── readme.md							    ## This document. General workflow description.
├── runmk.sh								## Script to print every file required by this module
├── test									## Test directory
│   ├── data								## Test data directory. Contains input files for testing.
└── testmodule.sh					        ## Script to test module functunality using test data
````

