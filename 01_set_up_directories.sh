#!/bin/bash

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