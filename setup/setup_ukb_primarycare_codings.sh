#!usr/bin/env bash

# TO BE RUN FROM ROOT OF ukbwranglr_resources FOLDER

# make data directory
mkdir caliber/data

# download caliber repo to `data` and unzip
wget  -O caliber/data/primarycare_codings.zip -nd  biobank.ndph.ox.ac.uk/showcase/showcase/auxdata/primarycare_codings.zip
unzip -q caliber/data/primarycare_codings.zip -d caliber/data/

# create database from csv files
RScript setup/ukb_primarycare_codings_to_db.R