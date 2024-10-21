#!/usr/bin/env Rscript

# Obtain passed arguments
args = commandArgs(trailingOnly=TRUE)

# Test if there is two arguments: the output and previous file
if (length(args)!=2) {
  stop("Please provide the output file, and the file it is being compared to", call.=FALSE)
} else {

  current_output <- readr::read_csv(
    args[1]
    skip = 29
  )

  existing_file <- readr::read_csv(
    args[2],
    skip = 29
  )
  
  # Use butterfly to check there are no changes to past data
  butterfly::loupe(
    current_output,
    existing_file,
    datetime_variable = "time"
  )
}

