import pandas as pd
import numpy as np
from numpy import savetxt
from calibration_functions import *

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
blue_model = make_regression(cal_data, "blue")
red_model = make_regression(cal_data, "red")

# Calculate slope from this linearization
yellow_slope = model_slope(yellow_model)
blue_slope = model_slope(blue_model)
red_slope = model_slope(red_model)

# Save slopes as list
slopes = [yellow_slope, blue_slope, red_slope]

# Manually enter wave gauge locations in order increasing towards paddle
x_locs = [0, 3.8, 5.84]

# Save data in standard layout as csv
    # [0, :] -> calibration curve slopes
    # [1, :] -> locations
cal_data = np.array([slopes, x_locs])
savetxt('calibration/calibration.csv', cal_data, delimiter = ',')

# print(cal_data)
