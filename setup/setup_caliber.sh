#!usr/bin/env bash

# TO BE RUN FROM ROOT OF ukbwranglr_resources FOLDER

# make data directory
mkdir caliber/data

# download caliber repo to `data` and unzip
wget -O caliber/data/caliber.zip https://github.com/spiros/chronological-map-phenotypes/archive/07594b89fd7602b6e885987b56373a95359da52b.zip
unzip -q caliber/data/caliber.zip -d caliber/data/

# create database from csv files
RScript setup/caliber_repo_to_db.R