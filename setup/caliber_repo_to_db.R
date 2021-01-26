library(ukbwranglr)
library(readr)
library(purrr)
library(dplyr)
library(tidyr)
library(stringr)
library(DBI)
library(RSQLite)


# OVERVIEW ----------------------------------------------------------------

# Script to collect all CALIBER code lists into a single standardised table and
# write this to a SQLite database.

# CONSTANTS -------------------------------------------------------------
# location to write database
UKB_DB <- "ukb.db"

# caliber paths
CALIBER_ROOT <- "caliber/data/chronological-map-phenotypes-master"
CALIBER_PRIMARY <- "caliber/data/chronological-map-phenotypes-master/primary_care"
CALIBER_SECONDARY <- "caliber/data/chronological-map-phenotypes-master/secondary_care"
CSV_REGEX <- "+\\.csv$"

# get primary care file names
PRIMARY_CARE_FILES <- list.files(CALIBER_PRIMARY,
                                 pattern = CSV_REGEX)

SECONDARY_CARE_FILES <- list.files(CALIBER_SECONDARY,
                                   pattern = CSV_REGEX)

SECONDARY_CARE_FILES_ICD <- subset(SECONDARY_CARE_FILES, grepl("^ICD_", SECONDARY_CARE_FILES))
SECONDARY_CARE_FILES_OPCS <- subset(SECONDARY_CARE_FILES, grepl("^OPCS_", SECONDARY_CARE_FILES))

# FUNCTIONS ---------------------------------------------------------------
# read_csv() - all columns read as type character
read_csv_as_character <- partial(read_csv, col_types = cols(.default = "c"))

# standardising functions for primary and secondary care (ICD and OPCS4) csv files
standardise_primary_care <- as_mapper(
  ~ .x %>%
    pivot_longer(
      cols = c("Readcode", "Medcode"),
      names_to = "code_type",
      values_to = "code"
    ) %>%
    select(
      disease = Disease,
      description = ReadcodeDescr,
      category = Category,
      code_type,
      code
    )
)

standardise_secondary_care_icd10 <- as_mapper(
  ~ .x %>%
    mutate(code_type = "ICD10") %>%
    select(
      disease = Disease,
      description = ICD10codeDescr,
      category = Category,
      code_type,
      code = ICD10code
    )
)

standardise_secondary_care_opcs4 <- as_mapper(
  ~ .x %>%
    mutate(code_type = "OPCS4") %>%
    select(
      disease = Disease,
      description = OPCS4codeDescr,
      category = Category,
      code_type,
      code = 	OPCS4code
    )
)

# reads a list of csv files into a named list, standardises, then combines into single df
read_csv_to_named_list <- function(
  directory, # directory where files are located
  filenames, # vector of file names
  standardising_function, # function to process each file with
  file_ext = ".csv", # file extension to remove
  read_function = read_csv_as_character # function read files
) {
  paste(directory, filenames, sep = "/") %>%
    set_names(nm = str_replace(filenames,
                               file_ext,
                               "")) %>% # remove '.csv'
    map(read_function) %>%
    map(standardising_function) %>%
    bind_rows()
}

# MAIN --------------------------------------------------------------------

# Dictionary (NOT NEEDED)
# read dictionary and remove ".csv" from all strings
# caliber_dictionary <- read_csv_as_character(paste(CALIBER_ROOT, "dictionary.csv",
#                                                   sep = "/")) %>%
#   mutate(across(everything(), ~ str_replace(.x, ".csv", "")))


# Read files into 3 dataframes - primary care and secondary care (ICD and OPCS)
result <- vector(mode = "list", length = 3L)
names(result) = c("primary_care_codes",
                  "secondary_care_codes_icd",
                  "secondary_care_codes_opcs4")

result$primary_care_codes <- read_csv_to_named_list(CALIBER_PRIMARY,
                                             filenames = PRIMARY_CARE_FILES,
                                             standardising_function = standardise_primary_care)

result$secondary_care_codes_icd <- read_csv_to_named_list(CALIBER_SECONDARY,
                                             filenames = SECONDARY_CARE_FILES_ICD,
                                             standardising_function = standardise_secondary_care_icd10)

result$secondary_care_codes_opcs4 <- read_csv_to_named_list(CALIBER_SECONDARY,
                                                   filenames = SECONDARY_CARE_FILES_OPCS,
                                                   standardising_function = standardise_secondary_care_opcs4)

# combine
result <- bind_rows(result)

# mutate phenotype_source indicator column
result <- result %>%
  mutate(phenotype_source = "caliber")

# write to database
con <- DBI::dbConnect(RSQLite::SQLite(), UKB_DB)

DBI::dbWriteTable(
  conn = con,
  name = "phenotype_codes",
  value = result,
  overwrite = FALSE, # ensure table is not inadvertently overwritten
  append = FALSE
)


# TESTS -------------------------------------------------------------------
# test <- tbl(con, "phenotype_codes")
#
# test %>%
#   filter(code_type == "OPCS4" & disease == "Oesophageal varices") %>%
#   show_query()
#
# test_imported <- test %>%
#   filter(code_type == "OPCS4" & disease == "Oesophageal varices") %>%
#   collect()
