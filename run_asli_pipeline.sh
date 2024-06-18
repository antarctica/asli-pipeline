#!/bin/bash
set -e

# Read in config file
source ENVS

# Location that pipeline is stored, referenced by most scripts
PIPELINE_DIRECTORY=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Date for indexing
DATE=$(date --utc +"%Y-%m-%d")

# Activative environment
source ${ASLI_VENV}

# Create input and output directories, if they do not already exist
if [ ! -d "$DATA_DIR" ]; then
  mkdir -p $DATA_DIR
fi

if [ ! -d "$OUTPUT_DIR" ]; then
  mkdir -p $OUTPUT_DIR
fi

# Fetch land sea mask, automatically writes in data directory
# Everything is pre-set in asli, no arguments needed for our purpose
asli_data_lsm

# Downloading latest ERA5 data
asli_data_era5 $DATA_ARGS_ERA5

# Run calculation, specifying output location
# output.csv will need to be renamed to sensible unique identifyer 
asli_calc $DATA_DIR/era5_mean_sea_level_pressure_monthly_*.nc -o $OUTPUT_DIR/output.csv
# probably move into sbatch to run on lotus - not strictly required but nice for reproducibility

# Move output into s3 bucket, making sure /.s3cfg file is present
s3cmd put $OUTPUT_DIR/output.csv s3://asli

# We can then move ERA5 data onto the object store as well OR
# Check if this can be done from the CEDA archive

# Clean up ERA5 data, not implementing until production
# rm  ERA5/monthly/era5_*.nc
