import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("TkAgg")
import matplotlib.pyplot as plt

import hdf5storage
import scipy.stats as stat
import os, math
import seaborn as sns
sns.set_style("ticks")
sns.despine(left=True)

"""
Helper functions
"""

def get_cond(_file):
    _cond = ""
    if "Jan" in _file:
        _cond = "3d fresh food"
    if "Feb" in _file:
        _cond = "8d deprived (sucrose water)"
    return _cond

def get_filename(_file, ID, _sort=""):
    _effect = ""
    if "KIR" in _file:
        _effect = "Kir"
    if "TrpA" in _file:
        _effect = "TrpA"
    if "Jan" in _file:
        _c = "FF"
    if "Feb" in _file:
        _c = "8dD"
    if "3600" in _file:
        _len = "3600"
    if "1800" in _file:
        _len = "1800"
    if "900" in _file:
        _len = "900"
    file_prefix = _c + "_" + _effect + "_" + _len
    return file_prefix+_sort+"_"+ID+".png"

def h5_to_panda(_file, _id):
    if _id == "PI":
        thisid = "Number_of_sips"
    else:
        thisid = _id
    dataid = "data2/" + thisid
    pid = "PVALS/" + thisid
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
    if _id == "PI":
        PIout = {"Label": [], "Data": [], "Median": [], "Signif": []}
        contr = (yeast_data[:, 0] - sucrose_data[:, 0]) / (yeast_data[:, 0] + sucrose_data[:, 0])
        Pvals = {}
        for col in range(yeast_data.shape[1]):      # different labels
            PIcol = (yeast_data[:, col] - sucrose_data[:, col]) / (yeast_data[:, col] + sucrose_data[:, col])
            PImedian = np.nanmedian(PIcol)
            PIcol = PIcol[~np.isnan(PIcol)]
            s, PIpval = stat.ranksums(contr, PIcol)
            if np.isnan(PIpval):
                PIpval = 1
            Pvals[labels[col]] = PIpval
            for row in range(yeast_data.shape[0]):      # different datapoints same label
                if ~np.isnan(yeast_data[row, col]) and ~np.isnan(sucrose_data[row, col]):
                    PIout["Label"].append(labels[col])
                    PIout["Data"].append(PIcol[row])
                    PIout["Median"].append(PImedian)
                    PIout["Signif"].append("Yes" if math.log10(1./PIpval)>2 else "No")
        PIout = pd.DataFrame(PIout)
        return PIout, Pvals
    else:
        Yout = {"Label": [], "Data": [], "Median": [], "Signif": []}
        Sout = {"Label": [], "Data": [], "Median": [], "Signif": []}
        for row in range(yeast_data.shape[0]):      # different datapoints same label
            for col in range(yeast_data.shape[1]):      # different labels
                if ~np.isnan(yeast_data[row, col]):
                    Yout["Label"].append(labels[col])
                    Yout["Data"].append(yeast_data[row, col])
                    Yout["Median"].append(np.nanmedian(yeast_data[:,col]))
                    Yout["Signif"].append("Yes" if math.log10(1./yeast_ps[col])>2 else "No")
                if ~np.isnan(sucrose_data[row, col]):
                    Sout["Label"].append(labels[col])
                    Sout["Data"].append(sucrose_data[row, col])
                    Sout["Median"].append(np.nanmedian(sucrose_data[:,col]))
                    Sout["Signif"].append("Yes" if np.log10(1./sucrose_ps[col])>2 else "No")
        Ydf = pd.DataFrame(Yout)
        Sdf = pd.DataFrame(Sout)
        Pvals = {}
        for ind, label in enumerate(labels):
            Pvals[label] = [yeast_ps[ind], sucrose_ps[ind]]
        return [Ydf, Sdf], Pvals

def h5_to_median(_file, _id):
    thisid = _id
    dataid = "data2/" + thisid
    pid = "PVALS/" + thisid
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
    Yout = {"Label": [], "Data": []}
    Sout = {"Label": [], "Data": []}
    for col in range(yeast_data.shape[1]):      # different labels
        Yout["Label"].append(labels[col])
        Yout["Data"].append(np.nanmedian(yeast_data[:, col]))
        Sout["Label"].append(labels[col])
        Sout["Data"].append(np.nanmedian(sucrose_data[:, col]))
    Ydf = pd.DataFrame(Yout)
    Sdf = pd.DataFrame(Sout)
    Pvals = {}
    for ind, label in enumerate(labels):
        Pvals[label] = [yeast_ps[ind], sucrose_ps[ind]]
    return [Ydf, Sdf], Pvals


def swarmbox(_data, _x, _y, _pval, _ax, ps=2, hueon=False):
    if hueon:
        un_med = [ _data[_data["Label"]==label]["Median"].unique()[0] for label in _data["Label"].unique()]
        pal = sns.diverging_palette(240, 10, s=99, n=201)
        pal = [pal[int(100*(med+1))] for med in un_med]
        _ax = sns.boxplot(x=_x, y=_y, palette=pal, data=_data, width=0.4, linewidth=0.5, showcaps=False, showfliers=False,whiskerprops={'linewidth':0}, ax=_ax)
    else:
        _ax = sns.boxplot(x=_x, y=_y, data=_data, width=0.4, linewidth=0.5, showcaps=False,boxprops={'facecolor':'.85'}, showfliers=False,whiskerprops={'linewidth':0}, ax=_ax)
    _ax = sns.swarmplot(x=_x, y=_y, hue="Signif", data=_data, size=ps, ax=_ax, palette=dict(Yes = 'r', No = 'k'))
    _ax = sns.pointplot(x=_x, y=_y, data=_data, estimator=np.median, ci=None, join=False, color="0.5", markers="_", scale=0.75, ax=_ax)
    return _ax


def unrv_data(_in):
    return _in[0][0][0,]

def unrv_labels(_in):
    return _in[0][0][0]

"""
Plot scripts:
    * Y/S screening plot (plot_id)
    * PI screening plot (plot_pi)
    * scatter plots (plot_scatter)
"""

def plot_id(_file, _ID, _sort="Y", lims=[]):
    ID = _ID
    title = _ID.replace("_", " ")
    Substr = ["10% Yeast", "20 mM Sucrose"]
    Df, pvals = h5_to_panda(_file, ID)
    if _sort == "Y":
        Df[0] = Df[0].sort_values("Median")
        Df[1] = Df[1].reindex(Df[0].index)
    else:
        Df[1] = Df[1].sort_values("Median")
        Df[0] = Df[0].reindex(Df[1].index)
    Labels = [Df[0]["Label"].unique(), Df[1]["Label"].unique()]
    for j, substr_labels in enumerate(Labels):
        for i, labl in enumerate(substr_labels):
            if type(labl) is float:
                if np.isnan(labl):
                    print(j, labl, type(labl))
                    Labels[j] = np.delete(Labels[j], i)
    plotpvals = [[pvals[label][0] for label in Labels[0]], [pvals[label][1] for label in Labels[1]]]
    f, axes = plt.subplots(2, sharex=False, figsize=(10,5))
    for i,ax in enumerate(axes):
        ax = swarmbox(Df[i], "Label", "Data", np.log10(1./np.array(plotpvals[i])), ax)
        ax2 = ax.twinx()
        ax2.plot(np.log10(1./np.array(plotpvals[i])), 'k-', linewidth=0.5)
        ax.set_xticklabels(Labels[i], rotation=60, ha='right')
        ax.grid(which='major', axis='y', linestyle='--')
        ax.tick_params(axis='both', direction='out', labelsize=9, pad=1)
        ax.tick_params(axis='y', labelsize=10)
        [lab.set_color("red") for j, lab in enumerate(ax.get_xticklabels()) if np.log10(1./np.array(plotpvals[i][j])) > 2.]
        ax.set_xlabel("JRC SplitGal4 Label", fontsize=8, fontweight='bold')
        ax.set_ylabel(title)
        ax.set_title(Substr[i], fontsize=12, loc='left', fontweight='bold')
        ax.legend(loc='upper left', title=" p < 0.01", labelspacing=0.25, handletextpad=-0.2, borderpad=0.,fontsize=8)
    plt.suptitle(get_cond(_file), fontsize=12)
    if len(lims)>1:
        axes[0].set_ylim([lims[0], lims[1]])
    if len(lims)>3:
        axes[1].set_ylim([lims[2], lims[3]])
    plt.tight_layout()
    #folder = os.path.dirname(_file)+os.sep+"plots"+os.sep
    folder = "/Users/degoldschmidt/Google Drive/PhD Project/Data/2017_01/Final plots/" ## MacOS fullpath
    fullfile = get_filename(_file, ID, _sort)
    print("Saving plot for", title, "as:", folder+fullfile)
    plt.savefig(folder+fullfile, dpi=300)
    plt.clf()
    plt.close()

def plot_pi(_file, _sort="Y"):
    ID = "PI"
    title = ID.replace("_", " ")
    Df, pvals = h5_to_panda(_file, ID)

    if _sort == "Y":
        Df = Df.sort_values("Median")
    else:
        Df = Df.sort_values("Median", ascending=False)
    Labels = Df["Label"].unique()
    for j, substr_labels in enumerate(Labels):
        for i, labl in enumerate(substr_labels):
            if type(labl) is float:
                if np.isnan(labl):
                    print(j, labl, type(labl))
                    Labels[j] = np.delete(Labels[j], i)
    plotpvals = [pvals[label] for label in Labels]
    fig, ax = plt.subplots(figsize=(10,5))
    ax = swarmbox(Df, "Label", "Data", np.log10(1./np.array(plotpvals)), ax, ps=1.5, hueon=True)
    ax2 = ax.twinx()
    ax2.plot(np.log10(1./np.array(plotpvals)), 'k-', linewidth=0.5)
    ax.set_xticklabels(Labels, rotation=60, ha='right')
    ax.grid(which='major', axis='y', linestyle='--')
    ax.tick_params(axis='both', direction='out', labelsize=9, pad=1)
    ax.tick_params(axis='y', labelsize=10)
    [lab.set_color("red") for j, lab in enumerate(ax.get_xticklabels()) if np.log10(1./np.array(plotpvals[j])) > 2.]
    ax.set_xlabel("JRC SplitGal4 Label", fontsize=8, fontweight='bold')
    ax.set_ylabel(title)
    ax2.set_ylabel('log10(1/p)')
    ax.legend(loc='upper left', title=" p < 0.01", labelspacing=0.25, handletextpad=-0.2, borderpad=0.,fontsize=8)
    plt.title(get_cond(_file), fontsize=12)
    ax.set_ylim([-1, 1])
    plt.tight_layout()
    #folder = os.path.dirname(_file)+os.sep+"plots"+os.sep
    folder = "/Users/degoldschmidt/Google Drive/PhD Project/Data/2017_01/Final plots/" ## MacOS fullpath
    fullfile = get_filename(_file, ID, _sort)
    print("Saving plot for", title, "as:", folder+fullfile)
    plt.savefig(folder+fullfile, dpi=300)
    fig.clf()
    plt.close()

def plot_scatter(_files, _ID):
    ID = _ID
    title = _ID.replace("_", " ")
    Substr = ["10% Yeast", "20 mM Sucrose"]
    col = ["r", "g", "b"]
    f, ax = plt.subplots(figsize=(10,5))
    control = [Df[0][Df[0]["Label"]=="control", Df[0][Df[0]["Label"]=="control"]
    rest = [Df[0][Df[0]["Label"]!="control", Df[0][Df[0]["Label"]!="control"]
    for ind, _file in enumerate(_files):
        Df, pvals = h5_to_median(_file, ID)
        ax.scatter(Df[0]["Data"], Df[1]["Data"], alpha=.4, s=5, c=col[ind])
    ax.set_ylabel("#sips Sucrose")
    ax.set_xlabel("#sips Yeast")
    ax.set_xlim([0,6000])
    ax.set_ylim([0,3000])
    plt.tight_layout()
    #folder = os.path.dirname(_file)+os.sep+"plots"+os.sep
    folder = "/Users/degoldschmidt/Google Drive/PhD Project/Data/2017_01/Final plots/" ## MacOS fullpath
    fullfile = get_filename(_file, ID, _sort="scat")
    plt.savefig(folder+fullfile, dpi=300)
    ax.set_xlim([0,600])
    ax.set_ylim([0,300])
    plt.tight_layout()
    plt.savefig(folder+"ZOOM_"+fullfile, dpi=300)
    f.clf()
    plt.close()
