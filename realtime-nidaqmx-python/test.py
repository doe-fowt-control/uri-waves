import numpy as np
from classes import *

# initialize parameters with default settings
pram = wrpParams()

# create wave gauge object and add gauges
gauges = WaveGauges()
gauges.addGauge(-4, .1, "PXI1Slot5/ai2", 0)
gauges.addGauge(-3.5, .1, "PXI1Slot5/ai6", 0)
gauges.addGauge(-2, .1, "PXI1Slot5/ai4", 0)
gauges.addGauge(-0, .1, "PXI1Slot5/ai0", 1)

# create flow object which manages transferring data to wrp
flow = DataManager(pram, gauges)

# set up the wrp
wrp = WRP(gauges)

wrp.spectral(flow)
wrp.inversion(flow)
wrp.reconstruct(flow)
# load in a new piece of data
# spectral
# inversion
# reconstruction