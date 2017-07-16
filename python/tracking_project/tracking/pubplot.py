import os
from datetime import datetime as date

import numpy as np
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
from matplotlib import cm
import seaborn as sns
sns.set_style("ticks")

PATH_PLOT = ""
DATET_FMT = "%Y-%m-%dT%H-%M-%S"
FILEFMT = ".svg"

def savefig(f, title="", as_fmt="", dpi=90):
    tst = date.now().strftime(DATET_FMT)
    if len(as_fmt) == 0:
        endf = FILEFMT
    else:
        endf = "."+as_fmt
    f[0].savefig(os.path.join(PATH_PLOT, title+"_"+tst+endf), dpi=dpi)

def get_path(outstr):
    print(outstr+"\t"+PATH_PLOT)

def trajectory2D(_data, plot_opt="BASIC", subsampl=1, title=""):
    f, ax = plt.subplots(1 ,figsize=(5, 5), dpi=90)
    f.suptitle(title, fontsize=16)
    x, y = np.array(_data[_data.columns[0]]), np.array(_data[_data.columns[1]])
    time = np.arange(0,len(x[::subsampl]))
    if plot_opt == "BASIC":
            ax.scatter(x[::subsampl], y[::subsampl], s=0.25)
    elif plot_opt == "TIME":
            ax.scatter(x[::subsampl], y[::subsampl], s=0.25, c=time, cmap=cm.viridis, alpha=0.5)
    ax.set_aspect('equal', 'datalim')
    return (f, ax)

def time_series(_data, dt=0.02, subsampl=1, title=""):
    f, ax = plt.subplots(1 ,figsize=(10, 2), dpi=90)
    f.suptitle(title, fontsize=16)
    series = np.array(_data)
    time = np.arange(0,len(series[::subsampl])*dt,dt)
    ax.plot(time, series)
    return (f, ax)

def swarm_box():
    pass

def histogram():
    pass

def show():
    plt.show()
