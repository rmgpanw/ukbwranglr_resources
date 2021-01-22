#!usr/bin/env bash

# TO BE RUN FROM ROOT OF ukbwranglr_resources FOLDER

# make data directory
mkdir ukb_primarycare_codings/data

# download caliber repo to `data` and unzip
wget -O ukb_primarycare_codings/data/caliber.zip https://github.com/spiros/chronological-map-phenotypes/archive/master.zip
unzip -q ukb_primarycare_codings/data/caliber.zip -d ukb_primarycare_codings/data/

# create database from csv files
RScript setup/caliber_repo_to_db.R