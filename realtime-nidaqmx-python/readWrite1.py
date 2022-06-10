from classes import *
from scipy import interpolate
import matplotlib.pyplot as plt
import numpy as np


# import nidaqmx
# from nidaqmx.stream_readers import (AnalogMultiChannelReader)
# from nidaqmx.stream_writers import (AnalogSingleChannelWriter)
# from nidaqmx.constants import AcquisitionType, RegenerationMode

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



with nidaqmx.Task() as readTask, nidaqmx.Task() as writeTask:

# PORTS + TIMING
    # read task
    for ai_channel in gauges.portNames:
        readTask.ai_channels.add_ai_voltage_chan(ai_channel)
    
    readTask.timing.cfg_samp_clk_timing(
        rate = flow.readSampleRate, 
        sample_mode = AcquisitionType.CONTINUOUS, 
        samps_per_chan = flow.readNSamples
    )

    # write task
    writeTask.ao_channels.add_ao_voltage_chan("PXI1Slot5/ao2")
    writeTask.timing.cfg_samp_clk_timing(
        rate = flow.writeSampleRate, 
        sample_mode = AcquisitionType.CONTINUOUS, 
        samps_per_chan = flow.writeNSamples,
    )

    # require the write task to ask for new data, rather than simply repeating
    writeTask.out_stream.regen_mode = RegenerationMode.DONT_ALLOW_REGENERATION


# DEFINE CALLBACK
    def read_callback(task_handle, every_n_samples_event_type, number_of_samples, callback_data):

    # read new data into readValues
        reader.read_many_sample(
            flow.readValues,
            number_of_samples_per_channel = flow.readNSamples,
        )
    # add new data to buffer
        flow.bufferUpdate(flow.readValues)

    # add new data to validation array
        flow.validateUpdate(flow.readValues)

        return 0

    def write_callback(task_handle, every_n_samples_event_type, number_of_samples, callback_data):

    # select the last readNSamples of the specified column (gauge) in the stored array
        readLatest = flow.readBuffer[0, -flow.readNSamples:]
    # create interpolated function from measured series
        f = interpolate.interp1d(readLatest, flow.readTime)
    # evaluate function at necessary intervals
        writeLatest = f(flow.writeTime)

        writer.write_many_sample(writeLatest)
        return 0
    
# STREAMS
    reader = AnalogMultiChannelReader( # multi channel
        readTask.in_stream)
    writer = AnalogSingleChannelWriter( # single channel
        writeTask.out_stream, 
        auto_start = False)

# REGISTER CALLBACK
    readTask.register_every_n_samples_acquired_into_buffer_event(
        flow.readNSamples,
        read_callback)

    writeTask.register_every_n_samples_transferred_from_buffer_event(
        flow.writeNSamples,
        write_callback)

# START
    writer.write_many_sample(flow.writeValues)
    readTask.start()
    writeTask.start()
    input('press ENTER to stop')
    reader.read_many_sample(
        flow.readValues,
        number_of_samples_per_channel = flow.readNSamples,
    )