import argparse
import os

import pandas as pd
import pandera.pandas as pa

LAT_MIN = -80.0
LAT_MAX = -60.0
LON_MIN = 170.0
LON_MAX = 298.0

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
        "--stdevs",
        type=int,
        nargs='?',
        default=os.getenv("SD_FROM_MEAN", 4),
        help="Maximum number of standard deviations from mean for range of Actual Central Pressure."
        )
    parser.add_argument(
        "--min",
        type=float,
        nargs='?',
        default=os.getenv("ACTCENPRES_BOUNDS_MIN", 900),
        help="Minimum Actual Central Pressure."
        )
    parser.add_argument(
        "--max",
        type=float,
        nargs='?',
        default=os.getenv("ACTCENPRES_BOUNDS_MAX", 1100),
        help="Maximum Actual Central Pressure."
        )
    parser.add_argument("filename",help="Path to ASLI csv file.")

    args = parser.parse_args()
 
    # read in current file
    df = pd.read_csv(args.filename, header=args.header)

    # compute actual central pressure standard deviation bounds
    acp_mean = df.loc[:, "actual_central_pressure (hPA)"].mean()
    acp_sd = df.loc[:, "actual_central_pressure (hPA)"].std()
    acp_sd_min = acp_mean - args.stdevs*acp_sd
    acp_sd_max = acp_mean + args.stdevs*acp_sd

    # define validation schema
    schema = pa.DataFrameSchema({
        "time (mo)": pa.Column(pa.dtypes.DateTime, coerce=True, unique=True),
        "longitude (degree)": pa.Column(float, [pa.Check.ge(LON_MIN), pa.Check.le(LON_MAX)]),
        "latitude (degree)": pa.Column(float, [pa.Check.ge(LAT_MIN), pa.Check.le(LAT_MAX)]),
        "actual_central_pressure (hPA)": pa.Column(float, [
            pa.Check.ge(0),
            pa.Check.in_range(args.min, args.max),
            pa.Check.in_range(acp_sd_min, acp_sd_max),
            ]),
        "sector_pressure (hPA) [a]": pa.Column(float, pa.Check.ge(0)),
        "relative_central_pressure (hPA) [b]": pa.Column(float, pa.Check.le(0)),
        "data_source [c]": pa.Column(str, pa.Check.isin(["ERA5", "ERA5T"])),
    })

    schema.validate(df) # validation failure raises error and stops execution, exiting with non-zero exit code

    print("All quality control checks passed.")