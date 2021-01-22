# Overview

A collection of resources to support [`ukbwranglr`](https://rmgpanw.github.io/ukbwranglr/index.html), an R package desinged to facilitate UK Biobank analyses.

# Setup

After cloning this repo, open a terminal in the root directory (where this README file is located) and run the following command:

```bash
make
```

This will:

1. Create local R and python (?) environments with all required packages
1. Generate a SQLite database file called `ukb.db`

## R environment

From R, run the command `renv::restore()` to install required R packages. See the [`renv` documentation](https://rstudio.github.io/renv/articles/renv.html) for further details. 