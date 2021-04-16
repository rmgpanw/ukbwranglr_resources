# OVERVIEW ----------------------------------------------------------------

# Script to read UKB data dictionary and list of data codings files
# (https://biobank.ctsu.ox.ac.uk/crystal/exinfo.cgi?src=accessing_data_guide)
# into a SQQLite database.

# Note: these files are imported directly into R from the UKB website (i.e. no
# files are saved locally)

# CONSTANTS -------------------------------------------------------------
config <- configr::read.config("config.ini")

# path to write database
UKB_DB <- config$PATHS$UKB_DB

# urls for UKB data dictionary and codings file
UKB_DATA_DICTIONARY_URL <- config$PATHS$UKB_DATA_DICTIONARY_URL
UKB_CODINGS_URL <- config$PATHS$UKB_CODINGS_URL

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

# save as .Rdata
save(ukb_data_dictionary, file = config$PATHS$UKB_DATA_DICTIONARY)
save(ukb_codings, file = config$PATHS$UKB_CODINGS)

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
