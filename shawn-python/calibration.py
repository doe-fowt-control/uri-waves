import pandas as pd
import numpy as np
from calibration_functions import make_regression, model_func

## Load calibration data
# Name of file with calibration data
cal_file = "../data/9_28_21/9_28_21_calibration2.lvm"

# Load data with pandas read_csv function
cal_data = pd.read_csv(
    cal_file,      # load file
    sep = '\t',    # define separator
    skiprows = 23, # skip labview junk
    usecols=np.arange(1,7), # select columns with relevant data
    names = [      # rename columns for make_regression function
        'yellow_g', 'red_g', 'blue_g', # gauges
        'yellow_p', 'red_p', 'blue_p', # pots
    ]
)

# Make sklearn linear model
yellow_model = make_regression(cal_data, "yellow")
red_model = make_regression(cal_data, "red")
blue_model = make_regression(cal_data, "blue")

# Save linear model as lambda function
yellow_func = model_func(yellow_model)
blue_func = model_func(blue_model)
red_func = model_func(red_model)