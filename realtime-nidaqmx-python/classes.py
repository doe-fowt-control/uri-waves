import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import welch
from scipy import linalg

from numpy import genfromtxt
my_data = genfromtxt('wave_sample.csv', delimiter=',')
my_data = my_data[1:,:]

class WaveGauges:
    '''
        A class to hold all wave gauges and their pertinent information
    '''
    def __init__(self):
        self.xPositions = []
        self.calibrationSlopes = []
        self.portNames = []
        self.wrpRole = []      # 0 = measurement gauge, 1 = prediction gauge

    def addGauge(self, position, slope, name, role):
        self.xPositions.append(position)
        self.calibrationSlopes.append(slope)
        self.portNames.append(name)
        self.wrpRole.append(role)

    def nGauges(self):
        # find number of active wave gauges
        return(len(self.xPositions))

    def measurementIndex(self):
        # find where the measurements should be taken
        mg = [i for i, e in enumerate(self.wrpRole) if e == 0]
        return mg

    def predictionIndex(self):
        # find where the prediction should be made
        pg = [i for i, e in enumerate(self.wrpRole) if e != 0]
        return pg

class wrpParams:
    def __init__(self):
        # wrp parameters
        self.ta = 10            # reconstruction assimilation time
        self.ts = 30            # spectral assimilation time
        self.nf = 100           # number of frequencies to use for reconstruction
        self.mu = 0.05          
        self.lam = 10

class FlowManager:
    def __init__(self, pram, gauges):
        
        self.readSampleRate = 30    # frequency to take wave measurements (Hz)
        self.writeSampleRate = 100  # frequency to send motor commands (Hz)

        # should eventually be based on the actual (calculated) prediction zone
        self.updateInterval = 1     # time between grabs at new data (s)
        
        # number of channels from which to read
        self.nChannels = gauges.nGauges()

        # time interval between wave measurements (s)
        self.readDT = 1 / self.readSampleRate
        self.writeDT = 1 / self.writeSampleRate

        # set up buffer - samples, values, time -
        self.bufferNSamples = self.readSampleRate * pram.ts
        self.bufferValues = np.zeros((self.nChannels, self.bufferNSamples), dtype=np.float64) 
        self.bufferTime = np.arange(-pram.ts, 0, self.readDT)

        # initialize read and write
        self.addUpdateInterval(self.updateInterval)

        # number of samples for reconstruction
        self.assimilationSamples = pram.ta * self.readSampleRate

        # gauges to select for reconstruction
        self.mg = gauges.measurementIndex()

        # gauges for prediction
        self.pg = gauges.predictionIndex()

######### FOR TESTING (POST PROCESSING)
        self.bufferValues = my_data

    def addUpdateInterval(self, updateInterval = 1):
        '''
            This allows the user to change the duration of the updateInterval,
            which in practice should also be the same length as the prediction zone
        '''
        self.updateInterval = updateInterval

        # also update NSamples
        self.readNSamples = self.readSampleRate * self.updateInterval
        self.writeNSamples = self.writeSampleRate * self.updateInterval

        # empty arrays
        self.readValues = np.zeros((self.nChannels, self.readNSamples), dtype=np.float64)
        self.writeValues = np.zeros((1, self.writeNSamples), dtype=np.float64) 

        # time series        
        self.readTime = np.arange(0, self.updateInterval, self.readDT)
        self.writeTime = np.arange(0, self.updateInterval, self.writeDT)

    def bufferUpdate(self, newData):

        # shift old data to the end of the matrix
        self.bufferValues = np.roll(self.bufferValues, -self.readNSamples)
        
        # write over old data with new data
        self.bufferValues[:, -self.readNSamples] = newData

    def reconstructionData(self):
        # select measurement gauges across reconstruction time
        data = self.bufferValues[self.mg, -self.assimilationSamples:]
        return data

    def reconstructionTime(self):
        time = self.bufferTime[-self.assimilationSamples:]
        return time

    def spectralData(self):
        # select measurement gauges across reconstruction time
        return self.bufferValues

class WRP(wrpParams):
    def __init__(self, gauges):
        super().__init__()

        self.x = gauges.xPositions
        self.calibration = gauges.calibrationSlopes

        # gauges to select for reconstruction
        self.mg = gauges.measurementIndex()

        # gauges for prediction
        self.pg = gauges.predictionIndex()

        self.ng = gauges.nGauges()

    def spectral(self, flow):
        # assign spectral variables to wrp class
        data = flow.spectralData()

        f, pxxEach = welch(data, fs = flow.readSampleRate, nfft = 1024)
        pxx = np.mean(pxxEach, 0)
  
        # peak period
        self.pperiod = 1 / (f[pxx == np.max(pxx)])

        # peak wavelength
        self.k_p = (1 / 9.81) * (2 * np.pi / self.pperiod)**2

        # zero-th moment as area under power curve
        self.m0 = np.trapz(pxx, f)

        # significant wave height from zero moment
        self.Hs = 4 * np.sqrt(self.m0)

        self.w = f * np.pi * 2

        pxxMod = pxx
        # set anything above the threshold to zero
        pxxMod[pxxMod > self.mu * np.max(pxxMod)] = 0
        # find the locations which didn't make the cut
        pxxIndex = np.nonzero(pxxMod)
        # find the largest gap between nonzero values
        low_index = np.argwhere( (np.diff(pxxIndex) == np.max(np.diff(pxxIndex)))[0] )
        high_index = low_index + 1

        # select group velocities
        self.cg_fast = (9.81 / (self.w[low_index] * 2))[0][0]
        self.cg_slow = (9.81 / (self.w[high_index] * 2))[0][0]

        # spatial parameters for reconstruction bandwidth
        self.xe = np.max( np.array(self.x)[self.mg] ) + self.ta * self.cg_slow
        self.xb = np.min( np.array(self.x)[self.mg])

        # reconstruction bandwidth wavenumbers
        self.k_min = 2 * np.pi / (self.xe - self.xb)
        self.k_max = 2 * np.pi / min(abs(np.diff(self.x)))


    def inversion(self, flow):

    # define wavenumber and frequency range
        k = np.linspace(self.k_min, self.k_max, self.nf)
        w = np.sqrt(9.81 * k)

    # get data
        eta = flow.reconstructionData()
        eta = np.reshape(eta,(np.size(eta), 1))

        t = flow.reconstructionTime()
        x = np.array(self.x)[self.mg]

    # grid data
        X, T = np.meshgrid(x, t)

        k = np.reshape(k, (self.nf, 1))
        X = np.reshape(X, (1, np.size(X)))

        w = np.reshape(w, (self.nf, 1))
        T = np.reshape(T, (1, np.size(T)))        

        psi = np.transpose(k@X - w@T)

        Z = np.zeros((np.size(X), 2*self.nf))

        Z[:, :self.nf] = np.cos(psi)
        Z[:, self.nf:] = np.sin(psi)


        m = np.transpose(Z)@Z + np.identity(self.nf * 2) * self.lam
        n = np.transpose(Z)@eta
        weights, res, rnk, s = linalg.lstsq(m, n)

        self.a = weights[:self.nf,0]
        self.b = weights[self.nf:,0]


    def reconstruct(self):
        self.reconstructionLocation = 0
        # assume that location of interest is always zero
        pass


    def correct(self):
        # scale the data array before inversion or spectral analysis by calibrationConstants
        pass

    def filter(self):
        # do some lowpass filtering on noisy data
        pass
    def update_measurement_locations(self):
        # hold the locations x in the wrp class and update them if necessary
        pass
