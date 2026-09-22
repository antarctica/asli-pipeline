import argparse
import os

import pandas as pd
import pandera.pandas as pa

LAT_MIN = -80.0
LAT_MAX = -60.0
LON_MIN = 170.0
LON_MAX = 298.0


def _check_and_report_missing_months(series: pd.Series) -> bool:
    if series.empty:
        return True

    unique_dates = series.drop_duplicates().sort_values()
    expected = pd.date_range(
        start=unique_dates.min(), end=unique_dates.max(), freq="MS"
    )

    # Calculate difference between expected and actual
    missing = expected.difference(unique_dates)

    if not missing.empty:
        missing_fmt = missing.strftime("%Y-%m-%d").tolist()
        raise ValueError(f"Time series missing {len(missing)} month(s): {missing_fmt}")

    return True


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--header",
        type=int,
        nargs="?",
        default=os.getenv("HEADER_LINES", "34"),
        help="Number of header lines in the csv file.",
    )
    parser.add_argument(
        "-n",
        "--stdevs",
        type=int,
        nargs="?",
        default=os.getenv("SD_FROM_MEAN", "4"),
        help="Maximum number of standard deviations from mean for range of Actual Central Pressure.",
    )
    parser.add_argument(
        "--min",
        type=float,
        nargs="?",
        default=os.getenv("ACTCENPRES_BOUNDS_MIN", "900"),
        help="Minimum Actual Central Pressure.",
    )
    parser.add_argument(
        "--max",
        type=float,
        nargs="?",
        default=os.getenv("ACTCENPRES_BOUNDS_MAX", "1100"),
        help="Maximum Actual Central Pressure.",
    )
    parser.add_argument("filename", help="Path to ASLI csv file.")

    args = parser.parse_args()
    stdevs = int(args.stdevs)
    min_pressure = int(args.min)
    max_pressure = int(args.max)

    # read in current file
    df = pd.read_csv(args.filename, header=args.header)

    # compute actual central pressure standard deviation bounds
    acp_mean = df.loc[:, "actual_central_pressure (hPa)"].mean()
    acp_sd = df.loc[:, "actual_central_pressure (hPa)"].std()
    acp_sd_min = acp_mean - stdevs * acp_sd
    acp_sd_max = acp_mean + stdevs * acp_sd

    # define validation schema
    schema = pa.DataFrameSchema(
        {
            "time (mo)": pa.Column(
                pa.dtypes.DateTime,
                checks=pa.Check(_check_and_report_missing_months),
                coerce=True,
                unique=True,
            ),
            "longitude (degree)": pa.Column(
                float, checks=[pa.Check.ge(LON_MIN), pa.Check.le(LON_MAX)]
            ),
            "latitude (degree)": pa.Column(
                float, checks=[pa.Check.ge(LAT_MIN), pa.Check.le(LAT_MAX)]
            ),
            "actual_central_pressure (hPa)": pa.Column(
                float,
                checks=[
                    pa.Check.ge(0),
                    pa.Check.in_range(min_pressure, max_pressure),
                    pa.Check.in_range(acp_sd_min, acp_sd_max),
                ],
            ),
            "sector_pressure (hPa) [a]": pa.Column(float, checks=pa.Check.ge(0)),
            "relative_central_pressure (hPa) [b]": pa.Column(
                float, checks=pa.Check.le(0)
            ),
            "data_source [c] [d]": pa.Column(
                str, checks=pa.Check.isin(["ERA5", "ERA5T"])
            ),
        }
    )

    # validation failure raises error and stops execution, exiting with non-zero exit code
    schema.validate(df)

    print("All quality control checks passed.")
