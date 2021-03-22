library(purrr)
library(readxl)
library(configr)

config <- read.config("config.ini")
# OVERVIEW ----------------------------------------------------------------

# Script to read mapping sheets from the UKB mapping excel spreadsheet
# (https://biobank.ndph.ox.ac.uk/showcase/refer.cgi?id=592) into a SQQLite
# database

# CONSTANTS -------------------------------------------------------------

# UKB code mappings file
UKB_ALL_LKPS_MAPS_V2 <- config$PATHS$UKB_ALL_LKPS_MAPS_V2

# path to write code mappings as .Rdata
UKB_CODE_MAPPINGS <- config$PATHS$UKB_CODE_MAPPINGS

# path to write code mappings as a database
UKB_DB <- config$PATHS$UKB_DB

# MAIN --------------------------------------------------------------------

# read all sheets to a named list
all_lkps_maps_v2 <- UKB_ALL_LKPS_MAPS_V2 %>%
  excel_sheets() %>%
  discard(~ .x %in% c("Description", "Contents")) %>% # first 2 sheets not needed
  set_names() %>%
  map(read_excel,
      path = UKB_ALL_LKPS_MAPS_V2,
      col_types = "text")

# save as .Rdata
save(all_lkps_maps_v2, file = UKB_CODE_MAPPINGS)

# write to separate tables in SQLite database
con <- DBI::dbConnect(RSQLite::SQLite(), UKB_DB)

for (sheet in names(all_lkps_maps_v2)) {
  all_lkps_maps_v2[[sheet]]

  DBI::dbWriteTable(
    conn = con,
    name = names(all_lkps_maps_v2[sheet]),
    value = all_lkps_maps_v2[[sheet]],
    overwrite = FALSE,
    # ensure table is not inadvertently overwritten
    append = FALSE
  )
}
