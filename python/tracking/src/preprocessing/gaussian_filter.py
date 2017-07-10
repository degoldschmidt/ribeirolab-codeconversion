from scipy import signal
import matplotlib.pyplot as plt
import numpy as np
import time
from benchmark import benchmark, multibench


def gaussian_filtered(_X, _len=16, _sigma=1.6):
    norm = np.sqrt(2*np.pi)*_sigma ### Scipy's gaussian window is not normalized
    window = signal.gaussian(_len+1, std=_sigma)/norm
    return np.convolve(_X, window, "same")

def gaussian_test():
    #np.random.seed(42)
    N=500000
    noise = np.random.randn(N)
    series = np.sin(np.linspace(0,50,num=N))
    convolved = gaussian_filtered(series+noise, _len=16)

test = multibench(100, "")
test(gaussian_test)
del test
