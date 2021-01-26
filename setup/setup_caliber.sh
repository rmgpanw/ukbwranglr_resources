#!usr/bin/env bash

# TO BE RUN FROM ROOT OF ukbwranglr_resources FOLDER

# make data directory
mkdir caliber

# download caliber repo to `data` and unzip
wget -O caliber/caliber.zip https://github.com/spiros/chronological-map-phenotypes/archive/07594b89fd7602b6e885987b56373a95359da52b.zip
unzip -q caliber/caliber.zip -d caliber/

# create database from csv files
RScript setup/caliber_repo_to_db.R