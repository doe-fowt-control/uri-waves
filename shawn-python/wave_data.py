import pandas as pd
from calibration import yellow_func, blue_func, red_func

# Load data
data_file = "../data/9_28_21/9_28_21_waves_5_1.8.lvm"
wave_data = pd.read_csv(
    data_file,
    sep = '\t',
    skiprows = 23,
    usecols = [0,1,2,3],
    names = ['time', 'yellow', 'red', 'blue'],
    index_col = 0
)

# Center on mean
wave_data = wave_data.apply(lambda x: x-x.mean())

wave_height = pd.DataFrame()
wave_height['yellow'] = wave_data['yellow'].apply(yellow_func)
wave_height['blue'] = wave_data['blue'].apply(blue_func)
wave_height['red'] = wave_data['red'].apply(red_func)

print(wave_height)