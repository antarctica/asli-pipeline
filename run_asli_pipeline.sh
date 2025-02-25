#!/bin/bash
set -e

# Read in config file
source ENVS

# Activate virtual environment
source ${ASLI_VENV}

# Data should already have been fetched with 00_download_era5.sh
if [ ! -d $DATA_DIR ]; then
	echo "There is no data directory. Do you need to run src/00_download_era5.sh first?"
	exit 1
fi

# Run calculations, writes an output file in $OUTPUT_DIR
bash src/01_run_asli_calculations.sh

# Script with carries out quality control checks on the data, can be configured in ENVS
# Failure of checks will stop execution
Rscript src/02_quality_checks.R "$OUTPUT_DIR/asli_calculation_$FILE_IDENTIFIER.csv" $SD_FROM_MEAN $ACTCENPRES_BOUNDS_MIN $ACTCENPRES_BOUNDS_MAX 

# Exports files to destination, either object storage of classic file system
# This also determines the file export format
case ${FILE_DESTINATION} in
	OBJECT_STORAGE)
		# Run checks on whether new data matches previous data
		# Provide old and new file
		# Only run if it is not the first run, ie there is a file to compare against
		if [[ "${FIRST_RUN}" != true ]]; then
			Rscript src/03_verify_no_past_changes.R "$OUTPUT_DIR/asli_calculation_$FILE_IDENTIFIER.csv" "$S3_BUCKET/asli_calculation_$FILE_IDENTIFIER.csv"
		fi

		bash src/04_export_to_object_store.sh
		;;
	# Putting in a fallthrough for BOTH
	# ie when BOTH is matched, it also runs FILE_SYSTEM
	BOTH)
		if [[ "${FIRST_RUN}" != true ]]; then
			Rscript src/03_verify_no_past_changes.R "$OUTPUT_DIR/asli_calculation_$FILE_IDENTIFIER.csv" "$S3_BUCKET/asli_calculation_$FILE_IDENTIFIER.csv"
		fi
		bash src/04_export_to_object_store.sh
		;&
	FILE_SYSTEM)
		if [[ "${FIRST_RUN}" != true ]]; then
			Rscript src/03_verify_no_past_changes.R "$OUTPUT_DIR/asli_calculation_$FILE_IDENTIFIER.csv" "$RSYNC_LOCATION/asli_calculation_$FILE_IDENTIFIER.csv"
		fi
		bash src/05_export_to_file_system.sh
		;;
	*)
	echo "ERROR: $FILE_DESTINATION is not a valid destination, choose from: ${VALID_DESTINATIONS[@]}"
	exit 1
	;;
esac

if [[ "${EXPORT_ROCRATE}" == true ]]; then
	python src/06_generate_rocrate.py "$BASH_VERSION"
fi

# Clean up the data dir, but retain output
# If I use $DATA_DIR here it will only remove /monthly
rm -r $PIPELINE_DIRECTORY/data
