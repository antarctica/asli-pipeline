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

bash 01_run_asli_calculations.sh

# Exports files to destination, either object storage of classic file system
# This also determines the file export format
case ${FILE_DESTINATION} in
	OBJECT_STORAGE)
		bash 02_export_to_object_store.sh
		;;
	# Putting in a fallthrough for BOTH
	# ie when BOTH is matched, it also runs FILE_SYSTEM
	BOTH)
		bash 02_export_to_object_store.sh
		;&
	FILE_SYSTEM)
		bash 03_export_to_file_system.sh
		;;
	*)
	echo "ERROR: $FILE_DESTINATION is not a valid destination, choose from: ${VALID_DESTINATIONS[@]}"
	exit 1
	;;
esac

# Clean up the data dir, but retain output
# If I use $DATA_DIR here it will only remove /monthly
rm -r $PIPELINE_DIRECTORY/data
