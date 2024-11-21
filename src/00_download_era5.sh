#!/bin/bash
set -e

# Read in config file
source ENVS

# Activate virtual environment
source ${ASLI_VENV}

# Put all relevant directories in a list
DIR_LIST=($DATA_DIR $OUTPUT_DIR)

# Create them if they do not exist
for dir in ${DIR_LIST[@]};
do
	if [ ! -d $dir ]; then
  		mkdir -p $dir
		echo "Created $dir"
	fi
done

# Fetch land sea mask, automatically writes in data directory
# Everything is pre-set in asli functions, no arguments needed for our purpose
asli_data_lsm

# Downloading latest ERA5 data, provide information to the user
echo "Requesting with the following arguments: $DATA_ARGS_ERA5".
asli_data_era5 $DATA_ARGS_ERA5