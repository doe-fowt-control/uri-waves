from classes import *


if __name__ == "__main__":
    # initialize parameters with default settings
    pram = wrpParams()

    # create wave gauge object and add gauges
    gauges = WaveGauges()
    gauges.addGauge(-4, .1, "PXI1Slot5/ai2", 0)
    gauges.addGauge(-3.5, .1, "PXI1Slot5/ai6", 0)
    gauges.addGauge(-2, .1, "PXI1Slot5/ai4", 0)
    gauges.addGauge(-0, .1, "PXI1Slot5/ai0", 1) # the '1' here indicates for prediction

    # create flow object which manages transferring data to wrp
    flow = DataManager(
        pram,
        gauges,
        readSampleRate=30,
        writeSampleRate=30,
        updateInterval = 1,
    )

    load = DataLoader('python test data - full.csv', 'python test data - fullTime.csv')

    # initialize wrp
    wrp = WRP(gauges)

    # initialize plotter
    V = wrp.setVis(flow)

    # specify operation to be triggered whenever 'loading' data
    def callFunc(wrp, flow):
        global V
        # start_time = time.time()
        wrp.spectral(flow)
        wrp.inversion(flow)
        wrp.reconstruct(flow)
        # print(time.time() - start_time)
        wrp.updateVis(flow, V)
    with plt.ion():
        load.generateBuffersDynamic(flow, wrp, 50, callFunc)