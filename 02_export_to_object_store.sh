#!/bin/bash

# Convert csv to parquet placeholder
s3cmd put $OUTPUT_DIR/output.csv $S3_BUCKET
echo "Writing to Object Storage, bucket $S3_BUCKET."