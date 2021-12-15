To get started, download the data available at the shared Google Drive folder: https://drive.google.com/drive/u/0/folders/0AAO5OBY7s6L9Uk9PVA. Preserve the `data` folder so the scripts can find it. 

Save data as two .mat files
    'data' : matrix with wave heights recorded at every point
    'time' : array of the time in seconds. It is necessary to convert the original string to seconds


Save the folder `linear-reconstruction` at the same level as `data`. 

To run this code:
The four scripts, `edinburgh6.m`, `edinburgh6_spectral.m`, `edinburgh_spectral_irregular.m`, and `linear_full.m` have similar functionality, as they all perform reconstruction in some kind of way. If data is located at the filepath at the top of each file and formatted correctly, they should run completely. 
    `edinburgh6.m` : requires manually input frequencies for reconstruction
    `edinburgh6_spectral.m` : calculates input frequencies automatically based on spectrum
    `edinburgh_spectral_irregular.m` : was written to process data from a specific date of sampling at various inputs
    `linear_full.m` : slightly refined version which allows you to perform reconstruction and propagation as they would be done during actual operation

Description of functions:
    `freq_range.m` : calculated a specified number of frequencies and wavenumbers (deep water) based on sampled spectrum
    `H_sig.m` : find significant wave height using zero-upcrossing method
    `linear_weights.m` : calculates linear weights for reconstruction using linear regression methods. Uses a subset of time samples
    `linear_weights_sampled.m` : same as `linear_weights.m` except also selects subset of wavegauges for data
    `preprocess.m` : takes input data and resamples it at new frequency, arranges it into forms usable for other functions
    `reconstruct.m` : deprecated
    `reconstruct_one_gauge.m` : reconstructs surface for desired time range at specified wave gauge
    `reconstruct_slice.m` : deprecated. Reconstruct either at one wave gauge or at one moment in time across space
    `spectral.m` : evaluates significant wave height using spectral methods and variance, finds peak period, zero-th moment

