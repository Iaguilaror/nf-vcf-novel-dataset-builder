# nf-vcf-novel-dataset-builder
Nextflow pipeline used to build the novel variants dataset for the 100GMX project

===
'nf-vcf-novel-dataset-builder' is a pipeline tool that builds a VCF file compiling only novel variants according to dbSNP and VEP, from a VEPextended annotated VCF file. This novel selection does not include singletons and private variants. The main output is in VCF format. Additional outputs include the dataset in TSV format, and a sequence coverage from gnomAD in these sites.

Important note: input file must be previously annotated by https://github.com/Iaguilaror/nf-VEPextended

---

### Features
  **-v 0.0.1**

* Supports vcf compressed files as input.
* VCF input must be previously annotated by https://github.com/Iaguilaror/nf-VEPextended
* Results include a vcf with only novel genotypes
* Novel genotypes are defined as not found in dbSNP via bcftools annotate, and not overlapping a known variant as reported by VEP annotation
* Results include a tsv from the novel vcf dataset
* Results include a tif with the novel sites categorized from the gnomAD coverage
* Scalability and reproducibility via a Nextflow-based framework.

---

## Requirements
#### Compatible OS*:
* [Ubuntu 18.04.03 LTS](http://releases.ubuntu.com/18.04/)
* [Ubuntu 16.04 LTS](http://releases.ubuntu.com/16.04/)

\* nf-100GMX-variant-summarizer may run in other UNIX based OS and versions, but testing is required.

#### Software:
| Requirement | Version  | Required Commands * |
|:---------:|:--------:|:-------------------:|
| [bcftools](https://samtools.github.io/bcftools/) | 1.9-220-gc65ba41 | bcftools |
| [htslib](http://www.htslib.org/download/) | 1.9 | tabix, bgzip |
| [Nextflow](https://www.nextflow.io/docs/latest/getstarted.html) | 19.04.1.5072 | nextflow |
| [Plan9 port](https://github.com/9fans/plan9port) | Latest (as of 10/01/2019 ) | mk \** |
| [R](https://www.r-project.org/) | 3.4.4 | Rscript |

\* These commands must be accessible from your `$PATH` (*i.e.* you should be able to invoke them from your command line).  

\** Plan9 port builds many binaries, but you ONLY need the `mk` utility to be accessible from your command line.

---

### Installation
Download nf-vcf-novel-dataset-builder from Github repository:  
```
git clone https://github.com/Iaguilaror/nf-vcf-novel-dataset-builder
```

---

#### Test
To test nf-vcf-novel-dataset-builder's execution using test data, run:
```
./runtest.sh
```

Your console should print the Nextflow log for the run, once every process has been submitted, the following message will appear:
```
======
VCF novel finder: Basic pipeline TEST SUCCESSFUL
======
```

nf-vcf-novel-dataset-builder results for test data should be in the following file:
```
nf-vcf-novel-dataset-builder/test/results/VCFnovelbuilder-results
```

---

### Usage
To run nf-vcf-novel-dataset-builder go to the pipeline directory and execute:
```
nextflow run vcf-novel-finder.nf --vcffile <path to input 1> [--output_dir path to results ]
```

For information about options and parameters, run:
```
nextflow run vcf-novel-finder.nf --help
```

---

### Pipeline Inputs
* A compressed vcf file with extension '.vcf.gz'; the VCF must be previously annotated with https://github.com/Iaguilaror/nf-VEPextended

Example line(s):
```
##fileformat=VCFv4.2
#CHROM  POS     ID      REF     ALT     QUAL    FILTER  INFO
chr21	5101724	.	G	A	.	PASS	AC=1;AF=0.00641;AN=152;DP=903;ANN=A|intron_variant|MODIFIER|GATD3B|ENSG00000280071|Transcript|ENST00000624810.3|protein_coding||4/5|ENST00000624810.3:c.357+19987C>T|||||||||-1|cds_start_NF&cds_end_NF|SNV|HGNC|HGNC:53816||5|||ENSP00000485439||A0A096LP73|UPI0004F23660|||||||chr21:g.5101724G>A||||||||||||||||||||||||||||2.079|0.034663||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
chr21	5102165	rs1373489291	G	T	.	PASS	AC=1;AF=0.00641;AN=140;DP=853;ANN=T|intron_variant|MODIFIER|GATD3B|ENSG00000280071|Transcript|ENST00000624810.3|protein_coding||4/5|ENST00000624810.3:c.357+19546C>A|||||||rs1373489291||-1|cds_start_NF&cds_end_NF|SNV|HGNC|HGNC:53816||5|||ENSP00000485439||A0A096LP73|UPI0004F23660|||||||chr21:g.5102165G>T||||||||||||||||||||||||||||5.009|0.275409||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
```

---

### Pipeline Results
* A vcf file with `*.for_upload_to_dbSNP.vcf.gz` extension.

Example line(s):
```
##fileformat=VCFv4.2
#CHROM  POS     ID      REF     ALT     QUAL    FILTER  INFO
chr21   5227536 .       C       CTCTCCTCTCT     .       .       AF_natmx=0.019
chr21   5377617 .       C       T       .       .       AF_natmx=0.013
chr21   9886907 .       T       A       .       .       AF_natmx=0.013
```

* 3 tif files with `*.all_variants.bar_ranges.tif`, `*.SNV.bar_ranges.tif` and `*.INDEL.bar_ranges.tif` extension.

These files are graphics summarizing gnomAD coverages at sites from novel variants

---

#### References
Under the hood nf-vcf-novel-dataset-builder uses some coding tools, please include the following ciations in your work:

* Narasimhan, V., Danecek, P., Scally, A., Xue, Y., Tyler-Smith, C., & Durbin, R. (2016). BCFtools/RoH: a hidden Markov model approach for detecting autozygosity from next-generation sequencing data. Bioinformatics, 32(11), 1749-1751.
* Team, R. C. (2017). R: a language and environment for statistical computing. R Foundation for Statistical Computing, Vienna. http s. www. R-proje ct. org.

---

### Contact
If you have questions, requests, or bugs to report, please email
<iaguilaror@gmail.com>

#### Dev Team
Israel Aguilar-Ordonez <iaguilaror@gmail.com>   
