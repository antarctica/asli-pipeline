#!/bin/bash

# Convert csv to parquet placeholder
duckdb -c "COPY (SELECT * FROM read_csv_auto('$OUTPUT_DIR')) TO '${$OUTPUT_DIR}/output.parquet' (FORMAT PARQUET);" 

s3cmd put $OUTPUT_DIR/output.parquet $S3_BUCKET
echo "Writing to Object Storage, bucket $S3_BUCKET."