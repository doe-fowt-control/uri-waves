To get started, download the data available at the shared Google Drive folder: https://drive.google.com/drive/u/0/folders/0AAO5OBY7s6L9Uk9PVA. Preserve the `data` folder so the scripts can find it. 

filename : ‘data/mat/date/wave.mat’

.mat file which can be imported to matlab with `load` command with following elements

`time` : (nt X 1) timestamp for each data entry in seconds, starting from t=0
`data` : (nt X nx) array with wave height data
`x` : (1 X nx) locations of wave gauges in meters corresponding to columns in `data`


nx is number of wave gauges
nt is number of samples in time


Save the folder `linear-reconstruction` at the same level as `data`. 

To run this code:
Open linear_full.m. 
A file is loaded containing relevant data.
Below this is a list of important parameters which can be modified depending on the desired parameters for the simulation. This can be modified and saved to affect the entire result. 

Additional scripts
    `fourier_experiment_2_3_22` : assesses the error of a prediction made based on an FFT decomposition at a single wave gauge. 

Description of functions:
    `linear_wrapper.m` : wrapper for other functions, makes code easier to run iteratively in `linear_full.m`
    `freq_range.m` : calculates spectral information, bandwidth, and creates a specified number of frequencies and wavenumbers (deep water) based on the bandwidth and shape of the spectrum. Calculates significant wave height based on zeroth moment of the spectrum
    `linear_weights.m` : calculates linear weights for reconstruction using linear regression methods. Uses a subset of time samples
    `preprocess.m` : takes input data and resamples it at new frequency, arranges it into forms usable for other functions
    `reconstruct_one_gauge.m` : reconstructs surface for desired time range at specified wave gauge

Archived functions:
    `H_sig.m` : find significant wave height using zero-upcrossing method
    `linear_weights_sampled.m` : same as `linear_weights.m` except also selects subset of wavegauges for data
    `reconstruct.m` : deprecated
    `spectral.m` : evaluates significant wave height using spectral methods and variance, finds peak period, zero-th moment
    `reconstruct_slice.m` : deprecated. Reconstruct either at one wave gauge or at one moment in time across space

