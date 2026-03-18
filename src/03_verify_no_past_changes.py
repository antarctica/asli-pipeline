import argparse
import configparser
import os
from pathlib import Path

import pandas as pd

from asli.utils import configure_s3_bucket

if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--header",
        type=int,
        nargs='?',
        default=os.getenv("HEADER_LINES", 33),
        help="Number of header lines in the csv file."
        )
    parser.add_argument(
        "-n",
        "--new",
        nargs='?',
        help="Path to newly created ASLI csv file."
        )
    parser.add_argument(
        "-p",
        "--previous",
        nargs='?',
        help="Path to previously created ASLI csv file."
        )
    

    args = parser.parse_args()

    # read the newly processed file
    current = pd.read_csv(args.new, header=args.header)

    if args.previous.startswith("s3://"):
        try:
            import s3fs
        except:
            raise ImportError("s3fs dependency not available.")

        config = configparser.ConfigParser()
        config_path = os.getenv("S3_CONFIG_PATH", Path(Path.home(), ".s3cfg"))
        config.read(config_path)
        
        protocol = "https://" if config['default']['use_https'] else "http://"

        existing = pd.read_csv(
            args.previous,
            header=args.header,
            storage_options={
                "endpoint_url": protocol + config['default']['host_base'],
                "key": config['default']['access_key'],
                "secret": config['default']['secret_key'],
            }
            )
        
    else:
        existing = pd.read_csv(args.previous, header=args.header)

    # extract rows with matching datetime_variables
    # (ie previously generated data)
    current_without_new_row = current[current['time (mo)'].isin(existing['time (mo)'])]

    # Obtaining the new rows to provide in feedback
    current_new_rows = current[~current['time (mo)'].isin(existing['time (mo)'])]

    # Compare the current data with the previous data, without "new" values
    differences = current_without_new_row.compare(existing)

    if differences.empty:
        print("Verification passed: no changes to previous data.")
    else:
        print(differences)
        raise ValueError("Previous values do not match. Stopping data transfer.")
