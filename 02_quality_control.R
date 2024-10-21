#!/usr/bin/env Rscript
# Usage: Rscript 02_quality_control.R <current-file-path> <existing-file-path>
# Obtain passed arguments
args = commandArgs(trailingOnly=TRUE)

# Test if there is two arguments: the output and previous file
if (length(args)!=2) {
  stop("Please provide the output file, and the file it is being compared to", call.=FALSE)
} else {
  
  current_output <- readr::read_csv(
    args[1],
    skip = 29
  )
  
  # Check if we are checking a file on s3, or local 
  # The s3 file will require the use of the config file
  if (startsWith(args[2], "s3://")) {
    s3_config <- ini::read.ini(
      "~/.s3cfg"
    )
    
    # Get s3 body
    s3 <- paws::s3(
      credentials = list(
        creds = list(
          access_key_id = s3_config$default$access_key,
          secret_access_key = s3_config$default$secret_key    
        )
      ),
      endpoint = paste0(
        "https://", s3_config$default$host_base
      )
    )
    
    s3_bucket <- s3$get_object(
      # Removing s3:// pre-fix, as paws adds this itself
      Bucket = gsub(
        "s3://",
        "",
        Sys.getenv("S3_BUCKET")
      ),
      Key = paste0(
        "asli_calculation_",
        Sys.getenv("FILE_IDENTIFIER"),
        ".csv"
      )
    )
    
    existing_file <- s3_bucket$Body |> 
      rawToChar() |> 
      readr::read_csv(
        skip = 29
      )
    
  } else {
    existing_file <- readr::read_csv(
      args[2],
      skip = 29
    )
  }
  
  # Use butterfly to check there are no changes to past data
  butterfly::loupe(
    current_output,
    existing_file,
    datetime_variable = "time"
  )
}
