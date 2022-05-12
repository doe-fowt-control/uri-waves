## Overview
This directory contains MATLAB functions to perform wave reconstruction and propagation using methods to be specified by the user. 

Two main scripts can be used, `main_1iter` and `main_niter` depending on the kind of calculation desired. The former does the calculation once and visualizes the result for a single instance while the latter does the calculation for multiple realizations and shows the average across these realizations.

Two strategies are employed within the code to account for performing inversion and reconstruction with a single wave gauge or with multiple. The user can specify which gauges to use by defining `pram.mg` - multiple gauges can be specified as a vector. The code will accomodate any number of gauges as input as long as the number doesn't exceed the total number used for measurement. The workflow is common for each method and is described below.

For the single gauge, inversion is performed using a Fast Fourier Transform. For multiple gauges, linear inversion is performed using linear regression techniques. Inversion using the Choppy wave model (cwm) [Nougier 2009] is also implemented, which takes the results of linear inversion as input.

## Workflow
Here we describe the interaction and purpose functions used in the main scripts.

`make_structs` : The call to `make_structs` initializes important parameters for the calculation. It does this by taking advantage of the MATLAB _structure_ data type, which is used to store many values in a single object. Two _structures_ are used throughout the scripts. `pram` is a set of input parameters (such as reconstruction assimilation time) which are defined in `make_structs`. `stat` exists to keep track of values of interest (such as significant wave height) as they are calculated while the code runs. `make_structs` is the only function which is meant to be modified by the user before running the main script, as it gives the user control over the simulation parameters in `pram`.

`preprocess` : Applies calibration to wave gauge data, centers data on mean, resamples at desired rate.

`subset` : Finds indices of data in full time series to use for reconstruction and spectral assimilation.

`spectral` : Uses spectral assimilation data to calculate statistics such as threshold group velocities, reconstruction bandwidth, significant wave height, peak period. 

`inversion_lin` : Uses reconstruction assimilation data to find constituent wave representation of full wave field.

`inversion_cwm` : Inversion using choppy wave model. Must be called after `inversion_lin`. Should not be used for single wave gauge worth of data.

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

Open a main file in MATLAB and run.

## Description of main files

**main_1iter.m**
Reconstruction at a single realization

**main_niter**
Reconstruction at multiple realizations and a representation of the average error across all realizations

## References
[1] F. Nouguier, C.-A. Guérin, and B. Chapron, “‘Choppy wave’ model for nonlinear gravity waves,” J. Geophys. Res., vol. 114, no. C9, p. C09012, Sep. 2009, doi: 10.1029/2008JC004984.

