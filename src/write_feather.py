import pyarrow.feather as feather
import pandas as pd
import sys

# usage python write_feather.py $OUTPUT_DIR $FILE_IDENTIFIER

# Reading in csv and writing as feather
df_asli = pd.read_table(sys.argv[1] + "/asli_calculation_" + sys.argv[2] + ".csv")

feather.write_feather(df_asli, sys.argv[1] + "feather/asli_calculation_" + sys.argv[2])
