import xarray as xr
import zarr
import s3fs
import sys
import configparser
from pathlib import Path

# Parsing the .s3cfg config file
# This prevents the need for a json config
# ie stops need for multiple configs
config = configparser.ConfigParser()
config.read(Path.home() / '.s3cfg')
jasmin_store_credentials = config['default']

# Populating s3fs s3 connection using the .s3cfg config file
jasmin_s3 = s3fs.S3FileSystem(
    anon=False, secret=jasmin_store_credentials['secret_key'],
    key=jasmin_store_credentials['access_key'],
    client_kwargs={'endpoint_url': "https://" + jasmin_store_credentials['host_bucket']}
)

# Open all ERA5 data, sys.argv[1] expects a list of nc files
# e.g. data/ERA5/monthly/*.nc
era5_dataset = xr.open_mfdataset(sys.argv[1], engine="netcdf4")

# Set s3 store destination, sys.argv[2] is s3 bucket name
# e.g. s3://asli/zarr-files
s3_store = s3fs.S3Map(sys.argv[2], s3=jasmin_s3)
era5_dataset.to_zarr(store=s3_store, mode='w')