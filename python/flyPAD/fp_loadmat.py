from helper import now, strfdelta
from tkinter import *
from tkinter import messagebox, filedialog
from tkinter import ttk
import os, math
import hdf5storage
import h5py
import numpy as np
import pandas as pd
import pprint

def print_attrs(name, obj):
    print(name)
    for key, val in obj.attrs.iteritems():
        print("{:s} {:s}".format(key, val))

def unrv_data(_in):
    return _in[0][0][0,]

def unrv_labels(_in):
    #return _in[0][0][0]
    return [ val[0,0] for val in _in[0][0][0] ]

def h5_to_panda(_file, _ids):
    ### GO THROUGH ALL IDS
    Out = {"Data": [], "Id": [], "Label": [], "Median": [], "pVal": [], "Signif": [], "Substr": []}
    for thisid in _ids:
        print(thisid)
        dataid = "data2/" + thisid
        pid = "PVALS/" + thisid
        ### LOAD MAT FILE
        raw_hdf5 = hdf5storage.loadmat(_file, variable_names=[dataid, pid, "LABELS"])

        ### UNRAVEL DATA
        datapoints = unrv_data(raw_hdf5[dataid])
        pvals = unrv_data(raw_hdf5[pid])
        labels = unrv_labels(raw_hdf5["LABELS"])

        ### WRITE ALL DATA INTO DICT FOR PANDAS DATAFRAME
        for idx, substr in enumerate(["yeast", "sucrose"]):
            thisdata = datapoints[idx]
            thisp = pvals[idx]
            for row in range(thisdata.shape[0]):      # different datapoints same label
                for col in range(thisdata.shape[1]):      # different labels
                    if ~np.isnan(thisdata[row, col]):
                        Out["Label"].append(labels[col])
                        Out["Data"].append(thisdata[row, col])
                        Out["Id"].append(thisid)
                        Out["Median"].append(np.nanmedian(thisdata[:,col]))
                        Out["pVal"].append(thisp[col][0])
                        Out["Signif"].append("yes" if math.log10(1./thisp[col])>2 else "no")
                        Out["Substr"].append(substr)

    return pd.DataFrame(Out)

def main():
    Tk().withdraw()
    _files = filedialog.askopenfilenames(title='Choose file to load')
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

    for _file in _files:
        df = h5_to_panda(_file, _ids)
        print(df)

if __name__ == "__main__":
    startdt = now()
    main()
    print("Done. Runtime:", strfdelta(now() - startdt, "%H:%M:%S"))
