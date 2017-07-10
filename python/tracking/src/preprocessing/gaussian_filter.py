from scipy import signal
import matplotlib.pyplot as plt
import numpy as np

window_size = 16
sigma = window_size/10
norm = np.sqrt(2*np.pi)*sigma ### Scipy's gaussian window is not normalized
window = signal.gaussian(window_size+1, std=sigma)/norm
plt.plot(window)
plt.ylabel("Value")
plt.xlabel("Index (Python starts at 0)")
plt.show()
