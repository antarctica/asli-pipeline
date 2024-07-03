#!/bin/bash

# Get file list
file_list=$(find $OUTPUT_DIR -maxdepth 2 -type f -name "*.nc" | sort)

# Check if OUTPUT directory exists and that it contains NetCDF files
if [ ! -d "OUTPUT" ] || [ ! -z "${file_list}" ]; then
    echo "Error: No .nc files found in OUTPUT directory or OUTPUT directory does not exist."
    exit 1
fi

total_files=$(echo "$file_list" | wc -l)

counter=0
for file in $file_list; do
    ((counter++))
    percentage=$((counter * 100 / total_files))

    echo -ne "Progress: ["
    for ((i = 0; i < percentage / 2; i++)); do
        echo -ne "="
    done
    echo -ne ">] $percentage% \r"

    echo -e "Sending ${file}"
    msm_os send -f ${file} -c ${S3_CREDENTIALS} -b ${S3_BUCKET}
done

echo -e "\nTransfer completed!"