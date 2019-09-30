#!/usr/bin/env bash

## find every vcf file
#find: -L option to include symlinks
find -L . \
  -type f \
  -name "*.vcf" \
  ! -name "*.novel.vcf" \
| sed 's#.vcf#.novel.vcf#' \
| xargs mk
