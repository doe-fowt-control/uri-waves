import numpy as np

# Start with a series of wave heights at known locations (J) and times (M)
from wave_data import time_series, wave_data

# Trim data cause it's a lot
wave_data = wave_data[500:550, :, :]
time_series = time_series[500:550]

# Total spatiotemporal samples (J*M) = (L)
# Specify a low and high end wavenumber, wavenumber series (1...N), and corresponding frequency series (1...N)
k_lo = 1
k_hi = 10
N = 30
k_n = np.linspace(k_lo, k_hi, num = N)
g = 9.81
w_n = np.sqrt(k_n * g)

def calc_A_mn(N, k_n, w_n, time_series, wave_data):

    # Every wavenumber gets two coefficients a_n and b_n
    # Make 2N x 2N A_mn matrix
    A_mn = np.ones([2*N, 2*N])

    # Upper left
    for m in range(N):
        for n in range(N):
            count = 0
            for i, t in enumerate(time_series):
                for x in wave_data[i, :, 1]: # same row as time, all columns, 1 deep
                    count += np.cos(k_n[m] * x - w_n[m]*t) * np.cos(k_n[n] * x - w_n[n]*t)
            A_mn[m, n] = count

    # Lower left
    for m in np.arange(N+1, 2*N, 1):
        for n in range(N):
            count = 0
            for i, t in enumerate(time_series):
                for x in wave_data[i, :, 1]: # same row as time, all columns, 1 deep
                    # Offset index by N to account for shift
                    count += np.sin(k_n[m - N] * x - w_n[m - N]*t) * np.cos(k_n[n] * x - w_n[n]*t)
            A_mn[m, n] = count

    # Upper right
    for m in range(N):
        for n in np.arange(N+1, 2*N, 1):
            count = 0
            for i, t in enumerate(time_series):
                for x in wave_data[i, :, 1]: # same row as time, all columns, 1 deep
                    # Offset index by N to account for shift
                    count += np.cos(k_n[m] * x - w_n[m]*t) * np.sin(k_n[n - N] * x - w_n[n - N]*t)
            A_mn[m, n] = count

    # Lower right
    for m in np.arange(N+1, 2*N, 1):
        for n in np.arange(N+1, 2*N, 1):
            count = 0
            for i, t in enumerate(time_series):
                for x in wave_data[i, :, 1]: # same row as time, all columns, 1 deep
                    # Offset index by N to account for shift
                    count += np.sin(k_n[m - N] * x - w_n[m - N]*t) * np.sin(k_n[n - N] * x - w_n[n - N]*t)
            A_mn[m, n] = count

    return A_mn

def calc_B_n(N, k_n, w_n, time_series, wave_data):
    # Make 2N x 1 B_n vector
    B_n = np.ones([2*N])

    for m in range(N):
        count = 0
        for i0, t in enumerate(time_series):
            for eta, x in wave_data[i0, :, :]: # same row as time, all columns, both deep to get measurement and location
                count += eta * np.cos(k_n[m] * x - w_n[m]*t)
        B_n[m] = count

    for m in np.arange(N+1, 2*N, 1):
        count = 0
        for i0, t in enumerate(time_series):
            for eta, x in wave_data[i0, :, :]: # same row as time, all columns, both deep to get measurement and location
                count += eta * np.cos(k_n[m-N] * x - w_n[m-N]*t)
        B_n[m] = count

    # Recast as column
    B_n = B_n.reshape(B_n.shape[0], 1)
    return B_n

print(2*np.pi/ w_n)
A_mn = calc_A_mn(N, k_n, w_n, time_series, wave_data)
B_n = calc_B_n(N, k_n, w_n, time_series, wave_data)

# print(A_mn.shape)
# print(B_n.shape)

print(np.linalg.solve(A_mn, B_n))
print(np.where())
# Solve linear equation
# A_mn * X_n = B_n

