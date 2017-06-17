import hdf5storage
import h5py
import numpy as np
import pandas as pd

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

def unrv_data(_in):
    return _in[0][0][0,]

def unrv_labels(_in):
    #return _in[0][0][0]
    return [ val[0,0] for val in _in[0][0][0] ]

def h5_to_panda(_file, _ids):
    thisdate, thiseff, thisinternal, thislength = get_conds(_file)
    Out = {"Date": [], "DataY": [], "DataS": [], "Effector": [], "Id": [], "Internal": [], "Label": [], "Length": [], "MedianY": [], "MedianS": [], "pValY": [], "pValS": [], "SignifY": [], "SignifS": [], "Temp": []}
    ### GO THROUGH ALL IDS
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
