#!usr/bin/env bash

# -n: number of dummy patients
# --file: file containing a list of FieldID's to generate dummy data for
# --out: outputfile name
# -j: number of missing values per variable

python tofu.py \
-n 100 \
--file dummy_ukb_fieldids.txt \
--out dummy_ukb_data.csv \
-j 10