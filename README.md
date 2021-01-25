# Overview

A collection of resources to support [`ukbwranglr`](https://rmgpanw.github.io/ukbwranglr/index.html), an R package designed to facilitate UK Biobank analyses.

# Setup

After cloning this repo, open a terminal in the root directory for this repo (where this `README` file is located) and run the following command:

```bash
make
```

This takes ~3-5 minutes to run and will:

1. Create a local R environment in this directory (in a subfolder called `renv`) with all required R packages
1. Generate a SQLite database file called `ukb.db` containing:

    - Phenotype code lists from [CALIBER](https://github.com/spiros/chronological-map-phenotypes) (table name: `'phenotype_codes'`)
    - Clinical coding classification systems and maps provided by UK Biobank ([resource 592](https://biobank.ndph.ox.ac.uk/showcase/refer.cgi?id=592))
    - The UK Biobank data dictionary and codings list (downloaded directly from the [UK Biobank website](https://biobank.ctsu.ox.ac.uk/crystal/exinfo.cgi?src=accessing_data_guide))

The following command will remove `ukb.db`, all packages installed in `renv`, and all files downloaded from UKB and CALIBER:

```bash
make clean
```

To specify a different location to build the database, before running the `make` command, create a config file in the root directory of this repo based on the following template:

```
# file paths
[PATHS]
# path to sqlite database where tables will be written
UKB_DB = /PATH/TO/MY/UKB/DATABASE
```

> NOTE: this will raise an error if a database already exists at the specified location.

# Useful links

- [UKB data dictionary and code mapping files](https://biobank.ctsu.ox.ac.uk/crystal/exinfo.cgi?src=accessing_data_guide)
- [UKB code mapping excel file](https://biobank.ndph.ox.ac.uk/ukb/refer.cgi?id=592)
