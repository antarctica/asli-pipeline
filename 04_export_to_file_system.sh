#!/bin/bash

# Rsync the contents of $OUTPUT_DIR to $RSYNC_LOCATION
# In this case there is no need to convert file formats
# But we will specify csv files only
rsync $OUTPUT_DIR/*.csv $RSYNC_LOCATION
echo "Writing to file system, folder $RSYNC_LOCATION."