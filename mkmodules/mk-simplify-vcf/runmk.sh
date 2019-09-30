#!/bin/bash

find -L . \
  -type f \
  -name "*.vcf" \
  ! -name ".for_upload_to_dbSNP.vcf.gz" \
| sed "s#.vcf#.for_upload_to_dbSNP.vcf.gz#" \
| xargs mk
