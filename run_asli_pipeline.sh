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

# Run calculations, writes an output file in $OUTPUT_DIR
bash 01_run_asli_calculations.sh



# Exports files to destination, either object storage of classic file system
# This also determines the file export format
case ${FILE_DESTINATION} in
	OBJECT_STORAGE)
		# Run quality control checks, checks whether new data matches previous data
		# Provide old and new file
		Rscript -e 02_quality_control.R $OUTPUT_DIR/asli_calculation_$FILE_IDENTIFYER.csv $S3_BUCKET/asli_calculation_$FILE_IDENTIFYER.csv

		bash 03_export_to_object_store.sh
		;;
	# Putting in a fallthrough for BOTH
	# ie when BOTH is matched, it also runs FILE_SYSTEM
	BOTH)
		Rscript -e 02_quality_control.R $OUTPUT_DIR/asli_calculation_$FILE_IDENTIFYER.csv $S3_BUCKET/asli_calculation_$FILE_IDENTIFYER.csv

		bash 03_export_to_object_store.sh
		;&
	FILE_SYSTEM)
		Rscript -e 02_quality_control.R $OUTPUT_DIR/asli_calculation_$FILE_IDENTIFYER.csv $RSYNC_LOCATION/asli_calculation_$FILE_IDENTIFYER.csv

		bash 04_export_to_file_system.sh
		;;
	*)
	echo "ERROR: $FILE_DESTINATION is not a valid destination, choose from: ${VALID_DESTINATIONS[@]}"
	exit 1
	;;
esac

# Clean up the data dir, but retain output
# If I use $DATA_DIR here it will only remove /monthly
rm -r $PIPELINE_DIRECTORY/data
