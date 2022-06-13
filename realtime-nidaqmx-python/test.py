from classes import *

# initialize parameters with default settings
pram = wrpParams()

# create wave gauge object and add gauges
gauges = WaveGauges()
gauges.addGauge(-4, .1, "PXI1Slot5/ai2", 0)
gauges.addGauge(-3.5, .1, "PXI1Slot5/ai6", 0)
gauges.addGauge(-2, .1, "PXI1Slot5/ai4", 0)
gauges.addGauge(-0, .1, "PXI1Slot5/ai0", 1) # the '1' here indicates for prediction

# create flow object which manages transferring data to wrp
flow = DataManager(pram, gauges)

load = DataLoader('python test data - full.csv', 'python test data - fullTime.csv')

wrp = WRP(gauges)

load.generateBuffersDynamic(flow, wrp, 60)

# load.generateBuffersStatic(flow, 100)

# print(np.count_nonzero(flow.bufferValues==0))

# set up the wrp


# wrp.spectral(flow)
# wrp.inversion(flow)
wrp.reconstruct(flow)
wrp.vis(flow)

# print(flow.readNSamples)