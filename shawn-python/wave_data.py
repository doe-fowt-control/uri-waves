import numpy as np
from numpy import loadtxt

import pandas as pd

# load calibration file
calibration_file = "calibration/calibration.csv"
calibration_data = loadtxt(calibration_file, delimiter = ',')

# Load wave data
data_file = "../data/9_28_21/9_28_21_waves_5_1.8.lvm"

wave_data = np.loadtxt(
    data_file,
    delimiter = '\t',
    skiprows = 23,
    usecols = [0, 1, 2, 3]
)

# isolate time data
time_series = wave_data[:, 0]
# reshape to concatenate with other arrays later
# times = times.reshape(times.shape[0], 1)

# isolate voltage data
voltages = wave_data[:, 1:]
# center on mean
voltages -= np.mean(voltages, axis = 0)
# apply calibration curve
heights = voltages * calibration_data[0]

# Array of locations
locs = np.ones(heights.shape) * calibration_data[1]

# Add time series to location and height series
# heights = np.concatenate((times, heights), axis=1)
# locs = np.concatenate((times, locs), axis = 1)

wave_data = np.dstack((heights, locs))

