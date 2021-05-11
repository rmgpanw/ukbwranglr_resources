
# OVERVIEW ----------------------------------------------------------------

# Functions to collect all CALIBER code lists into a single standardised table, map
# codes from read2 -> read3 and from icd10 ->icd9, and write this to a SQLite
# database.

# Medcodes are dropped and only primary descriptions are kept for read2 and read3


# FUNCTIONS ---------------------------------------------------------------

download_caliber_repo <- function(url = "https://github.com/spiros/chronological-map-phenotypes/archive/07594b89fd7602b6e885987b56373a95359da52b.zip",
                                  commit = "07594b89fd7602b6e885987b56373a95359da52b") {
  # file paths
  caliber_repo_zip <- tempfile()
  caliber_repo_unzipped = file.path(tempdir(), paste("chronological-map-phenotypes",
                                                     commit,
                                                     sep = "-"))

  # download zip file
  download.file(url,
                destfile = caliber_repo_zip)

  # unzip
  utils::unzip(caliber_repo_zip,
               exdir = tempdir())

  # return path to downloaded and unzipped directory
  return(caliber_repo_unzipped)
}

# read_csv() - all columns read as type character
read_csv_as_character <- purrr::partial(readr::read_csv, col_types = readr::cols(.default = "c"))

# standardising functions for primary and secondary care (ICD and OPCS4) csv files
standardise_primary_care <- purrr::as_mapper(
  ~ .x %>%
    tidyr::pivot_longer(
      cols = c("Readcode", "Medcode"),
      names_to = "code_type",
      values_to = "code"
    ) %>%
    dplyr::mutate(
      phenotype_source = "caliber"
    ) %>%
    dplyr::select(
      disease = Disease,
      description = ReadcodeDescr,
      category = Category,
      code_type,
      code,
      phenotype_source
    )
)

standardise_secondary_care_icd10 <- purrr::as_mapper(
  ~ .x %>%
    dplyr::mutate(code_type = "icd10",
           phenotype_source = "caliber") %>%
    dplyr::select(
      disease = Disease,
      description = ICD10codeDescr,
      category = Category,
      code_type,
      code = ICD10code,
      phenotype_source
    )
)

standardise_secondary_care_opcs4 <- purrr::as_mapper(
  ~ .x %>%
    dplyr::mutate(code_type = "opcs4",
           phenotype_source = "caliber") %>%
    dplyr::select(
      disease = Disease,
      description = OPCS4codeDescr,
      category = Category,
      code_type,
      code = 	OPCS4code,
      phenotype_source
    )
)

# functions to reformat codes for UKB

# read2 codes: filter for only primary descriptions and remove last 2 characters
# (the last 2 characters indicate whether description is primary or not for a
# code) and remove "." from ICD-10 codes
reformat_caliber_read2 <- function(read2_df) {
  read2_df %>%
    # filter for only read2 codes
    dplyr::filter(code_type == "Readcode") %>%
    # label as 'read2' (ukbwranglr format)
    dplyr::mutate(code_type = "read2") %>%
    # filter for primary descriptions only: the last 2 characters indicate whether
    # description is the  preferred one or not
    dplyr::filter(stringr::str_detect(code, ".*00$")) %>%

    # remove last 2 characters
    dplyr::mutate(code = stringr::str_replace(code,
                              pattern = "00$",
                              replacement = ""))
}

reformat_caliber_icd10 <- function(icd10_df,
                                   ukb_code_mappings) {
  icd10_df %>%
    dplyr::mutate(code = ukbwranglr::reformat_icd10_codes(
      icd10_codes = code,
      ukb_code_mappings = ukb_code_mappings,
      input_icd10_format = "ICD10_CODE",
      output_icd10_format = "ALT_CODE"))
}

# functions to map codes from read2 to read3 and icd10 to icd9
map_caliber_sinale_disease_category <- function(df,
                                                disease,
                                                disease_category,
                                                ukb_code_mappings,
                                                from,
                                                to) {
  # process read codes only - drop medcodes

  # map to read3
  df <- df %>%
    purrr::pluck("code") %>%
    map_codes(from = from,
              to = to,
              ukb_code_mappings = ukb_code_mappings,
              codes_only = FALSE,
              preferred_description_only = TRUE,
              standardise_output = TRUE)

  # reformat
  if (is.null(df)) {
    return(NULL)
  }

  reformat_standardised_codelist(
    standardised_codelist = df,
    code_type = to,
    disease = disease,
    disease_category = disease_category,
    phenotype_source = "caliber"
  )
}

map_caliber_multiple_disease_categories <- function(df,
                                                    ukb_code_mappings,
                                                    from,
                                                    to,
                                                    verbose = TRUE) {
  # read2 to read3
  result <- unique(df$category) %>%
    purrr::set_names() %>%
    purrr::map( ~ NULL)

  total_n_disease_categories = length(names(result))
  counter <- 1

  # loop through disease categories by disease (nested for loop)
  diseases <- unique(df$disease)
  for (disease in diseases) {
    disease_df <- df[df$disease == disease, ]

    categories <- unique(disease_df$category)

    # for each disease category, map codes
    for (disease_category in categories) {
      if (verbose) {
        message(paste0("Mapping codes for ",
                       disease_category,
                       ". ",
                       counter, " of ", total_n_disease_categories))
      }

      disease_category_df <- disease_df[disease_df$category == disease_category, ]

      result[[disease_category]] <-
        map_caliber_sinale_disease_category(
          df = disease_category_df,
          disease = disease,
          disease_category = disease_category,
          ukb_code_mappings = ukb_code_mappings,
          from = from,
          to = to
        )

      counter <- counter + 1
    }
  }

  # combine list of results into a single df and return
  return(dplyr::bind_rows(result))
}

# reads a list of csv files into a named list, standardises, then combines into single df
read_csv_to_named_list_and_combine <- function(
  directory, # directory where files are located
  filenames, # vector of file names
  standardising_function, # function to process each file with
  file_ext = ".csv", # file extension to remove
  read_function = read_csv_as_character # function read files
) {
  paste(directory, filenames, sep = "/") %>%
    purrr::set_names(nm = stringr::str_replace(filenames,
                               file_ext,
                               "")) %>% # remove '.csv'
    purrr::map(read_function) %>%
    purrr::map(standardising_function) %>%
    dplyr::bind_rows()
}

# MAIN --------------------------------------------------------------------

get_caliber_codes_standardise_and_map <- function(ukb_code_mappings) {


  # Download caliber repo ---------------------------------------------------
  message("Downloading code lists from caliber repo")
  caliber_dir_path <- download_caliber_repo()

  # Set filepath constants --------------------------------------------------

  CALIBER_PRIMARY <- file.path(caliber_dir_path, "primary_care")
  CALIBER_SECONDARY <- file.path(caliber_dir_path, "secondary_care")
  CSV_REGEX <- "+\\.csv$"

  PRIMARY_CARE_FILES <- list.files(CALIBER_PRIMARY,
                                   pattern = CSV_REGEX)

  SECONDARY_CARE_FILES <- list.files(CALIBER_SECONDARY,
                                     pattern = CSV_REGEX)

  SECONDARY_CARE_FILES_ICD <- subset(SECONDARY_CARE_FILES, grepl("^ICD_", SECONDARY_CARE_FILES))
  SECONDARY_CARE_FILES_OPCS <- subset(SECONDARY_CARE_FILES, grepl("^OPCS_", SECONDARY_CARE_FILES))

  # Read CALIBER files and reformat -----------------------------------------

  # Note - currently removes medcodes and secondary descriptions for read codes

  # Read files into 3 dataframes - primary care and secondary care (ICD and OPCS)
  result <- c(
    "primary_care_codes_read2",
    "primary_care_codes_read3",
    "secondary_care_codes_icd10",
    "secondary_care_codes_icd9",
    "secondary_care_codes_opcs4"
  ) %>%
    purrr::set_names() %>%
    purrr::map(~ NULL)

  message("Reading caliber codeslists into R and reformtting")
  result$primary_care_codes_read2 <-
    read_csv_to_named_list_and_combine(CALIBER_PRIMARY,
                           filenames = PRIMARY_CARE_FILES,
                           standardising_function = standardise_primary_care) %>%
    reformat_caliber_read2()

  result$secondary_care_codes_icd10 <-
    read_csv_to_named_list_and_combine(CALIBER_SECONDARY,
                           filenames = SECONDARY_CARE_FILES_ICD,
                           standardising_function = standardise_secondary_care_icd10) %>%
    reformat_caliber_icd10(ukb_code_mappings = ukb_code_mappings)

  result$secondary_care_codes_opcs4 <-
    read_csv_to_named_list_and_combine(CALIBER_SECONDARY,
                           filenames = SECONDARY_CARE_FILES_OPCS,
                           standardising_function = standardise_secondary_care_opcs4)


  # Map codes (read2 - read3,  icd10 - icd9) --------------------------------
  message("Mapping read2 codes to read3")
  result$primary_care_codes_read3 <-
    map_caliber_multiple_disease_categories(
      result$primary_care_codes_read2,
      ukb_code_mappings = ukb_code_mappings,
      from = "read2",
      to = "read3"
    )

  message("Mapping icd10 to icd9 codes")
  result$secondary_care_codes_icd9 <-
    map_caliber_multiple_disease_categories(
      result$secondary_care_codes_icd10,
      ukb_code_mappings = ukb_code_mappings,
      from = "icd10",
      to = "icd9"
    )

  # combine
  message("Concatenating results")
  dplyr::bind_rows(result)
}
