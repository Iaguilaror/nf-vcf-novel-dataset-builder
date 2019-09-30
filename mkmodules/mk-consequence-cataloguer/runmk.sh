#!/bin/bash

find -L . \
  -type f \
  -name "*.tsv.gz" \
| sed "s#.tsv.gz#.ALL_ANALYSIS#" \
| xargs mk
