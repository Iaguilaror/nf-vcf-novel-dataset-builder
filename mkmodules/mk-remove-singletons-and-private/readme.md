# mk-remove-singletons-and-private
**Author(s):** Israel Aguilar-Ordoñez (iaguilaror@gmail.com)  
**Date:** September-2019  

---

## Module description:
Remove singletons and private variants

*Outputs will not be compressed.

## Module Dependencies:
bcftools 1.9-220-gc65ba41 >
[Download and compile bcftools](https://samtools.github.io/bcftools/)

### Input(s):

Compressed `VCF` file(s) with extension `.vcf`, which mainly contains meta-information lines, a header and data lines with information about each position. The header names the eigth mandatory columns `CHROM, POS, ID, REF, ALT, QUAL, FILTER, INFO`, plus the columns of the VEP annotation process.

For more information about the VCF format, please go to the next link: [Variant Call Format](https://www.internationalgenome.org/wiki/Analysis/Variant%20Call%20Format/vcf-variant-call-format-version-40/)


Example line(s):
```
chr21   5273143 rs1455753695    A       G       .       PASS    AC=2;AF=0.013;AN=150;DP=610;ANN=G|intergenic_variant|MODIFIER|||||||||||||||rs1455753695||||SNV|||||||||||||||||chr21:g.5273143A>G||||||||||
chr21   5290508 rs1224282273    G       A       .       PASS    AC=35;AF=0.231;AN=152;DP=3056;ANN=A|intergenic_variant|MODIFIER|||||||||||||||rs1224282273||||SNV|||||||||||||||||chr21:g.5290508G>A||||||||
chr21   5291061 rs1391270447    C       G       .       PASS    AC=1;AF=0.006494;AN=150;DP=1170;ANN=G|intergenic_variant|MODIFIER|||||||||||||||rs1391270447||||SNV|||||||||||||||||chr21:g.5291061C>G||||||
```
Please, observe that in the examples lines there are singleton (AC=1) and private (AC = 2 & GT=AA) variants.

### Output:

An uncompressed `VCF` file format, without singletons and private variants.

Example line(s):

```
#CHROM  POS     ID      REF     ALT     QUAL    FILTER  INFO    FORMAT  SM-3MG3L        SM-3MG3M        SM-3MG3N        SM-3MG3O        SM-3MG3P        SM-3MG3R        SM-3MG3U        SM-3MG3V        SM-3
chr21   5290508 rs1224282273    G       A       .       PASS    AC=35;AF=0.231;AN=152;DP=3056;ANN=A|intergenic_variant|MODIFIER|||||||||||||||rs1224282273||||SNV|||||||||||||||||chr21:g.5290508G>A||||||||
```
Note that singletons and private variants have been removed.

## Module parameters:
NONE

## Testing the module:

1. Test this module locally by running,
```
bash testmodule.sh
```

2. `[>>>] Module Test Successful` should be printed in the console...

## mk-remove-singletons-and-private directory structure

````
mk-remove-singletons-and-private /				   ## Module main directory
├── mkfile						   		    ## File in mk format, specifying the rules for building every result requested by runmk.sh
├── readme.md							    ## This document. General workflow description.
├── runmk.sh								## Script to print every file required by this module
├── test									## Test directory
│   ├── data								## Test data directory. Contains input files for testing.
└── testmodule.sh					        ## Script to test module functunality using test data
````

