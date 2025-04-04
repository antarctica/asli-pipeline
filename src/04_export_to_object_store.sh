#!/bin/bash
set -e

# Check if OUTPUT directory exists and that it contains files
if [ ! -d $OUTPUT_DIR ]; then
    echo "Error: OUTPUT directory does not exist."
    exit 1
fi

total_files=$(echo "$file_list" | wc -l)

counter=0
for file in $OUTPUT_DIR/*; do
    ((counter+1))
    percentage=$((counter * 100 / total_files))

    echo -ne "Progress: ["
    for ((i = 0; i < percentage / 2; i++)); do
        echo -ne "="
    done
    echo -ne ">] $percentage% \r"
    echo -e "Sending ${file}"

    # Simply puts files in object store
    # Credentials handled via .s3cfg
    s3cmd put ${file} $S3_BUCKET
    echo -e "\n ${file} transfer to $S3_BUCKET completed!"
done

echo -e "\n Transfer to $S3_BUCKET completed!"