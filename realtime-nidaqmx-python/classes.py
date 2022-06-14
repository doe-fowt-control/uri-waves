import numpy as np
from scipy.signal import welch
from scipy import linalg
import matplotlib.pyplot as plt
from numpy import genfromtxt
import time


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
        '''
        find number of active wave gauges
        '''
        return(len(self.xPositions))

    def measurementIndex(self):
        '''
        return the indices of the measurement gauges
        '''
        mg = [i for i, e in enumerate(self.wrpRole) if e == 0]
        return mg

    def predictionIndex(self):
        '''
        return the index of the prediction/validation gauge
        '''
        pg = [i for i, e in enumerate(self.wrpRole) if e != 0]
        return pg


class wrpParams:
    def __init__(self):
        # wrp parameters
        self.ta = 10            # reconstruction assimilation time
        self.ts = 30            # spectral assimilation time
        self.nf = 100           # number of frequencies to use for reconstruction
        self.mu = 0.05          # threshold parameter to determine fastest/slowest group velocities for prediction zone
        self.lam = 1            # regularization parameter for least squares fit


class DataManager:
    def __init__(self, pram, gauges):
        
        self.readSampleRate = 30    # frequency to take wave measurements (Hz)
        self.writeSampleRate = 100  # frequency to send motor commands (Hz)

        self.preWindow = 0          # number of seconds before assimilation to reconstruct for
        self.postWindow = 5        # number of seconds after assimilation to reconstruct for

        # should eventually be based on the actual (calculated) prediction zone
        self.updateInterval = 1     # time between grabs at new data (s)
        
        # number of channels from which to read
        self.nChannels = gauges.nGauges()

        # time interval between wave measurements (s)
        self.readDT = 1 / self.readSampleRate
        self.writeDT = 1 / self.writeSampleRate

        # initialize read and write based on desired interval between samples
        self.addUpdateInterval(self.updateInterval)

        # set up buffer - samples, values, time -
        self.bufferNSamples = self.readSampleRate * pram.ts
        self.bufferValues = np.zeros((self.nChannels, self.bufferNSamples), dtype=np.float64) 
        self.bufferTime = np.arange(-pram.ts, 0, self.readDT)

        # set up validation - samples, values, time -
        self.validateNSamples = self.readSampleRate * (pram.ta + self.preWindow + self.postWindow)
        self.validateNFutureSamples = self.readSampleRate * self.postWindow
        self.validateNPastSamples = self.readSampleRate * (pram.ta + self.preWindow)
        self.validateValues = np.zeros((self.nChannels, self.validateNSamples), dtype=np.float64)
        self.validateTime = np.arange(-pram.ta - self.preWindow, self.postWindow, self.readDT)

        # array to save results of inversions for the length of time to visualize in the future
        self.inversionNSaved = int(self.postWindow / self.updateInterval) + 1
        self.inversionSavedValues = np.zeros((2, self.inversionNSaved, pram.nf))

        # number of samples for reconstruction
        self.assimilationSamples = pram.ta * self.readSampleRate

        # gauges to select for reconstruction
        self.mg = gauges.measurementIndex()

        # gauges for prediction
        self.pg = gauges.predictionIndex()

        # alter calibration constants for easy multiplying
        self.calibrationSlopes = np.expand_dims(gauges.calibrationSlopes, axis = 1)

 
    def addUpdateInterval(self, updateInterval = 1):
        '''
            Initialize read and write - samples, values, time - based on update interval
            
            Also allows the user to change the duration of the updateInterval,
            which in practice should also be the same length as the prediction zone
        '''
        self.updateInterval = updateInterval

        # set up read - samples, values, time -
        self.readNSamples = self.readSampleRate * self.updateInterval
        self.readValues = np.zeros((self.nChannels, self.readNSamples), dtype=np.float64)
        self.readTime = np.arange(0, self.updateInterval, self.readDT)

        # set up write - samples, values, time -
        self.writeNSamples = self.writeSampleRate * self.updateInterval
        self.writeValues = np.zeros((1, self.writeNSamples), dtype=np.float64) 
        self.writeTime = np.arange(0, self.updateInterval, self.writeDT)        

    def bufferUpdate(self, newData):
        # shift old data to the end of the matrix
        self.bufferValues = np.roll(self.bufferValues, -self.readNSamples)
        # write over old data with new data
        self.bufferValues[:, -self.readNSamples:] = newData

    def validateUpdate(self, newData):
        # shift old data to the end of the matrix
        self.validateValues = np.roll(self.validateValues, -self.readNSamples)
        
        # write over old data with new data
        self.validateValues[:, -self.readNSamples:] = newData

    def inversionUpdate(self, a, b):
        # array to save backlog of inversion results, good for validating real time
        self.inversionSavedValues = np.roll(self.inversionSavedValues, -1, axis = 1)

        # need to squeeze to fit it into the matrix
        self.inversionSavedValues[0][self.inversionNSaved - 1] = np.squeeze(a)
        self.inversionSavedValues[1][self.inversionNSaved - 1] = np.squeeze(b)


    def inversionGetValues(self, method):
        # need expand_dims for the matrix math in reconstruct

        if method == 'oldest':
            a = np.expand_dims(self.inversionSavedValues[0][0][:], axis=1)
            b = np.expand_dims(self.inversionSavedValues[1][0][:], axis=1)

            return a,b

        if method == 'newest':
            a = np.expand_dims(self.inversionSavedValues[0][-1][:], axis=1)
            b = np.expand_dims(self.inversionSavedValues[1][-1][:], axis=1)

            return a,b

    def reconstructionData(self):
        # select measurement gauges across reconstruction time
        data = self.bufferValues[self.mg, -self.assimilationSamples:]

        processedData = self.preprocess(data, self.mg)
        return processedData

    def reconstructionTime(self):
        time = self.bufferTime[-self.assimilationSamples:]
        return time

    def spectralData(self):
        data = self.bufferValues[self.mg, :]

        processedData = self.preprocess(data, self.mg)
        return processedData

    def validateData(self):
        data = self.validateValues[self.pg, :]

        processedData = self.preprocess(data, self.pg)
        return processedData

    def preprocess(self, data, whichGauges):
        # scale by calibration constants
        data *= self.calibrationSlopes[whichGauges]

        # center on mean
        dataMeans = np.expand_dims(np.mean(data, axis = 1), axis = 1)
        data -= dataMeans

        return data



class DataLoader:
    def __init__(self, dataFile, timeFile):
        # location of data
        self.dataFileName = dataFile
        # load full array
        self.dataFull = genfromtxt(self.dataFileName, delimiter=',')

        # location of data
        self.timeFileName = timeFile
        # load full array
        self.timeFull = genfromtxt(self.timeFileName, delimiter=',')

        # location in full array for dynamic method
        self.currentIndex = 0

        # location in full array for dynamic soft method
        self.bufferCurrentIndex = 0
        self.validateCurrentIndex = 0

    def generateBuffersStatic(self, flow, reconstructionTime):
        # load reconstruction and validation data one time

        # index of the specified reconstruction time
        self.reconstructionIndex = np.argmin( np.abs(reconstructionTime - self.timeFull))
        bufferLowIndex = self.reconstructionIndex - flow.bufferNSamples
        bufferHighIndex = self.reconstructionIndex

        validateLowIndex = self.reconstructionIndex - flow.validateNPastSamples
        validateHighIndex = self.reconstructionIndex + flow.validateNFutureSamples

        flow.bufferValues = self.dataFull[:, bufferLowIndex:bufferHighIndex]
        flow.validateValues = self.dataFull[:, validateLowIndex:validateHighIndex]

    def generateBuffersDynamic(self, flow, wrp, reconstructionTime, callFunc):
        # index of the specified reconstruction time
        self.reconstructionIndex = np.argmin( np.abs(reconstructionTime - self.timeFull))

        while self.currentIndex <= self.reconstructionIndex:
            if self.currentIndex == 0:

                filler = np.reshape(np.cos(flow.bufferTime + np.random.normal()), (1, flow.bufferNSamples))
                fillAll = np.tile(filler, (4, 1))
                flow.bufferValues = fillAll

                newData = self.dataFull[:, :flow.readNSamples]

            else:              
                newData = self.dataFull[:, self.currentIndex:self.currentIndex + flow.readNSamples]
            
            flow.bufferUpdate(newData)
            flow.validateUpdate(newData)

            # decide what to do on update in main script
            callFunc(wrp, flow)

            self.currentIndex += flow.readNSamples

    def generateBuffersDynamicSoft(self, flow, reconstructionTime):
        # called 'soft' because it still allocates data to the right place in each buffer, 
        # unlike true acquisition which needs to do reconstruction as soon as data is available

        # index of the specified reconstruction time
        self.reconstructionIndex = np.argmin( np.abs(reconstructionTime - self.timeFull))

        # add samples from self.dataFull to flow.validateValues until the number of samples added
        # matches flow.validateNFutureSamples
        flow.validateValues[:, -flow.validateNFutureSamples:] = self.dataFull[:, :flow.validateNFutureSamples]
        self.validateCurrentIndex = flow.validateNFutureSamples

        while self.bufferCurrentIndex < self.reconstructionIndex:
            if self.bufferCurrentIndex == 0:
                bufferNewData = self.dataFull[:, :flow.readNSamples]
                flow.bufferUpdate(bufferNewData)

            # update bufferValues and validateValues
            bufferNewData = self.dataFull[:, self.bufferCurrentIndex: self.bufferCurrentIndex+flow.readNSamples]
            flow.bufferUpdate(bufferNewData)

            validateNewData = self.dataFull[:, self.validateCurrentIndex: self.validateCurrentIndex+flow.readNSamples]
            flow.validateUpdate(validateNewData)

            self.bufferCurrentIndex += flow.readNSamples
            self.validateCurrentIndex += flow.readNSamples

        print(flow.bufferValues)

class WRP(wrpParams):
    def __init__(self, gauges):
        super().__init__()

        self.x = gauges.xPositions
        self.calibration = gauges.calibrationSlopes

        # gauges to select for reconstruction
        self.mg = gauges.measurementIndex()

        # gauges for prediction
        self.pg = gauges.predictionIndex()

        # important spatial parameters for wrp based on gauge locations
        self.xmax = np.max( np.array(self.x)[self.mg] )
        self.xmin = np.min( np.array(self.x)[self.mg] )
        self.xpred = np.array(self.x)[self.pg]



    def spectral(self, flow):
        # assign spectral variables to wrp class
        data = flow.spectralData()

        f, pxxEach = welch(data, fs = flow.readSampleRate)
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

        thresh = self.mu * np.max(pxx)

        # set anything above the threshold to zero
        pxx[pxx > thresh] = 0
        # plt.plot(f, pxx)
        # find the locations which didn't make the cut
        pxxIndex = np.nonzero(pxx)[0]

        # find the largest gap between nonzero values
        low_index = np.argwhere( (np.diff(pxxIndex) == np.max(np.diff(pxxIndex))) )[0][0]
        high_index = pxxIndex[low_index + 1]

        # plt.axvline(x = f[low_index])
        # plt.axvline(x = f[high_index])
        # plt.show()

        # select group velocities
        if self.w[low_index] == 0:
            self.cg_fast = 20 # super arbitrary
        else:
            self.cg_fast = (9.81 / (self.w[low_index] * 2))
        self.cg_slow = (9.81 / (self.w[high_index] * 2))

        # spatial parameters for reconstruction bandwidth
        self.xe = self.xmax + self.ta * self.cg_slow
        self.xb = self.xmin

        # reconstruction bandwidth wavenumbers
        self.k_min = 2 * np.pi / (self.xe - self.xb)
        self.k_max = 2 * np.pi / min(abs(np.diff(self.x)))

    def inversion(self, flow):

    # define wavenumber and frequency range
        k = np.linspace(self.k_min, self.k_max, self.nf)
        w = np.sqrt(9.81 * k)

    # get data
        eta = flow.reconstructionData()
        t = flow.reconstructionTime()
        x = np.array(self.x)[self.mg]

    # grid data and reshape for matrix operations
        X, T = np.meshgrid(x, t)

        self.k = np.reshape(k, (self.nf, 1))
        self.w = np.reshape(w, (self.nf, 1))

        X = np.reshape(X, (1, np.size(X)), order='F')

        T = np.reshape(T, (1, np.size(T)), order='F')        
        eta = np.reshape(eta, (np.size(eta), 1))

        psi = np.transpose(self.k@X - self.w@T)

        
    # data matrix
        Z = np.zeros((np.size(X), 2*self.nf))
        Z[:, :self.nf] = np.cos(psi)
        Z[:, self.nf:] = np.sin(psi)


        m = np.transpose(Z)@Z + (np.identity(self.nf * 2) * self.lam)
        n = np.transpose(Z)@eta
        weights, res, rnk, s = linalg.lstsq(m, n)

        # choose all columns [:] for future matrix math
        a = weights[:self.nf,:]
        b = weights[self.nf:,:]

        flow.inversionUpdate(a, b)


    def reconstruct(self, flow, method = 'validate'):

        # prediction zone time boundary
        self.t_min = (1 / self.cg_slow) * (self.xpred - self.xe)
        self.t_max = (1 / self.cg_fast) * (self.xpred - self.xb)

        # time for matrix math
        t = np.expand_dims(flow.validateTime, axis = 0)

        # dx array for surface representation at desired location
        dx = self.xpred * np.ones((1, len(t)))

        # matrix for summing across frequencies
        sumMatrix = np.ones((1, self.nf))

        if method == 'validate':
            a, b = flow.inversionGetValues('oldest')
        if method == 'now':
            a, b = flow.inversionGetValues('newest')

        # reconstruct
        acos = a * np.cos( (self.k @ dx) - self.w @ t )
        bsin = b * np.sin( (self.k @ dx) - self.w @ t )
        
        self.reconstructedSurface = sumMatrix @ (acos + bsin)

    def setVis(self, flow):
        plt.ion()

        figure, ax = plt.subplots(figsize = (4,3))
        plt.ylim([-.2, .2])
        ax.axvline(0, color = 'gray', linestyle = '-', label = 'reconstruction time')
        ax.legend()
        reconstructedLine, = ax.plot(flow.validateTime, np.zeros(flow.validateNSamples), color = 'blue', label = 'reconstructed')
        measuredLine, = ax.plot(flow.validateTime, np.zeros(flow.validateNSamples), color = 'red', label = 'measured')
        tMin = ax.axvline(-1, color = 'black', linestyle = '--', label = 'reconstrucion boundary')
        tMax = ax.axvline(1, color = 'black', linestyle = '--')

        V = figure, ax, reconstructedLine, measuredLine, tMin, tMax

        return V

    def updateVis(self, flow, V):

        figure, ax, reconstructedLine, measuredLine, tMin, tMax = V

        reconstructedLine.set_ydata(np.squeeze(self.reconstructedSurface))
        measuredLine.set_ydata(np.squeeze(flow.validateData()))
        tMin.set_xdata(self.t_min)
        tMax.set_xdata(self.t_max)

        figure.canvas.draw()
        figure.canvas.flush_events()
        time.sleep(.1)




    def filter(self):
        # do some lowpass filtering on noisy data
        pass
    def update_measurement_locations(self):
        # hold the locations x in the wrp class and update them if necessary
        pass
