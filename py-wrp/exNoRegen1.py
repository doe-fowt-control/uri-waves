if __name__ == "__main__":
    # Continuous write single channel
    import numpy as np

    import nidaqmx
    from nidaqmx.stream_writers import (AnalogSingleChannelWriter)
    from nidaqmx.constants import AcquisitionType, RegenerationMode


    nSamples = 1000      # number of samples to write per channel, also to trigger callback
    sampleRate = 100    # (Hz)
    updateDelay = nSamples / sampleRate  # time between callbacks(s)

    vps = 0.25              # volts per second, rate at which to ramp voltage 
    dV = updateDelay * vps  # voltage increased every callback

    global data # initial write
    data = np.linspace(0, dV, nSamples)

    with nidaqmx.Task() as writeTask:
    # define task
        writeTask.ao_channels.add_ao_voltage_chan("PXI1Slot5/ao2")
        writeTask.timing.cfg_samp_clk_timing(
            rate = sampleRate,
            sample_mode = AcquisitionType.CONTINUOUS,
            samps_per_chan = nSamples
        )  # last arg is the buffer size for continuous output

        writeTask.out_stream.regen_mode = RegenerationMode.DONT_ALLOW_REGENERATION


        def writeCallback(task_idx, every_n_samples_event_type, num_of_samples, callback_data):
            global data

            data[:] = data[:] + dV          # modify the array
            stream.write_many_sample(data)  # write the array

            return 0

        # define stream writer
        stream = AnalogSingleChannelWriter(
            writeTask.out_stream, 
            auto_start=False # with auto_start=True it complains
        )  

        # Callback function is called whenever the buffer is out of samples to write
        writeTask.register_every_n_samples_transferred_from_buffer_event(
            nSamples, 
            writeCallback
        )

        stream.write_many_sample(data)  # first write (necessary to clear buffer)

        writeTask.start()
        input('press ENTER to stop')  # task runs for as long as ENTER is not pressed