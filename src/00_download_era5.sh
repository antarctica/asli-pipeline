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

# Fetch land sea mask, automatically writes in data directory
# Everything is pre-set in asli functions, no arguments needed for our purpose
asli download --lsm

# Downloading latest ERA5 data, provide information to the user
echo "Requesting with the following arguments: $DATA_ARGS_ERA5".
asli download $DATA_ARGS_ERA5

# The newer CDS API may return zip archives even when netcdf format is requested.
# Extract any downloaded .nc files that are actually zip archives.
for f in "$DATA_DIR"/era5_mean_sea_level_pressure_monthly_*.nc; do
	if [ -f "$f" ] && file "$f" | grep -q "Zip archive"; then
		tmpdir=$(mktemp -d)
		unzip -o "$f" -d "$tmpdir"
		extracted_nc=$(find "$tmpdir" -name "*.nc" | head -1)
		if [ -n "$extracted_nc" ]; then
			mv "$extracted_nc" "$f"
			echo "Extracted NetCDF to: $f"
		else
			echo "ERROR: No .nc file found inside zip archive: $f"
			rm -rf "$tmpdir"
			exit 1
		fi
		rm -rf "$tmpdir"
	fi
done