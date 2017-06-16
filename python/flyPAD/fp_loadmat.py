from helper import now, strfdelta
from tkinter import *
from tkinter import messagebox, filedialog
from tkinter import ttk
import os, math
import hdf5storage
import h5py
import numpy as np
import pandas as pd
from fp_swarmbox import screenplot
import matplotlib
matplotlib.use("TkAgg")
import matplotlib.pyplot as plt

def get_conds(_file):
    effector = ""
    internal = ""
    onlyfile = os.path.basename(_file)
    if "KIR" in _file:
        effector = "Kir"
    if "Trp" in _file:
        effector = "TrpA"
    if onlyfile[7:].startswith("01_"):
        internal = "FF"
    if onlyfile[7:].startswith("03_"):
        internal = "8dD"
    if "3600" in _file:
        _len = "3600"
    if "1800" in _file:
        _len = "1800"
    if "900" in _file:
        _len = "900"
    date = onlyfile[0:6]
    return date, effector, internal, _len

def print_attrs(name, obj):
    print(name)
    for key, val in obj.attrs.iteritems():
        print("{:s} {:s}".format(key, val))

def unrv_data(_in, multic=False):
    if multic:
        out = []
        for condsdata in _in[0]:
            out.append([])
            for substrd in condsdata[0,]:
                out[-1].append(np.array(substrd))
        return out
    else:
        return _in[0][0][0,]

def unrv_labels(_in, multic=False):
    #return _in[0][0][0]
    if multic:
        out = []
        for condlabels in _in[0]:
            for label in condlabels:
                out.append([labs[0,0] for labs in label])
        return out
    else:
        return [ val[0,0] for val in _in[0][0][0] ]

def h5_to_panda(_file, _ids, _multic=False):
    ### GO THROUGH ALL IDS
    thisdate, thiseff, thisinternal, thislength = get_conds(_file)
    Out = {"Date": [], "DataY": [], "DataS": [], "Effector": [], "Id": [], "Internal": [], "Label": [], "Length": [], "MedianY": [], "MedianS": [], "pValY": [], "pValS": [], "SignifY": [], "SignifS": [], "Temp": []}
    for thisid in _ids:
        dataid = "data2/" + thisid
        pid = "PVALS/" + thisid
        ### LOAD MAT FILE
        raw_hdf5 = hdf5storage.loadmat(_file, variable_names=[dataid, pid, "LABELS"])

        ### UNRAVEL DATA
        datapoints = unrv_data(raw_hdf5[dataid], multic=_multic)
        pvals = unrv_data(raw_hdf5[pid], multic=_multic)
        labels = unrv_labels(raw_hdf5["LABELS"], multic=_multic)

        """
        for id1, conds in enumerate(["22C", "30C"]):
            print("Temp.:", conds)
            print("Labels:", labels[id1], "({:d})".format(len(labels[id1])))
            for id2, subtrs in enumerate(["yeast", "sucrose"]):
                print("Substrate:", subtrs)
                print("Datapoints dims:", datapoints[id1][id2].shape)
                print("pVals dims:", pvals[id1][id2].shape)
        """

        ### WRITE ALL DATA INTO DICT FOR PANDAS DATAFRAME
        if _multic:
            temps = ["22ºC", "30ºC"]
        else:
            temps = ["30ºC"]
        for id1, temp in enumerate(temps):
            if _multic:
                thisdata = datapoints[id1]
                thisp = pvals[id1]
                thislabels = labels[id1]
            else:
                thisdata = datapoints
                thisp = pvals
                thislabels = labels

            for col in range(thisdata[0].shape[1]):      # different labels
                for row in range(thisdata[0].shape[0]):      # different datapoints; same label
                    if ~np.isnan(thisdata[0][row, col]) and ~np.isnan(thisdata[1][row, col]):
                        Out["Label"].append(thislabels[col])
                        Out["Date"].append(thisdate)
                        Out["DataY"].append(thisdata[0][row, col])
                        Out["DataS"].append(thisdata[1][row, col])
                        Out["Effector"].append(thiseff)
                        Out["Id"].append(thisid)
                        Out["Internal"].append(thisinternal)
                        Out["Length"].append(thislength)
                        Out["MedianY"].append(np.nanmedian(thisdata[0][:,col]))
                        Out["MedianS"].append(np.nanmedian(thisdata[1][:,col]))
                        Out["pValY"].append(thisp[0][col][0])
                        Out["pValS"].append(thisp[1][col][0])
                        Out["SignifY"].append("yes" if math.log10(1./thisp[0][col])>2 else "no")
                        Out["SignifS"].append("yes" if math.log10(1./thisp[1][col])>2 else "no")
                        Out["Temp"].append(temp)

    return pd.DataFrame(Out)

def main():
    Tk().withdraw()
    askload = messagebox.askquestion("Load dataframe", "Wanna load some dataframe?", icon='warning')
    if askload == 'yes':
        _file = filedialog.askopenfilename(title='Choose file to load')
        DATA = pd.read_csv(_file, sep='\t', encoding='utf-8')
        #DATA = DATA.query("Id == 'Number_of_sips'")
        #DATA = DATA.query("Date == 170109")
        #DATA = DATA.sort_values("MedianY")
        f, axes = plt.subplots(2, sharex=False, figsize=(10,5))
        axes = screenplot(axes, DATA, "Number_of_sips", "170109")
        plt.tight_layout()
        plt.show()
    else:
        _files = filedialog.askopenfilenames(title='Choose file/s to load')
        _ids = [ #"Fano_Factor_of_inBurst_sips_durations",
                "Median_IFI",
                #"Fano_Factor_of_IFI",
                #"Mode_IFI",
                "Median_duration_of_inBurst_sips_durations",
                #"Fano_Factor_of_sip_durations",
                "Median_duration_of_sip_durations",
                "Inverse_of_Median_duration_of_transition_IBI",
                "Median_duration_of_feeding_burst_insider_IBI_",
                "Inverse_of_Median_duration_of_feeding_burst_IBI",
                "Median_duration_of_feeding_burst_Latency",
                "total_duration_of_feeding_bursts",
                "Median_nSips_per_feeding_bursts",
                "Median_duration_of_feeding_bursts",
                "Number_of_feeding_bursts_",
                "Total_duration_of_activity_bouts",
                "Median_duration_of_activity_bouts",
                "Inverse_of_Median_duration_of_activity_bout_IBI",
                "Number_of_activity_bouts",
                "Number_of_sips" ]

        dfs = []
        for _file in _files:
            print(_file)
            if "Apr" in _file:
                mult = True
            else:
                mult = False
            df = h5_to_panda(_file, _ids, _multic=mult)
            dfs.append(df)
        outdf = pd.concat(dfs, ignore_index=True)
        print(outdf)
        asksave = messagebox.askquestion("Saving data", "Do you want to save dataframe into file?", icon='warning')
        if asksave == 'yes':
            save_file = filedialog.asksaveasfilename(defaultextension='.csv', title='Choose filename to save',
                                                            filetypes=[("Comma-separated values","*.csv"),
                                                              ("All files","*.*")])
            outdf.to_csv(save_file, sep='\t', encoding='utf-8')


if __name__ == "__main__":
    startdt = now()
    main()
    print("Done. Runtime:", strfdelta(now() - startdt, "%H:%M:%S"))
