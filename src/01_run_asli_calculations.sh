#!/bin/bash
set -e

# Run calculation, specifying output location
# output.csv will need to be renamed to sensible unique identifier 
asli_calc $DATA_DIR/era5_mean_sea_level_pressure_monthly_*.nc -o $OUTPUT_DIR/asli_calculation_$FILE_IDENTIFIER.csv -n $NJOBS_CALC