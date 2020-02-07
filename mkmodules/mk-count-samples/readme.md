# mk-count-samples
**Author(s):** Israel Aguilar-Ordoñez (iaguilaror@gmail.com)  
**Date:** September-2019  

---

## Module description:
List and count samples to present block data in a column format.

* final-counter.R is a tool for transforming wide to long format.

*Outputs will not be compressed.

## Module Dependencies:
* bcftools 1.9-220-gc65ba41 >
[Download and compile bcftools](https://samtools.github.io/bcftools/)

* final-counter.R

### Input(s):

An uncompressed `VCF` file(s) with extension `.vcf`, which mainly contains meta-information lines, a header and data lines with information about each position. The header names the eigth mandatory columns `CHROM, POS, ID, REF, ALT, QUAL, FILTER, INFO`, plus the columns of the VEP annotation process.

For more information about the VCF format, please go to the next link: [Variant Call Format](https://www.internationalgenome.org/wiki/Analysis/Variant%20Call%20Format/vcf-variant-call-format-version-40/)


Example line(s):
```
#CHROM  POS     ID      REF     ALT     QUAL    FILTER  INFO    FORMAT  SM-3MG3L        SM-3MG3M        SM-3MG3N        SM-3MG3O        SM-3MG3P        SM-3MG3R        SM-3MG3U        SM-3MG3V        SM-3
chr21   5227536 .       C       CTCTCCTCTCT     .       PASS    AC=3;AF=0.019;AN=152;DP=1699;ANN=TCTCCTCTCT|intergenic_variant|MODIFIER|||||||||||||||||||insertion|||||||||||||||||chr21:g.5227537_5227538i
```

### Output:

An uncompressed `TSV` file format, with counted samples.

Example line(s):

```
sample  variant_type    numbers sex     pop     chromosome
SM-3MG3L        nRefHom 43      NA      NA      NA
SM-3MG3M        nRefHom 43      NA      NA      NA
SM-3MG3N        nRefHom 43      NA      NA      NA
SM-3MG3O        nRefHom 44      NA      NA      NA
...
```

## Module parameters:
NONE

## Testing the module:

1. Test this module locally by running,
```
bash testmodule.sh
```

2. `[>>>] Module Test Successful` should be printed in the console...

## mk-count-samples

````
mk-count-samples /	               		    ## Module main directory
├── mkfile						   		    ## File in mk format, specifying the rules for building every result requested by runmk.sh
├── readme.md							    ## This document. General workflow description.
├── final-counter.R                         ## Script used in this module.
├── runmk.sh								## Script to print every file required by this module
├── test									## Test directory
│   ├── data								## Test data directory. Contains input files for testing.
└── testmodule.sh					        ## Script to test module functunality using test data
````

