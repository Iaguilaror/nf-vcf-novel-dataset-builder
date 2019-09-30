#!/bin/bash

## This small script runs a module test with the sample data

## Export variables
# export METADATA="test/metadata/integrated_call_samples_v3.20130502.ALL.panel"

echo "[>..] test running this module with data in test/data"
## Remove old test results, if any; then create test/reults dir
rm -rf test/results
mkdir -p test/results
echo "[>>.] results will be created in test/results"
## Execute runmk.sh, it will find the basic example in test/data ; -a arg forces target creation even if results are up to date
## Move results from . to test/results
## files are *.for_upload_to_dbSNP.vcf
./runmk.sh \
&& mv test/data/*.for_upload_to_dbSNP.vcf.gz* test/results/ \
&& echo "[>>>] Module Test Successful"
