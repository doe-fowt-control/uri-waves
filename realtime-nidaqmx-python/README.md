# WRP Model Documentation (Python)

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