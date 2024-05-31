#!/bin/bash

set -e

# Create data directory if it is not present
DATA_DIR="data/ERA5/monthly"

if [ ! -d "$DATA_DIR" ]; then
  mkdir $DATA_DIR
fi

asli_data_lsm

# Downloading latest ERA5 data
asli_data_era5 -s 2022

# Do we need to check whether data has changed here?

# Run calculation, specifying output location
asli_calc ERA5/monthly/era5_mean_sea_level_pressure_monthly_*.nc -o /gws/nopw/j04/dit/users/thozwa/output_csv/output.csv

# Move output into s3 bucket, making sure /.s3cfg file is present
s3cmd put output_csv/output.csv s3://asli

# Clean up ERA5 data, not implementing until production
# rm  ERA5/monthly/era5_*.nc







