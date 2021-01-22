#!usr/bin/env bash

# download caliber repo to `data` and unzip
wget -O data/caliber.zip https://github.com/spiros/chronological-map-phenotypes/archive/master.zip
unzip -q data/caliber.zip -d data/

# create database from csv files
RScript gen_caliber_sqlite_db.R