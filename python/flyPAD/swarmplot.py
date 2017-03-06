import matplotlib.pyplot as plt
import seaborn as sns
from helper import now, strfdelta
from tkinter import *
from tkinter import messagebox, filedialog
from tkinter import ttk
import numpy as np
import h5py as h5
import hdf5storage
import pandas as pd
import os, math
sns.set_style("ticks")
sns.despine(left=True)
tips = sns.load_dataset("tips")

def h5_to_panda(_file, _id):
    dataid = "data2/" + _id.replace(" ","_")
    pid = "PVALS/" + _id.replace(" ","_")
    out = hdf5storage.loadmat(_file, variable_names=[dataid, pid, "LABELS"])

    datapoints = unrv_data(out[dataid])
    pvals = unrv_data(out[pid])

    labels = unrv_labels(out["LABELS"])
    labels = [label[0,0] for label in labels]
    labels[0] = "control"
    yeast_data = datapoints[0]
    sucrose_data = datapoints[1]
    yeast_ps = pvals[0]
    sucrose_ps = pvals[1]
    numdtpoints = yeast_data.size-np.count_nonzero(~np.isnan(yeast_data))
    Yout = {"Label": [], "Data": [], "Median": [], "Sign": []}
    Sout = {"Label": [], "Data": [], "Median": [], "Sign": []}
    for row in range(yeast_data.shape[0]):      # different datapoints same label
        for col in range(yeast_data.shape[1]):      # different labels
            if ~np.isnan(yeast_data[row, col]):
                Yout["Label"].append(labels[col])
                Yout["Data"].append(yeast_data[row, col])
                Yout["Median"].append(np.nanmedian(yeast_data[:,col]))
                Yout["Sign"].append("Yes" if math.log10(1./yeast_ps[col])>2 else "No")
            if ~np.isnan(sucrose_data[row, col]):
                Sout["Label"].append(labels[col])
                Sout["Data"].append(sucrose_data[row, col])
                Sout["Median"].append(np.nanmedian(sucrose_data[:,col]))
                Sout["Sign"].append("Yes" if np.log10(1./sucrose_ps[col])>2 else "No")
    Ydf = pd.DataFrame(Yout)
    Sdf = pd.DataFrame(Sout)

    Pvals = {}
    for ind, label in enumerate(labels):
        Pvals[label] = [yeast_ps[ind], sucrose_ps[ind]]
    return [Ydf, Sdf], Pvals


def swarmbox(_data, _x, _y, _pval, _ax):
    #_ax = sns.stripplot(x=_x, y=_y, data=_data, color=".25", size=1.5,  jitter=0.05, ax=_ax)
    _ax = sns.swarmplot(x=_x, y=_y, hue="Sign", data=_data, size=2, ax=_ax, palette=dict(Yes = 'r', No = 'k'))
    _ax = sns.pointplot(x=_x, y=_y, data=_data, estimator=np.median, ci=None, join=False, color="0.5", markers="_", scale=0.75, ax=_ax)
    #_ax = sns.violinplot(x=_x, y=_y, data=_data, inner=None, ax=_ax)
    #pal = {_x: "r" if _data[_pval][i] == "Yes" else "k" for i, label in enumerate(_data[_x])}
    _ax = sns.boxplot(x=_x, y=_y, data=_data, width=0.4, linewidth=0.5, showcaps=False,boxprops={'facecolor':'.85'}, showfliers=False,whiskerprops={'linewidth':0}, ax=_ax)
    return _ax

def unrv_data(_in):
    return _in[0][0][0,]

def unrv_labels(_in):
    return _in[0][0][0]

def main():
    ID = "Number of sips"
    Substr = ["10% Yeast", "20 mM Sucrose"]
    Tk().withdraw()
    _file = filedialog.askopenfilename(title='Choose file to load')
    Df, pvals = h5_to_panda(_file, ID)
    Df[0] = Df[0].sort_values("Median")
    #Sdf = Sdf.sort_values("Median")
    Df[1] = Df[1].reindex(Df[0].index)
    Labels = [Df[0]["Label"].unique(), Df[1]["Label"].unique()]
    plotpvals = [[pvals[label][0] for label in Labels[0]], [pvals[label][1] for label in Labels[1]]]
    f, axes = plt.subplots(2, sharex=False, figsize=(18,10))
    for i,ax in enumerate(axes):
        ax = swarmbox(Df[i], "Label", "Data", np.log10(1./np.array(plotpvals[i])), ax)
        ax2 = ax.twinx()
        ax2.plot(np.log10(1./np.array(plotpvals[i])), 'k-', linewidth=0.5)
        ax.set_xticklabels(Labels[i], rotation=60, ha='right')
        ax.grid(which='major', axis='y', linestyle='--')
        ax.tick_params(axis='both', direction='out', labelsize=9, pad=1)
        ax.tick_params(axis='y', labelsize=10)
        ax.set_ylabel(ID)
        ax.set_title(Substr[i], fontsize=10, loc='left')
    plt.suptitle("3d fresh food", fontsize=12, ha='right')
    axes[0].set_ylim([0, 1600])
    axes[1].set_ylim([0, 500])
    axes[0].set_xlabel("")
    plt.tight_layout()
    print("Saving plot for", ID, "as:", os.path.dirname(_file)+os.sep+ID.replace(" ","_")+".png")
    plt.savefig(os.path.dirname(_file)+os.sep+ID.replace(" ","_")+".png", dpi=600)


if __name__ == "__main__":
    startdt = now()
    main()
    print("Done. Runtime:", strfdelta(now() - startdt, "%H:%M:%S"))
