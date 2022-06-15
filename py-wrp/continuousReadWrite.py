
import nidaqmx

from nidaqmx.stream_readers import (
    AnalogSingleChannelReader, AnalogMultiChannelReader)
from nidaqmx.stream_writers import (AnalogSingleChannelWriter)

from nidaqmx.constants import AcquisitionType, RegenerationMode

import matplotlib.pyplot as plt

import numpy as np


nSamples = 100
sampleRate = 100

global data_buffer
global values_read

data_buffer = np.zeros(nSamples, dtype=np.float64)
values_read = np.zeros(nSamples, dtype=np.float64)

with nidaqmx.Task() as readTask, nidaqmx.Task() as writeTask:

# PORTS + TIMING

    # read task
    readTask.ai_channels.add_ai_voltage_chan("PXI1Slot5/ai4")
    readTask.timing.cfg_samp_clk_timing(
        rate = sampleRate, 
        sample_mode=AcquisitionType.CONTINUOUS, 
        samps_per_chan=nSamples
    )

    # write task
    writeTask.ao_channels.add_ao_voltage_chan("PXI1Slot5/ao2")
    writeTask.timing.cfg_samp_clk_timing(
        rate = sampleRate, 
        sample_mode = AcquisitionType.CONTINUOUS, 
        samps_per_chan=nSamples
    )

    writeTask.out_stream.regen_mode = RegenerationMode.DONT_ALLOW_REGENERATION

# DEFINE CALLBACK
    def read_callback(task_handle, every_n_samples_event_type,
                 number_of_samples, callback_data):

        global data_buffer

        reader.read_many_sample(
            values_read,
            number_of_samples_per_channel = nSamples,
            )

        data_buffer = np.append(
            data_buffer,
            values_read,
        )
        
        return 0

    def write_callback(task_handle, every_n_samples_event_type,
                 number_of_samples, callback_data):
        global data_buffer

        write_data = data_buffer[-nSamples:]

        writer.write_many_sample(write_data)

        return 0
    
# STREAMS
    reader = AnalogSingleChannelReader(
        readTask.in_stream
    )
    writer = AnalogSingleChannelWriter(
        writeTask.out_stream, 
        auto_start=False
    )

# REGISTER CALLBACK
    readTask.register_every_n_samples_acquired_into_buffer_event(
        nSamples,
        read_callback,
    )

    writeTask.register_every_n_samples_transferred_from_buffer_event(
        nSamples,
        write_callback,
    )

    print(np.shape(values_read))
    writer.write_many_sample(values_read)
# START
    readTask.start()
    writeTask.start()
    input('press ENTER to stop')

# INITIAL DATA FLOWS
    reader.read_many_sample(
        values_read,
        number_of_samples_per_channel = nSamples,
    )




    # print(values_read)
    # plt.plot(samples)
    # plt.show()
