import numpy as np

def fastrms(x, window = 5, dim = -1, ampl = 0):
    """
    FASTRMS Instantaneous root-mean-square (RMS) power via convolution. (Translated from MATLAB script by Scott McKinney, 2011)

    Input Parameters:
        x:      input signal (array-like)
        window: length of LENGTH(WINDOW)-point rectangular window
        dim:    operates along specified dimension (default: -1 [along dimension with most elements])
        ampl:   if non-zero, ampl applies a correction so that the output RMS reflects the equivalent amplitude of a sinusoidal input signal (default: 0)
    """
    # choose dimension with more elements
    indim = len(x.shape)                                                        # dimension of input array
    rows = x.shape[0]                                                           # number of rows in input array
    if indim > 1:
        cols = x.shape[1]                                                       # number of columns in input array
        if dim == -1 and cols >= rows:                                          # for matrix, if #rows > #cols
            dim = 1
        else:
            dim = 0

    #if indim > 1:
        #window = np.ones((window, x.shape[dim]))                                # if matrix
    #else:
    window = np.ones(window)                                                    # rectangular window
    power = x**2                                                                # signal power

    if indim < 2:                                                               # for vectors
        rms = np.convolve(power, window, 'same')                                # convolve signal power with window
    else:                                                                       # for matrices
        rms = np.zeros(x.shape)
        if dim==0:
            for col in range(cols):
                rms[:, col] = np.convolve(power[:, col], window, 'same')        # convolves along columns
        else:
            for row in range(rows):
                rms[row, :] = np.convolve(power[row, :], window, 'same');       # convolves along rows
    rms = np.sqrt(rms/np.sum(window))                                           # normalize root-mean-square
    if ampl:
        rms = np.sqrt(2)*rms                                                    # amplitude correction term
    return rms

"""
% Fs = 200; T = 5; N = T*Fs; t = linspace(0,T,N);
% noise = randn(N,1);
% [a,b] = butter(5, [9 12]/(Fs/2));
% x = filtfilt(a,b,noise);
% window = gausswin(0.25*Fs);
% rms = fastrms(x,window,[],1);
% plot(t,x,t,rms*[1 -1],'LineWidth',2);
% xlabel('Time (sec)'); ylabel('Signal')
% title('Instantaneous amplitude via RMS')


import matplotlib.pyplot as plt
time = np.arange(1000)
print(time.shape)
x = 0.5*np.sin(0.05*time)+0.3*np.sin(0.3*time)+0.1*np.sin(0.9*time)
y = fastrms(x)

plt.plot(time, x, 'r-', label="Raw data")
plt.plot(time, y, 'b-', label="RMS")
plt.legend()
plt.show()
"""
