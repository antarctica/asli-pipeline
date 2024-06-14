#!/bin/bash
set -e

# Location that pipeline is stored, referenced by most scripts
PIPELINE_DIRECTORY=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Date for indexing
DATE=$(date --utc +"%Y-%m-%d")

# Activative environment
source ${pipeline_directory}/venv/bin/activate

if [ ! -d "$DATA_DIR" ]; then
  mkdir $DATA_DIR
fi

asli_data_lsm

# Downloading latest ERA5 data
asli_data_era5 -s 2022

# Do we need to check whether data has changed here?

# Run calculation, specifying output location
# output.csv will need to be renamed to sensible unique identifyer 
asli_calc ERA5/monthly/era5_mean_sea_level_pressure_monthly_*.nc -o /gws/nopw/j04/dit/users/thozwa/output_csv/output.csv
# probably move into sbatch to run on lotus - not strictly required but nice for reproducibility

# Move output into s3 bucket, making sure /.s3cfg file is present
s3cmd put output_csv/output.csv s3://asli

# Clean up ERA5 data, not implementing until production
# rm  ERA5/monthly/era5_*.nc







