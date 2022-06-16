# WRP Model Documentation (Python)
The goals of this model are numerous
- implement wrp *forecasting* in real time for use by the controller
- save old forecasts to validate them once the wave has passed
- 

WRP expects to be given two local data buffers
bufferValues has the spectral assimilation data, of which reconstruction assimilation is a subset. It is caught up with real time
validateValues has an amount of data which varies depending on how far outside of the reconstruction assimilation time in either direction you want to visualize 

## Classes

### WaveGauges  
Stores information about all wave gauges. Initializes with empty list attributes `xPositions`, `calibrationSlopes`, `portNames`, `wrpRole`, which correspond to the physical location of the wave gauge, the conversion constant in m/V, the name of the local port on which to read from a NI DAQ, and whether the gauge is used for measurements in the wrp or validation. For the last, 0 corresponds to measurement and 1 to validation. Only one gauge should be set to validation.

Once instantiated, the `addGauge` method is used to add a physical wave gauge to the program. Specify the physical location where the 1D waves move in the positive x direction and the float to be at position x = 0. Calibration should already have been completed separately and the calibration constants entered manually at this point.

### wrpParams
Stores global parameters which specifically affect the physical wrp model. They are as follows.
- ta : reconstruction assimilation time
- ts : spectral assimilation time
- nf : number of frequencies to use in reconstruction
- mu : threshold parameter to determine fastest/slowest group velocities for prediction zone
- lam : regularization parameter for least squares fit

### 


- read and write
- buffer, validate, inversion