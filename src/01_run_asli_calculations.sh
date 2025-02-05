#!/bin/bash
set -e

# Run calculation, specifying output location
# output.csv will need to be renamed to sensible unique identifier 
echo "Running job on $NUM_CORES cores." 
asli_calc $DATA_DIR/era5_mean_sea_level_pressure_monthly_*.nc -o $OUTPUT_DIR/asli_calculation_$FILE_IDENTIFIER.csv -n $NUM_CORES

# If OUTPUT_PLOTTING is set to true also output plots
if [[ "${OUTPUT_PLOTTING}" == true ]]; then
    for plot_year in $(seq $START_YEAR $END_YEAR);
        do asli_plot $DATA_DIR/era5_mean_sea_level_pressure_monthly_*.nc -y $plot_year -i $OUTPUT_DIR/asli_calculation_$FILE_IDENTIFIER.csv -o $OUTPUT_DIR/asli_plot_$plot_year.png;
    done
fi