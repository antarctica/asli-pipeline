#!/bin/bash
set -e

# Read in config file
source ENVS

./01_set_up_directories.sh

./02_run_asli_calculations.sh

# Exports files to destination, either object storage of classic file system
# This also determines the file export format
case ${FILE_DESTINATION} in
	OBJECT_STORAGE|BOTH)
		./03_export_to_object_store.sh
		;;&
	FILE_SYSTEM|BOTH)
		./04_export_to_file_system.sh
		;;
	*)
	echo "ERROR: This is not a valid destination, choose from: ${VALID_DESTINATIONS[@]}"
	exit 1
	;;
esac

# Clean up the data dir, but retain output
# If I use $DATA_DIR here it will only remove /monthly
rm -r $PIPELINE_DIRECTORY/data
