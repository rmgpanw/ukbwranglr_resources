# Overview

A collection of resources to support [`ukbwranglr`](https://rmgpanw.github.io/ukbwranglr/index.html), an R package designed to facilitate UK Biobank analyses.

# Setup

After cloning this repo, open a terminal in the root directory (where this README file is located) and run the following command:

```bash
make
```

This takes ~3-5 minutes to run and will:

1. Create a local R environment in this directory (in a subfolder called `renv`) with all required R packages
1. Generate a SQLite database file called `ukb.db` containing:

    - Phenotype code lists from [CALIBER](https://github.com/spiros/chronological-map-phenotypes) (table name: `'phenotype_codes'`)
    - Code mapping tables provided by UK Biobank ([resource 592](https://biobank.ndph.ox.ac.uk/showcase/refer.cgi?id=592))

The following command will remove `ukb.db` and all downloaded UKB and CALIBER files:

```bash
make clean
```
# Useful links

- [UKB data dictionary and code mapping files](https://biobank.ctsu.ox.ac.uk/crystal/exinfo.cgi?src=accessing_data_guide)
- [UKB code mapping excel file](https://biobank.ndph.ox.ac.uk/ukb/refer.cgi?id=592)