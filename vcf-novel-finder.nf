#!/usr/bin/env nextflow

/*================================================================
The MORETT LAB presents...

  The VCF novel dataset builder

- A novel data set builder tool

==================================================================
Version: 0.0.1
Project repository: PENDING
==================================================================
Authors:

- Bioinformatics Design
 Israel Aguilar-Ordonez (iaguilaror@gmail)

- Bioinformatics Development
 Israel Aguilar-Ordonez (iaguilaror@gmail)

- Nextflow Port
 Israel Aguilar-Ordonez (iaguilaror@gmail)

=============================
Pipeline Processes In Brief:

Pre-processing:
  _pre1_remove_singletons_and_private

Core-processing:
  _001_select_novel

Pos-processing
	_posa_count_per_sample //could be taken out, since VCF-summarizer pipeline already counts this
	_posb_simplify_vcf_for_dbSNP_upload
	_posc1_vcf2tsv
	_posc2_consequence_cataloguer
	_posc3_coverage_gnomAD

================================================================*/

/* Define the help message as a function to call when needed *//////////////////////////////
def helpMessage() {
	log.info"""
  ==========================================
  The VCF novel dataset builder
  - A novel data set builder tool
  v${version}
  ==========================================

	Usage:

  nextflow run vcf-novel-finder.nf --vcffile <path to input 1> [--output_dir path to results ]

	  --vcffile    <- compressed vcf file for annotation;
				vcf file must be annotated with https://github.com/Iaguilaror/nf-VEPextended
				accepted extension is vcf.gz;
	  --output_dir     <- directory where results, intermediate and log files will bestored;
				default: same dir where --query_fasta resides
	  -resume	   <- Use cached results if the executed project has been run before;
				default: not activated
				This native NF option checks if anything has changed from a previous pipeline execution.
				Then, it resumes the run from the last successful stage.
				i.e. If for some reason your previous run got interrupted,
				running the -resume option will take it from the last successful pipeline stage
				instead of starting over
				Read more here: https://www.nextflow.io/docs/latest/getstarted.html#getstart-resume
	  --help           <- Shows Pipeline Information
	  --version        <- Show pipeline version
	""".stripIndent()
}

/*//////////////////////////////
  Define pipeline version
  If you bump the number, remember to bump it in the header description at the begining of this script too
*/
version = "0.0.1"

/*//////////////////////////////
  Define pipeline Name
  This will be used as a name to include in the results and intermediates directory names
*/
pipeline_name = "VCFnovelbuilder"

/*
  Initiate default values for parameters
  to avoid "WARN: Access to undefined parameter" messages
*/
params.vcffile = false  //if no inputh path is provided, value is false to provoke the error during the parameter validation block
params.help = false //default is false to not trigger help message automatically at every run
params.version = false //default is false to not trigger version message automatically at every run

/*//////////////////////////////
  If the user inputs the --help flag
  print the help message and exit pipeline
*/
if (params.help){
	helpMessage()
	exit 0
}

/*//////////////////////////////
  If the user inputs the --version flag
  print the pipeline version
*/
if (params.version){
	println "VCF novel builder v${version}"
	exit 0
}

/*//////////////////////////////
  Define the Nextflow version under which this pipeline was developed or successfuly tested
  Updated by iaguilar at FEB 2019
*/
nextflow_required_version = '18.10.1'
/*
  Try Catch to verify compatible Nextflow version
  If user Nextflow version is lower than the required version pipeline will continue
  but a message is printed to tell the user maybe it's a good idea to update her/his Nextflow
*/
try {
	if( ! nextflow.version.matches(">= $nextflow_required_version") ){
		throw GroovyException('Your Nextflow version is older than Pipeline required version')
	}
} catch (all) {
	log.error "-----\n" +
			"  This pipeline requires Nextflow version: $nextflow_required_version \n" +
      "  But you are running version: $workflow.nextflow.version \n" +
			"  The pipeline will continue but some things may not work as intended\n" +
			"  You may want to run `nextflow self-update` to update Nextflow\n" +
			"============================================================"
}

/*//////////////////////////////
  INPUT PARAMETER VALIDATION BLOCK
/* Check if inpuths were provided
 * if they were not provided, they keep the 'false' value assigned in the parameter initiation block above and this test fails
*/
if ( !file(params.vcffile).exists() ) {
  log.error "Input file does not exist\n\n" +
  "Please provide valid path for the --vcffile and make sure that it has an index \n\n" +
  "For more information, execute: nextflow run vcf-novel-finder.nf --help"
  exit 1
}

/*  Check that extension of input 1 is .vcf.gz
 * to understand regexp use, and '==~' see https://www.nextflow.io/docs/latest/script.html#regular-expressions
*/
if ( !(file(params.vcffile).getName() ==~ /.+\.vcf\.gz$/) ) {
	log.error " --vcffile must have .vcf.gz extension \n\n" +
	"For more information, execute: nextflow run summarize-vcf.nf --help"
  exit 1
}

/*
Output directory definition
Default value to create directory is the parent dir of --vcffile
*/
params.output_dir = file(params.vcffile).getParent()

/*
  Results and Intermediate directory definition
  They are always relative to the base Output Directory
  and they always include the pipeline name in the variable (pipeline_name) defined by this Script

  This directories will be automatically created by the pipeline to store files during the run
*/
results_dir = "${params.output_dir}/${pipeline_name}-results/"
intermediates_dir = "${params.output_dir}/${pipeline_name}-intermediate/"

/*//////////////////////////////
  LOG RUN INFORMATION
*/
log.info"""
==========================================
The VCF novel finder
- A novel data set builder tool
v${version}
==========================================
"""
log.info "--Nextflow metadata--"
/* define function to store nextflow metadata summary info */
def nfsummary = [:]
/* log parameter values beign used into summary */
/* For the following runtime metadata origins, see https://www.nextflow.io/docs/latest/metadata.html */
nfsummary['Resumed run?'] = workflow.resume
nfsummary['Run Name']			= workflow.runName
nfsummary['Current user']		= workflow.userName
/* string transform the time and date of run start; remove : chars and replace spaces by underscores */
nfsummary['Start time']			= workflow.start.toString().replace(":", "").replace(" ", "_")
nfsummary['Script dir']		 = workflow.projectDir
nfsummary['Working dir']		 = workflow.workDir
nfsummary['Current dir']		= workflow.launchDir
nfsummary['Launch command'] = workflow.commandLine
log.info nfsummary.collect { k,v -> "${k.padRight(15)}: $v" }.join("\n")
log.info "\n\n--Pipeline Parameters--"
/* define function to store nextflow metadata summary info */
def pipelinesummary = [:]
/* log parameter values beign used into summary */
pipelinesummary['VCFfile']			= params.vcffile
pipelinesummary['Results Dir']		= results_dir
pipelinesummary['Intermediate Dir']		= intermediates_dir
/* print stored summary info */
log.info pipelinesummary.collect { k,v -> "${k.padRight(15)}: $v" }.join("\n")
log.info "==========================================\nPipeline Start"

/*//////////////////////////////
  PIPELINE START
*/

/*
	READ INPUTS
*/

/* Load vcf files AND TABIX INDEX into channel */
Channel
  .fromPath("${params.vcffile}*")
	.toList()
  .set{ vcf_inputs }

/* _pre1_remove_singletons_and_private */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/mk-remove-singletons-and-private/*")
	.toList()
	.set{ mkfiles_pre1 }

process _pre1_remove_singletons_and_private {

	publishDir "${intermediates_dir}/_pre1_remove_singletons_and_private/",mode:"symlink"

	input:
	file sample from vcf_inputs
	file mk_files from mkfiles_pre1

	output:
	file "*.removed_singletons_and_private.vcf" into results_pre1_remove_singletons_and_private

	"""
	bash runmk.sh
	"""

}

/* _001_select_novel */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/mk-select-novel/*")
	.toList()
	.set{ mkfiles_001 }

process _001_select_novel {

	publishDir "${intermediates_dir}/_001_select_novel/",mode:"symlink"

	input:
	file sample from results_pre1_remove_singletons_and_private
	file mk_files from mkfiles_001

	output:
	file "*.novel.vcf" into results_001_select_novel, also_results_001_select_novel, again_results_001_select_novel

	"""
	bash runmk.sh
	"""

}

/* _posa_count_per_sample */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/mk-count-samples/*")
	.toList()
	.set{ mkfiles_posa }

process _posa_count_per_sample {

	publishDir "${results_dir}/_posa_count_per_sample/",mode:"copy"

	input:
	file sample from results_001_select_novel
	file mk_files from mkfiles_posa

	output:
	file "*.counts.tsv" into results_posa_count_per_sample

	"""
	bash runmk.sh
	"""

}

/* _posb_simplify_vcf_for_dbSNP_upload */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/mk-simplify-vcf/*")
	.toList()
	.set{ mkfiles_posb }

process _posb_simplify_vcf_for_dbSNP_upload {

	publishDir "${results_dir}/_posb_simplify_vcf_for_dbSNP_upload/",mode:"copy"

	input:
	file sample from also_results_001_select_novel
	file mk_files from mkfiles_posb

	output:
	file "*.for_upload_to_dbSNP.vcf.gz" into results_posb_simplify_vcf_for_dbSNP_upload

	"""
	bash runmk.sh
	"""

}

/* _posc1_vcf2tsv */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/mk-vcf2tsv/*")
	.toList()
	.set{ mkfiles_posc1 }

process _posc1_vcf2tsv {

	publishDir "${results_dir}/_posc1_vcf2tsv/",mode:"copy"

	input:
	file sample from again_results_001_select_novel
	file mk_files from mkfiles_posc1

	output:
	file "*.tsv.gz" into results_posc1_vcf2tsv, also_results_posc1_vcf2tsv

	"""
	bash runmk.sh
	"""

}

/* _posc2_consequence_cataloguer */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/mk-consequence-cataloguer/*")
	.toList()
	.set{ mkfiles_posc2 }

process _posc2_consequence_cataloguer {

	publishDir "${results_dir}/_posc2_consequence_cataloguer/",mode:"copy"

	input:
	file sample from results_posc1_vcf2tsv
	file mk_files from mkfiles_posc2

	output:
	file "*" into results_posc2_consequence_cataloguer

	"""
	bash runmk.sh
	"""

}

/* _posc3_coverage_gnomAD */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/mk-coverage-gnomAD/*")
	.toList()
	.set{ mkfiles_posc3 }

process _posc3_coverage_gnomAD {

	publishDir "${results_dir}/_posc3_coverage_gnomAD/",mode:"copy"

	input:
	file sample from also_results_posc1_vcf2tsv
	file mk_files from mkfiles_posc3

	output:
	file "*.tif"

	"""
	bash runmk.sh
	"""

}
