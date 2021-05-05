library(targets)
library(ukbwranglr)
library(magrittr)
library(future)
# library(future.callr)
library(future.batchtools)

plan(batchtools_sge, template = "sge.tmpl")
# Use tar_script() to create _targets.R and tar_edit()
# to open it again for editing.
# Then, run tar_make() to run the pipeline
# and tar_read(summary) to view the results.


# CONSTANTS ---------------------------------------------------------------
UKB_DB <- "ukb.db" 

# FUNCTIONS ---------------------------------------------------------------

source("code/caliber.R")

#' Write tables to ukb.db
#'
#' Function to write ukb data dict, codings and code mappings (resource 592)
# files, and standardised/mapped caliber codes to a SQLite database and zip this. The zipped file is created in the
# same directory as ukb.db.
#'
#' @param tables named list of dataframes to be written to the database
#' @param ukb_db_path filepath to where the database will be created
#'
#' @return The path to the zipped database file
make_ukb_db_zipped <- function(tables,
                               ukb_db_path) {
  # create db connection
  con <- DBI::dbConnect(RSQLite::SQLite(), ukb_db_path)

  # write to database - ukb_code_mappings
  purrr::imap(tables$ukb_code_mappings,
              ~ DBI::dbWriteTable(
                conn = con,
                name = .y,
                value = .x,
                overwrite = TRUE,
                append = FALSE
              ))

  # write to database - tables MINUS ukb_code_mappings
  tables[names(tables) != "ukb_code_mappings"] %>%
  purrr::imap(~ DBI::dbWriteTable(
                conn = con,
                name = .y,
                value = .x,
                overwrite = TRUE,
                append = FALSE
              ))

  # disconnect
  DBI::dbDisconnect(con)

  # zip sqlite file
  ukb_db_zip_path = paste0(ukb_db_path, ".zip")
  utils::zip(zipfile = ukb_db_zip_path,
             files = ukb_db_path)

  # return filepath
  return(ukb_db_zip_path)
}


# SETTINGS/OPTIONS --------------------------------------------------------

# Set target-specific options such as packages.
tar_option_set(packages = c("magrittr", "ukbwranglr"))

# MAIN - PIPELINE ---------------------------------------------------------

list(
  tar_target(UKB_DATA_DICT,
             get_ukb_data_dict_direct()),
  tar_target(UKB_CODINGS,
             get_ukb_codings_direct()),
  tar_target(UKB_CODE_MAPPINGS,
             get_ukb_code_mappings_direct()),
  tar_target(CALIBER_CODES_STANDARDISED_AND_MAPPED,
             get_caliber_codes_standardise_and_map(ukb_code_mappings = tar_read(UKB_CODE_MAPPINGS))),
  tar_target(UKB_DB_ZIPPED,
             make_ukb_db_zipped(
               tables = list(
                 "caliber_codes" = CALIBER_CODES_STANDARDISED_AND_MAPPED,
                 "ukb_data_dict" = UKB_DATA_DICT,
                 "ukb_codings" = UKB_CODINGS,
                 "ukb_code_mappings" = UKB_CODE_MAPPINGS
               ),
               ukb_db_path = UKB_DB
             ),
             format = "file")
)
