# mk-consequence-cataloguer
**Author(s):** Israel Aguilar-Ordoñez (iaguilaror@gmail.com)  
**Date:** September-2019  

---

## Module description:
* cataloguer.R is a tool for cataloguing consequences of novel variants.

*Outputs will be compressed.

## Module Dependencies:
* cataloguer.R

### Input(s):

A compressed `TSV` file(s) with extension `.tsv`, which mainly contains the columns of the VEP annotation process.

Example line(s):
```
CHROM   POS     REF     ALT     AF_natmx        Allele  Consequence     IMPACT  SYMBOL  Gene    Feature_type    Feature BIOTYPE EXON    INTRON  HGVSc   HGVSp   cDNA_position   CDS_position    Protein_posi
chr21   5227536 C       CTCTCCTCTCT     0.019   TCTCCTCTCT      intergenic_variant      MODIFIER        .       .       .       .       .       .       .       .       .       .       .       .       .
...
```

### Output:

A compressed `TSV` file format by each category of variant and a `SVG` file.

Example line(s) of TSV:

```
Consequence     number_of_variants      Type    General_category        First_specific_consequence
3_prime_UTR_variant     2       noncoding       UTR     3 prime UTR
3_prime_UTR_variant&NMD_transcript_variant      NA      noncoding       UTR     3 prime UTR
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

## mk-consequence-cataloguer

````
mk-consequence-cataloguer /        		    ## Module main directory
├── mkfile						   		    ## File in mk format, specifying the rules for building every result requested by runmk.sh
├── readme.md							    ## This document. General workflow description.
├── runmk.sh								## Script to print every file required by this module
├── cataloguer.R                           ## Script used in this module.
├── test									## Test directory
│   ├── data								## Test data directory. Contains input files for testing.
└── testmodule.sh					        ## Script to test module functunality using test data
````

