#!/bin/bash
set -e

# Fetch land sea mask, automatically writes in data directory
# Everything is pre-set in asli functions, no arguments needed for our purpose
asli_data_lsm

# Downloading latest ERA5 data, provide information to the user
echo "Requesting with the following arguments: $DATA_ARGS_ERA5".
asli_data_era5 $DATA_ARGS_ERA5

# Run calculation, specifying output location
# output.csv will need to be renamed to sensible unique IDENTIFIER 
asli_calc $DATA_DIR/era5_mean_sea_level_pressure_monthly_*.nc -o $OUTPUT_DIR/asli_calculation_$FILE_IDENTIFIER.csv
# probably move into sbatch to run on lotus - not strictly required but nice for reproducibility
