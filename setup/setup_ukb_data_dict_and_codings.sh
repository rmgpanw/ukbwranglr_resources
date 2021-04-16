#!usr/bin/env bash

# TO BE RUN FROM ROOT OF ukbwranglr_resources FOLDER

# make data directory
mkdir ukb_data_dict_and_codings

# download data dictionary and codings files from UKB website
wget -O ukb_data_dict_and_codings/Data_Dictionary_Showcase.tsv -nd  https://biobank.ctsu.ox.ac.uk/~bbdatan/Data_Dictionary_Showcase.tsv
wget -O ukb_data_dict_and_codings/Codings.tsv -nd  https://biobank.ctsu.ox.ac.uk/~bbdatan/Codings.tsv
