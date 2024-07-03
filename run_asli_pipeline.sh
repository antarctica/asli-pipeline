#!/bin/bash
set -e

# Read in config file
source ENVS

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

bash 01_run_asli_calculations.sh

# Exports files to destination, either object storage of classic file system
# This also determines the file export format
case ${FILE_DESTINATION} in
	OBJECT_STORAGE|BOTH)
		bash 02_export_to_object_store.sh
		;;&
	FILE_SYSTEM|BOTH)
		bash 03_export_to_file_system.sh
		;;
	*)
	echo "ERROR: This is not a valid destination, choose from: ${VALID_DESTINATIONS[@]}"
	exit 1
	;;
esac

# Clean up the data dir, but retain output
# If I use $DATA_DIR here it will only remove /monthly
rm -r $PIPELINE_DIRECTORY/data
