#!usr/bin/env bash

# TO BE RUN FROM ROOT OF ukbwranglr_resources FOLDER

# make data directory
mkdir ukb_primarycare_codings

# download ukb primary care files to `data` and unzip
wget  -O ukb_primarycare_codings/primarycare_codings.zip -nd  biobank.ndph.ox.ac.uk/showcase/showcase/auxdata/primarycare_codings.zip
unzip -q ukb_primarycare_codings/primarycare_codings.zip -d ukb_primarycare_codings/

# create database from excel file
RScript setup/ukb_primarycare_codings_to_db.R
