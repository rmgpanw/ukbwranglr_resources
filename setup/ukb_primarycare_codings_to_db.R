library(purrr)
library(readxl)

# OVERVIEW ----------------------------------------------------------------

# Script to read mapping sheets from the UKB mapping excel spreadsheet
# (https://biobank.ndph.ox.ac.uk/showcase/refer.cgi?id=592) into a SQQLite
# database

# CONSTANTS -------------------------------------------------------------

UKB_ALL_LKPS_MAPS_V2 <-"ukb_primarycare_codings/data/all_lkps_maps_v2.xlsx"

# MAIN --------------------------------------------------------------------

# read all sheets to a named list
all_lkps_maps_v2 <- UKB_ALL_LKPS_MAPS_V2 %>%
  excel_sheets() %>%
  discard(~ .x %in% c("Description", "Contents")) %>% # first 2 sheets not needed
  set_names() %>%
  map(read_excel,
      path = UKB_ALL_LKPS_MAPS_V2,
      col_types = "text")

# write to separate tables in SQLite database
con <- DBI::dbConnect(RSQLite::SQLite(), "ukb.db")

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
