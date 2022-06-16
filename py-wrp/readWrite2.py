# adapted from continuousReadWriteManyGauges.py, which has been shown to work with error
    # nidaqmx.errors.DaqWriteError: The generation has stopped to prevent the regeneration of old samples. Your application was unable to write samples to the background buffer fast enough to prevent old samples from being regenerated.
    # To avoid this error, you can do any of the following:
    # 1. Increase the size of the background buffer by configuring the buffer.
    # 2. Increase the number of samples you write each time you invoke a write operation.
    # 3. Write samples more often.
    # 4. Reduce the sample rate.
    # 6. Reduce the number of applications your computer is executing concurrently.
    # In addition, if you do not need to write every sample that is generated, you can configure the regeneration mode to allow regeneration, and then use the Position and Offset attributes to write the desired samples.
    # Task Name: _unnamedTask<1>

    # Status Code: -200290

# but trying to use classes 
if __name__ == "__main__":
    import nidaqmx
    from classes import *

    # from tkinter import *

    from nidaqmx.stream_readers import (AnalogMultiChannelReader)
    from nidaqmx.stream_writers import (AnalogSingleChannelWriter)

    from nidaqmx.constants import AcquisitionType, RegenerationMode

    import matplotlib
    from matplotlib.figure import Figure
    # from matplotlib.backends.backend_tkagg import (FigureCanvasTkAgg, NavigationToolbar2Tk)
    import matplotlib.pyplot as plt

    import numpy as np

    from scipy.ndimage import uniform_filter1d

    # initialize parameters with default settings
    pram = wrpParams()

    # create wave gauge object and add gauges
    gauges = WaveGauges()
    gauges.addGauge(-3, .1, "PXI1Slot5/ai2", 0)
    gauges.addGauge(-2., .1, "PXI1Slot5/ai6", 0)
    gauges.addGauge(-1, .1, "PXI1Slot5/ai4", 0)
    gauges.addGauge(-0, .1, "PXI1Slot5/ai0", 1) # the '1' here indicates for prediction


    # create flow object which manages transferring data to wrp
    flow = DataManager(
        pram,
        gauges,
        readSampleRate=20,
        writeSampleRate=20,
        updateInterval = 1,
    )

    # initialize wrp
    wrp = WRP(gauges)

    V = wrp.setVis(flow)

    # # initialize plotter
    # plt.ion()

    # # global figure
    # # global writeLine
    # figure, ax = plt.subplots(figsize = (8,4))
    # plt.ylim([-.2, .2])
    # ax.axvline(0, color = 'gray', linestyle = '-', label = 'reconstruction time')
    # writeLine, = ax.plot(flow.validateTime, np.ones(flow.validateNSamples), color = 'blue', label = 'reconstructed')
    # ax.legend(loc = 'upper left')
    # plt.show()

    def plotFunc(V, newData):

        figure, ax, line = V

        line.set_ydata(newData)
        
        figure.canvas.draw()
        figure.canvas.flush_events()

    first_write = np.ones(flow.writeNSamples, dtype=np.float64)


    with plt.ion(), nidaqmx.Task() as readTask, nidaqmx.Task() as writeTask:

        # figure, ax = plt.subplots(figsize = (8,4))
        # plt.ylim([0, 10])
        # ax.axvline(0, color = 'gray', linestyle = '-', label = 'reconstruction time')
        # writeLine, = ax.plot(flow.validateTime, np.ones(flow.validateNSamples), color = 'blue', label = 'reconstructed')
        # ax.legend(loc = 'upper left')
        # V = [figure, ax, writeLine]

    # PORTS + TIMING
        # read task
        readTask.ai_channels.add_ai_voltage_chan("PXI1Slot5/ai2")
        readTask.ai_channels.add_ai_voltage_chan("PXI1Slot5/ai6")
        readTask.ai_channels.add_ai_voltage_chan("PXI1Slot5/ai4")
        readTask.ai_channels.add_ai_voltage_chan("PXI1Slot5/ai0")
        readTask.timing.cfg_samp_clk_timing(
            rate = flow.readSampleRate, 
            sample_mode=AcquisitionType.CONTINUOUS, 
            samps_per_chan=flow.readNSamples
        )

        # write task
        writeTask.ao_channels.add_ao_voltage_chan("PXI1Slot5/ao2")
        writeTask.timing.cfg_samp_clk_timing(
            rate = flow.writeSampleRate, 
            sample_mode = AcquisitionType.CONTINUOUS,
            samps_per_chan=flow.writeNSamples
        )

        # require the write task to ask for new data, rather than simply repeating
        writeTask.out_stream.regen_mode = RegenerationMode.DONT_ALLOW_REGENERATION

    # DEFINE CALLBACK
        def read_callback(task_handle, every_n_samples_event_type,
                    number_of_samples, callback_data):
            # print("read")
        # read new data into readValues
            reader.read_many_sample(
                flow.readValues,
                number_of_samples_per_channel = flow.readNSamples,
            )
        # add new data to buffer
            flow.bufferUpdate(flow.readValues)

        # add new data to validation array
            flow.validateUpdate(flow.readValues)

            wrp.spectral(flow)
            wrp.inversion(flow)
            wrp.reconstruct(flow)

            return 0

        def write_callback(task_handle, every_n_samples_event_type,
                    number_of_samples, callback_data):

            # print(' - write')
        # select the last readNSamples of the specified column (gauge) in the stored array
            # writeLatest = flow.bufferValues[0, -flow.readNSamples:]
            try:
                writeLatest = wrp.reconstructedSurfacePredicts
                # print(writeLatest)
                # print(" - - reconstruction")
                # wrp.plotFlag = True
                # writeLatest = uniform_filter1d(writeLatest, size = 5, mode = 'wrap')
                # print(writeLatest)
            except AttributeError:
                writeLatest = .05*np.ones(flow.readNSamples)
                # print(writeLatest)
            # print(writeLatest)
            writer.write_many_sample(writeLatest)

            return 0
        
    # STREAMS
        reader = AnalogMultiChannelReader( # multi channel
            readTask.in_stream
        )
        writer = AnalogSingleChannelWriter( # single channel
            writeTask.out_stream, 
            auto_start=False
        )

    # REGISTER CALLBACK
        readTask.register_every_n_samples_acquired_into_buffer_event(
            flow.readNSamples,
            read_callback,
        )

        writeTask.register_every_n_samples_transferred_from_buffer_event(
            flow.writeNSamples,
            write_callback,
        )


    # START
        writer.write_many_sample(first_write)
        readTask.start()
        writeTask.start()
    # INITIAL DATA FLOWS
        reader.read_many_sample(
            flow.readValues,
            number_of_samples_per_channel = flow.readNSamples,
        )

        
        time.sleep(2)
        try:
            while True:
                wrp.updateVis(flow, V)
                # if wrp.plotFlag:
                #     wrp.updateVis(flow, V)
                #     wrp.plotFlag = False
                # else:
                #     continue

        except KeyboardInterrupt:
            pass

        # input('press ENTER to stop')


