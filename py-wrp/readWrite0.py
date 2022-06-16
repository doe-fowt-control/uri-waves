if __name__ == "__main__":
    import nidaqmx
    from nidaqmx.stream_readers import (AnalogMultiChannelReader)
    from nidaqmx.stream_writers import (AnalogSingleChannelWriter)
    from nidaqmx.constants import AcquisitionType, RegenerationMode

    from scipy import interpolate

    # import matplotlib.pyplot as plt

    import numpy as np

    # specify timing
    updateInterval = 1                                    # time between grabs at new data (s)

    readSampleRate = 25                                   # frequency to take wave measurements (Hz)
    readDT = 1 / readSampleRate                           # time interval between wave measurements (s)
    readNSamples = readSampleRate * updateInterval        # number of wave measurements at a time

    writeSampleRate = 100                                 # frequency to send motor commands (Hz)
    writeDT = 1 / writeSampleRate                         # time interval between motor commands (s)
    writeNSamples = writeSampleRate * updateInterval      # number of motor commands at a time

    readBufferDuration = 30                               # store this many seconds worth of data from wave gauges
    readBufferLength = readSampleRate * readBufferDuration

    # initialize arrays
    readBuffer = np.zeros((4, readBufferLength), dtype=np.float64)  # to store all data in process
    readBufferTime = np.arange(-readBufferDuration, 0, readDT)      # for reconstruction and spectral assimilation

    readValues = np.zeros((4, readNSamples), dtype=np.float64)      # to store data every time it is read
    readValuesTime = np.arange(0, updateInterval, readDT)           # for the acquired read series

    writeValues = np.ones(writeNSamples, dtype=np.float64)          # initial write
    writeValuesTime = np.arange(0, updateInterval, writeDT)         # for the generated write series

    # input channels
    channels_in = [
        "PXI1Slot5/ai2",        # gauge 0
        "PXI1Slot5/ai6",        # gauge 1
        "PXI1Slot5/ai4",        # gauge 2
        "PXI1Slot5/ai0",        # gauge 3
                                # string pot (roll)
    ]

    with nidaqmx.Task() as readTask, nidaqmx.Task() as writeTask:

    # PORTS + TIMING
        # read task
        for ai_channel in channels_in:
            readTask.ai_channels.add_ai_voltage_chan(ai_channel)
        
        readTask.timing.cfg_samp_clk_timing(
            rate = readSampleRate, 
            sample_mode = AcquisitionType.CONTINUOUS, 
            samps_per_chan = readNSamples
        )

        # write task
        writeTask.ao_channels.add_ao_voltage_chan("PXI1Slot5/ao2")
        writeTask.timing.cfg_samp_clk_timing(
            rate = writeSampleRate, 
            sample_mode = AcquisitionType.CONTINUOUS, 
            samps_per_chan = writeNSamples,
        )

        # require the write task to ask for new data, rather than simply repeating
        writeTask.out_stream.regen_mode = RegenerationMode.DONT_ALLOW_REGENERATION


    # DEFINE CALLBACK
        def read_callback(task_handle, every_n_samples_event_type, number_of_samples, callback_data):
            global readBuffer
        # read new data into readValues
            reader.read_many_sample(
                readValues,
                number_of_samples_per_channel = readNSamples,
            )
        # add new data to buffer
        
        # shift old data to the end of the matrix
            readBuffer = np.roll(readBuffer, -readNSamples)
        # write over old data with new data
            readBuffer[:, -readNSamples] = readValues

            # readBuffer = np.concatenate(
            #     (readBuffer, readValues), 
            #     axis = 1 # channels are rows, samples are columns
            # )

            # readBuffer = readBuffer[:, -readBufferLength:]

            return 0

        def write_callback(task_handle, every_n_samples_event_type, number_of_samples, callback_data):
            global readBuffer
        # select the last readNSamples of the specified column (gauge) in the stored array
            readLatest = readBuffer[0, -readNSamples:]
        # create interpolated function from measured series
            f = interpolate.interp1d(readLatest, readValuesTime)
        # evaluate function at necessary intervals
            writeLatest = f(writeValuesTime)

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
            readNSamples,
            read_callback)

        writeTask.register_every_n_samples_transferred_from_buffer_event(
            writeNSamples,
            write_callback)

    # START
        writer.write_many_sample(writeValues)
        readTask.start()
        writeTask.start()
        input('press ENTER to stop')
        reader.read_many_sample(
            readValues,
            number_of_samples_per_channel = readNSamples,
        )




        # print(values_read)
        # plt.plot(samples)
        # plt.show()
