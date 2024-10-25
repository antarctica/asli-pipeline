#!/usr/bin/env Rscript
# Usage: Rscript 02_quality_control.R <current-file-path> $SD_FROM_MEAN $ACTCENPRES_BOUNDS_MIN $ACTCENPRES_BOUNDS_MAX $MEDIAN_ABSOLUTE_DEVIATIONS 
# Obtain passed arguments
args = commandArgs(trailingOnly=TRUE)

if (length(args)!=5) {
  stop(
    "Please provide all arguments. Inspect src/R/02_quality_checks.R for usage instructions.", call.=FALSE
  )
} else {
  # Reading in the current file, skipping lines to exclude metadata
  asli_df <- readr::read_csv(
    args[1],
    skip = 29,
    show_col_types = FALSE
  )
  
  asli_df <- asli_df |> 
    assertr::verify(
      assertr::has_all_names(
        "time",
        "lon",
        "lat",
        "ActCenPres",
        "SectorPres",
        "RelCenPres",
        "DataSource"
      )
    ) |> 
    assertr::verify(
      ActCenPres > 0,
    ) |> 
    # Check for no values outwith $SD_FROM_MEAN standard deviations from the mean
    assertr::insist(
      assertr::within_n_sds(
        as.integer(args[2])
      ),
      ActCenPres
    ) |> 
    # Check combination of columns is unique (no duplicate rows)
    assertr::assert_rows(
      assertr::col_concat,
      assertr::is_uniq,
      ActCenPres,
      SectorPres,
      RelCenPres
    ) |> 
    # Check ActCenPres is between $ACTCENPRES_BOUNDS_MIN - $ACTCENPRES_BOUNDS_MAX (in all records: min ~958, max ~998)
    assertr::assert(
      assertr::within_bounds(
        as.integer(args[3]),
        as.integer(args[4])
      ),
      ActCenPres
    ) |> 
    # Checking for outliers outwith mahalanobis distance
    # $MEDIAN_ABSOLUTE_DEVIATIONS median absolute deviations of all distances
    assertr::insist_rows(
      assertr::maha_dist, 
      assertr::within_n_mads(
        as.integer(args[5])
      ),
      dplyr::everything()
    )
  
  message(
    "All quality control checks passed."
  )
}
