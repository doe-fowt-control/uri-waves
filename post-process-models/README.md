## Overview
This directory contains MATLAB functions to perform wave reconstruction and propagation using methods to be specified by the user. There are multiple models implemented here with a common naming convention. There are two main strategies employed for linear reconstruction methods depending on whether the user wants to use multiple wave gauges or a single wave gauge to perform reconstruction. While the overall implementation is quite similar, small changes are necessary - functions used for single wave gauge have the suffix `_1g`, while functions used for an arbitrary number of wave gauges use the suffix `_ng`.

The file `linear_ng_main0.m` is the most up to date with implementation for multiple wave gauges, and `linear_1g_main0.m` for a single wave gauge. The work flow (order of functions called) for each of these is now laid out, naming the function and its general role without the suffix. 

The Choppy wave model [Nougier 2009] is also implemented.

## Workflow
Here we describe the interaction and purpose functions used in the main scripts.

`make_structs` : The call to `make_structs` initializes important parameters for the calculation. It does this by taking advantage of the MATLAB _structure_ data type, which is used to store many values in a single object. Two _structures_ are used throughout the scripts. `pram` is a set of input parameters (such as reconstruction assimilation time) which are defined in `make_structs`. `stat` exists to keep track of values of interest (such as significant wave height) as they are calculated while the code runs. `make_structs` is the only function which is meant to be modified by the user before running the main script, as it gives the user control over the simulation parameters in `pram`.

`preprocess` : Applies calibration to wave gauge data, centers data on mean, resamples at desired rate.

`subset` : Finds indices of data in full time series to use for reconstruction and spectral assimilation.

`spectral` : Uses spectral assimilation data to calculate statistics such as threshold group velocities, reconstruction bandwidth, significant wave height, peak period. 

`decompose` : Uses reconstruction assimilation data to find constituent wave representation of full wave field.

`reconstruct` : Reconstructs constituent waves at time and location of interest.

## Run me
To run the code, you will need access to data. Data is available in the shared Google Drive folder listed below (you may need to request access). It is recommended to download the subfolder called `mat` which includes the formatted data for loading into MATLAB as is already written.
https://drive.google.com/drive/u/0/folders/0AAO5OBY7s6L9Uk9PVA. 

filename : ‘data/mat/DATE/CASE.mat’

The .mat file which can be imported to matlab with `load` command with following elements

`time` : (nt X 1) timestamp for each data entry in seconds, starting from t=0
`data` : (nt X nx) array with wave height data
`x` : (1 X nx) locations of wave gauges in meters corresponding to columns in `data`

nx is number of wave gauges
nt is number of temporal samples


Save the folder `post-process-models` at the same level as `data`. 

Open linear_#g_main#.m in MATLAB, and run.

## Description of main files

**linear_1g_main0**

- Perform reconstruction using a single probe using FFT
- Optionally plot the error between the wave propagation and measurement
- Optionally visualize reconstruction and reconstruction error

**linear_1g_main1**

- Perform reconstruction using a single probe using FFT  
- Evaluate the error between the wave propagation and measurement across
- full time series

**linear_1g_main2**

- Perform reconstruction using a single probe using FFT and calculate
- propagation error across multiple gauges

**linear_1g_main3**

- Single gauge propagation using calibration factors for 3.21.22 data,
- visualizing how prediction zone narrows as distance increases

**linear_ng_main0**

- Perform reconstruction using n probes
- Plot prediction at prediction gauge pram.pg

**choppy_main0**
- Nonlinear choppy wave model

## References
[1] F. Nouguier, C.-A. Guérin, and B. Chapron, “‘Choppy wave’ model for nonlinear gravity waves,” J. Geophys. Res., vol. 114, no. C9, p. C09012, Sep. 2009, doi: 10.1029/2008JC004984.

