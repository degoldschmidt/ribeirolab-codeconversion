from scipy import signal
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import time
from benchmark import benchmark, multibench


def gaussian_filtered(_X, _len=16, _sigma=1.6):
    norm = np.sqrt(2*np.pi)*_sigma ### Scipy's gaussian window is not normalized
    window = signal.gaussian(_len+1, std=_sigma)/norm
    return np.convolve(_X, window, "same")

testsamples = 1000000

def gaussian_test_pd():
    #np.random.seed(42)
    N=testsamples
    s = pd.Series(np.random.randn(N) + np.sin(np.linspace(0,50,num=N)))
    convolved = gaussian_filtered(s, _len=16)

def gaussian_test_np():
    #np.random.seed(42)
    N=testsamples
    noise = np.random.randn(N)
    series = np.sin(np.linspace(0,50,num=N))
    convolved = gaussian_filtered(series+noise, _len=16)



if __name__ == "__main__":
    test = multibench(100)   # start benchmark for 10 repetitions
    test(gaussian_test_np)  # perform benchmark for given function
    del test                # delete benchmark for stats printout (test.t)
    """
    test2 = multibench(20)   # start benchmark for 10 repetitions
    test2(gaussian_test_pd)  # perform benchmark for given function
    del test2                # delete benchmark for stats printout (test.t)
    """
