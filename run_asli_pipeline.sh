#!/bin/bash
set -e

# Read in config file
source ENVS

# Location that pipeline is stored
PIPELINE_DIRECTORY=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Activate virtual environment
source ${ASLI_VENV}

# Put all relevant directories in a list
DIR_LIST=($DATA_DIR $OUTPUT_DIR)

# Create them if they do not exist
for DIR in ${DIR_LIST[@]};
do
	if [ ! -d $DIR ]; then
  		mkdir -p $DIR
		echo "Created $DIR"
	fi
done

# Fetch land sea mask, automatically writes in data directory
# Everything is pre-set in asli functions, no arguments needed for our purpose
asli_data_lsm

# Downloading latest ERA5 data
asli_data_era5 $DATA_ARGS_ERA5

# Run calculation, specifying output location
# output.csv will need to be renamed to sensible unique identifyer 
asli_calc $DATA_DIR/era5_mean_sea_level_pressure_monthly_*.nc -o $OUTPUT_DIR/asli_calculation_$DATE.csv
# probably move into sbatch to run on lotus - not strictly required but nice for reproducibility

# Exports files to destination, either object storage of classic file system
# This also determines the file export format
case ${FILE_DESTINATION} in
	OBJECT_STORAGE|BOTH)
		s3cmd put $OUTPUT_DIR/output.csv $S3_BUCKET
		echo "Writing to Object Storage, bucket $S3_BUCKET."
		;;&
	FILE_SYSTEM|BOTH)
		# Do file system placeholder
		echo "Writing to file system, folder $RSYNC_LOCATION."
		;;
	*)
	echo "ERROR: This is not a valid destination, choose from: ${VALID_DESTINATIONS[@]}"
	exit 1
	;;
esac

# Clean up the data dir, but retain output
# If I use $DATA_DIR here it will only remove /monthly
rm -r $PIPELINE_DIRECTORY/data
