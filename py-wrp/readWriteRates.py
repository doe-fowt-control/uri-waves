if __name__ == "__main__":
    import nidaqmx

    from nidaqmx.stream_readers import (
        AnalogSingleChannelReader, AnalogMultiChannelReader)
    from nidaqmx.stream_writers import (AnalogSingleChannelWriter)

    from nidaqmx.constants import AcquisitionType, RegenerationMode

    # import matplotlib.pyplot as plt

    import numpy as np

    readSampleRate = 30     # frequency to take wave measurements (Hz)
    writeSampleRate = 100   # frequency to send motor commands (Hz)

    nSamples = 100
    sampleRate = 100

    global data_buffer
    global values_read

    data_buffer = np.zeros((4, nSamples), dtype=np.float64)
    values_read = np.zeros((4, nSamples), dtype=np.float64)
    first_write = np.ones(nSamples, dtype=np.float64)


    with nidaqmx.Task() as readTask, nidaqmx.Task() as writeTask:

    # PORTS + TIMING

        # read task
        readTask.ai_channels.add_ai_voltage_chan("PXI1Slot5/ai2")
        readTask.ai_channels.add_ai_voltage_chan("PXI1Slot5/ai6")
        readTask.ai_channels.add_ai_voltage_chan("PXI1Slot5/ai4")
        readTask.ai_channels.add_ai_voltage_chan("PXI1Slot5/ai0")
        readTask.timing.cfg_samp_clk_timing(
            rate = readSampleRate, 
            sample_mode = AcquisitionType.CONTINUOUS, 
            samps_per_chan = nSamples
        )

        # write task
        writeTask.ao_channels.add_ao_voltage_chan("PXI1Slot5/ao2")
        writeTask.timing.cfg_samp_clk_timing(
            rate = writeSampleRate, 
            sample_mode = AcquisitionType.CONTINUOUS, 
            samps_per_chan = nSamples
        )

        # require the write task to ask for new data, rather than simply repeating
        writeTask.out_stream.regen_mode = RegenerationMode.DONT_ALLOW_REGENERATION

    # DEFINE CALLBACK
        def read_callback(task_handle, every_n_samples_event_type,
                    number_of_samples, callback_data):

            global data_buffer

        # read new data
            reader.read_many_sample(
                values_read,
                number_of_samples_per_channel = nSamples,
                )

        # add new data to buffer
            data_buffer = np.concatenate(
                (data_buffer, values_read), 
                axis = 1 # channels are rows, samples are columns
            )

            data_buffer
            
            return 0

        def write_callback(task_handle, every_n_samples_event_type,
                    number_of_samples, callback_data):
            global data_buffer

        # write the last nSamples of the third column of the stored array
            write_data = data_buffer[0, -nSamples:]

            writer.write_many_sample(write_data)

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
            nSamples,
            read_callback,
        )

        writeTask.register_every_n_samples_transferred_from_buffer_event(
            nSamples,
            write_callback,
        )

        # print(values_read[:, 2])
        # print(values_read.flags['C_CONTIGUOUS'])
        # print(np.shape(values_read[:, 2]))
        writer.write_many_sample(first_write)
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
