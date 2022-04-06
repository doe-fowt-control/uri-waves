This directory contains MATLAB functions to perform wave reconstruction and propagation using methods to be specified by the user. There are two main strategies employed depending on whether the user wants to use multiple wave gauges or a single wave gauge to perform reconstruction. While the overall implementation is quite similar, small changes are necessary - functions used for single wave gauge have the suffix `_1g`, while functions used for an arbitrary number of wave gauges use the suffix `_ng`.

The file `linear_main8.m` is the most up to date with implementation for multiple wave gauges, and `linear_main9.m` for a single wave gauge. The work flow (order of functions called) for each of these is now laid out, naming the function and its general role without the suffix. 

`make_structs` : The call to `make_structs` initializes important parameters for entire calculation. It does this by taking advantage of the MATLAB _structure_ data type, which is used to store values in a single object. Two structs are used throughout the scripts. `pram` is a set of input parameters, set at the beginning of the script, which establishes details such as reconstruction assimilation time and other parameters needed to make a prediction. `stat` is an object which is added to in different ways in the scripts, storing information that is calculated at one point and may need to be referenced later on (for example, the peak period of the wave series. `make_structs` is actually a special function in this implementation, as it is meant to be modified by the user to change parameters before running the main script.

`preprocess` : Applies calibration to wave gauge data, centers data on mean, resamples at reasonable rate.

`subset` : Finds indices of data in full time series to use for reconstruction and spectral assimilation.

`spectral` : Uses spectral data to find parameters based on this, such as threshold group velocities, reconstruction bandwidth, significant wave height, peak period. 

`decompose` : Finds constituent wave representation of full wave field.

`reconstruct` : Reconstructs constituent waves at time and location of interest.

To run the code, you will need access to data. Data is available in the shared Google Drive folder listed below (you may need to request access). It is recommended to download the subfolder called `mat` which includes the formatted data for loading into MATLAB as is already written.
https://drive.google.com/drive/u/0/folders/0AAO5OBY7s6L9Uk9PVA. 

filename : ‘data/mat/date/wave.mat’

The .mat file which can be imported to matlab with `load` command with following elements

`time` : (nt X 1) timestamp for each data entry in seconds, starting from t=0
`data` : (nt X nx) array with wave height data
`x` : (1 X nx) locations of wave gauges in meters corresponding to columns in `data`

nx is number of wave gauges
nt is number of temporal samples


Save the folder `linear-reconstruction` at the same level as `data`. 

Open linear_main_.m in MATLAB, and run.

A description of the files contained here:

**linear_main1**

- Perform reconstruction using a single probe using FFT
- Optionally plot the error between the wave propagation and measurement
- Optionally visualize reconstruction and reconstruction error

**linear_main2**

- Perform reconstruction using a single probe using FFT  
- Evaluate the error between the wave propagation and measurement across
- full time series

**linear_main5**

- Perform reconstruction using a single probe using FFT and calculate
- propagation error across multiple gauges

**linear_main7**

- Single gauge propagation using calibration factors for 3.21.22 data,
- visualizing how prediction zone narrows as distance increases

**linear_main8**

- Perform reconstruction using n probes
- Plot prediction at prediction gauge pram.pg

