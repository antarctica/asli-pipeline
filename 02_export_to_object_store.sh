#!/bin/bash

# Move ERA5 monthly files to $OUTPUT_DIR
scp $DATA_DIR/*.nc $OUTPUT_DIR

# Check if OUTPUT directory exists and that it contains files
if [ ! -d $OUTPUT_DIR ]; then
    echo "Error: OUTPUT directory does not exist."
    exit 1
fi

total_files=$(echo "$file_list" | wc -l)

counter=0
for file in $OUTPUT_DIR/*; do
    ((counter++))
    percentage=$((counter * 100 / total_files))

    echo -ne "Progress: ["
    for ((i = 0; i < percentage / 2; i++)); do
        echo -ne "="
    done
    echo -ne ">] $percentage% \r"

    echo -e "Sending ${file}"
    if [[ $file == *.nc ]]
    then
        msm_os send -f ${file} -c ${S3_CREDENTIALS} -b ${S3_BUCKET_ZARR}
        echo -e "\n Transfer to $S3_BUCKET_ZARR completed!"
    else 
        if [[ $file == *.csv ]]
        then
            s3cmd put ${file} $S3_BUCKET_CSV
            echo -e "\n Transfer to $S3_BUCKET_CSV completed!"
        fi
    fi
done