# OVERVIEW ----------------------------------------------------------------

# Script to read UKB data dictionary and list of data codings files
# (https://biobank.ctsu.ox.ac.uk/crystal/exinfo.cgi?src=accessing_data_guide)
# into a SQQLite database.

# Note: these files are imported directly into R from the UKB website (i.e. no
# files are saved locally)

# CONSTANTS -------------------------------------------------------------

# path to database
config <- configr::read.config("config.ini")
UKB_DB <- config$PATHS$UKB_DB

# default database location if not specified by config file is root directory of
# repo
if (is.null(UKB_DB)) {
  UKB_DB <- "ukb.db"
}

# ERROR IF DATABASE ALREADY EXISTS
if (file.exists(UKB_DB)) {
  stop("Error! Database already exists at location ", UKB_DB)
}

# urls for UKB data dictionary and codings file
UKB_DATA_DICTIONARY_URL <- "https://biobank.ctsu.ox.ac.uk/~bbdatan/Data_Dictionary_Showcase.tsv"
UKB_CODINGS_URL <- "https://biobank.ctsu.ox.ac.uk/~bbdatan/Codings.tsv"

# FUNCTIONS ---------------------------------------------------------------
# fread() a tsv file, all columns read as type character
fread_tsv_as_character <- purrr::partial(data.table::fread,
                                 colClasses = c('character'),
                                 sep = "\t",
                                 quote = " ",
                                 na.strings = c("", "NA"))

# MAIN --------------------------------------------------------------------
# read files
ukb_data_dictionary <- fread_tsv_as_character(UKB_DATA_DICTIONARY_URL)
ukb_codings <- fread_tsv_as_character(UKB_CODINGS_URL)

# write to database
con <- DBI::dbConnect(RSQLite::SQLite(), UKB_DB)

DBI::dbWriteTable(
  conn = con,
  name = "ukb_data_dictionary",
  value = ukb_data_dictionary,
  overwrite = FALSE, # ensure table is not inadvertently overwritten
  append = FALSE
)

DBI::dbWriteTable(
  conn = con,
  name = "ukb_codings",
  value = ukb_codings,
  overwrite = FALSE, # ensure table is not inadvertently overwritten
  append = FALSE
)
