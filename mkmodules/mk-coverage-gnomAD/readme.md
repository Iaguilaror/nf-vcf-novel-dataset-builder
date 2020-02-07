# mk-coverage-gnomAD
**Author(s):** Israel Aguilar-Ordoñez (iaguilaror@gmail.com)  
**Date:** September-2019  

---

## Module description:
* coverage-analyzer.R is a tool for plotting coverage of gnomAD project.

*Outputs will be compressed.

## Module Dependencies:
* coverage-analyzer.R

### Input(s):

A compressed `TSV` file(s) with extension `.tsv`, which mainly contains the columns of the VEP annotation process.

Example line(s):
```
CHROM   POS     REF     ALT     AF_natmx        Allele  Consequence     IMPACT  SYMBOL  Gene    Feature_type    Feature BIOTYPE EXON    INTRON  HGVSc   HGVSp   cDNA_position   CDS_position    Protein_posi
chr21   5227536 C       CTCTCCTCTCT     0.019   TCTCCTCTCT      intergenic_variant      MODIFIER        .       .       .       .       .       .       .       .       .       .       .       .       .
...
```

### Output:

`.tif` file sformat by each category of variant.

## Module parameters:
NONE

## Testing the module:

1. Test this module locally by running,
```
bash testmodule.sh
```

2. `[>>>] Module Test Successful` should be printed in the console...

## mk-coverage-gnomAD

````
mk-coverage-gnomAD /               		    ## Module main directory
├── mkfile						   		    ## File in mk format, specifying the rules for building every result requested by runmk.sh
├── readme.md							    ## This document. General workflow description.
├── runmk.sh								## Script to print every file required by this module
├── coverage-analyzer.R                           ## Script used in this module.
├── test									## Test directory
│   ├── data								## Test data directory. Contains input files for testing.
└── testmodule.sh					        ## Script to test module functunality using test data
````

