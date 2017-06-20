import math, os
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

def unrv_data(_in, opt=0):
    if opt==2:
        return _in[0,]
    if opt==1:
        out = []
        for condsdata in _in[0]:
            out.append([])
            for substrd in condsdata[0,]:
                out[-1].append(np.array(substrd))
        return out
    else:
        return _in[0][0][0,]

def unrv_labels(_in, opt=0):
    #return _in[0][0][0]
    if opt==2:
        return [ val[0,0] for val in _in[0,] ]
    if opt==1:
        out = []
        for condlabels in _in[0]:
            for label in condlabels:
                out.append([labs[0,0] for labs in label])
        return out
    else:
        return [ val[0,0] for val in _in[0][0][0] ]

def h5_to_panda(_file, _ids, _multic=False, _datopt=True):
    thisdate, thiseff, thisinternal, thislength = get_conds(_file)
    Out = {"Date": [], "DataY": [], "DataS": [], "Effector": [], "Id": [], "Internal": [], "Label": [], "Length": [], "MedianY": [], "MedianS": [], "pValY": [], "pValS": [], "SignifY": [], "SignifS": [], "Temp": []}
    ### GO THROUGH ALL IDS
    for thisid in _ids:
        ### skip it
        not_those = ["FractionNonEaters", "InsiderIBI", "SipRatio"]
        if thisid in not_those:
            continue
        ### LOAD MAT FILE
        if _datopt:
            dataid = "data2/" + thisid
            pid = "PVALS/" + thisid
            raw_hdf5 = hdf5storage.loadmat(_file, variable_names=[dataid, pid, "LABELS"])
        else:
            dataid = "data/" + thisid
            pid = "stats/" + thisid
            raw_hdf5 = hdf5storage.loadmat(_file, variable_names=[dataid])
            _statsfile = _file.replace("data", "stats")
            stats_hdf5 = hdf5storage.loadmat(_statsfile, variable_names=[pid])
            _labelfile = _file.replace("data", "label")
            labid = "Events/ConditionLabel"
            label_hdf5 = hdf5storage.loadmat(_labelfile, variable_names=[labid])


        ### UNRAVEL DATA
        if _datopt == True:
            opt = 1 if _multic else 0
            datapoints = unrv_data(raw_hdf5[dataid], opt=opt)
            pvals = unrv_data(raw_hdf5[pid], opt=opt)
            labels = unrv_labels(raw_hdf5["LABELS"], opt=opt)
        else:
            opt = 2
            datapoints = unrv_data(raw_hdf5[dataid], opt=opt)
            oldpvals = unrv_data(stats_hdf5[pid], opt=opt)
            labels = unrv_labels(label_hdf5[labid], opt=opt)
            N = len(labels[2:])
            maxN =  oldpvals[0].shape[0]
            pvals = [[],[]]
            pvals[0].append(1.0)
            pvals[0].append(1.0)
            pvals[1].append(1.0)
            pvals[1].append(1.0)
            for compi in range(maxN):
                ido = oldpvals[0][compi,0]
                if ido == 1:
                    ide = oldpvals[0][compi,1]
                    if ide%2==0:
                        pass
                    else:
                        pvals[0].append(oldpvals[0][compi,2])
                        pvals[1].append(oldpvals[1][compi,2])
                elif ido == 2:
                    ide = oldpvals[0][compi,1]
                    if ide%2==0:
                        pvals[0].append(oldpvals[0][compi,2])
                        pvals[1].append(oldpvals[1][compi,2])
                else:
                    break

        pvals = np.array(pvals)


        ### WRITE ALL DATA INTO DICT FOR PANDAS DATAFRAME
        if _datopt == False:
            _multic = _datopt
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
            """
            print(thisdata.shape)
            print(thisp.shape)
            print(thislabels.shape)
            """

            for col in range(thisdata[0].shape[1]):      # different labels
                for row in range(thisdata[0].shape[0]):      # different datapoints; same label
                    if ~np.isnan(thisdata[0][row, col]) and ~np.isnan(thisdata[1][row, col]):
                        if _datopt:
                            Out["Label"].append(thislabels[col])
                        else:
                            Out["Label"].append(thislabels[col][:-4])
                        Out["Date"].append(thisdate)
                        Out["DataY"].append(thisdata[0][row, col])
                        Out["DataS"].append(thisdata[1][row, col])
                        Out["Effector"].append(thiseff)
                        Out["Id"].append(thisid)
                        Out["Internal"].append(thisinternal)
                        Out["Length"].append(thislength)
                        Out["MedianY"].append(np.nanmedian(thisdata[0][:,col]))
                        Out["MedianS"].append(np.nanmedian(thisdata[1][:,col]))
                        if _datopt:
                            Out["pValY"].append(thisp[0][col][0])
                            Out["pValS"].append(thisp[1][col][0])
                        else:
                            Out["pValY"].append(thisp[0, col])
                            Out["pValS"].append(thisp[1, col])
                        if "emptySplitGal4" in thislabels[col]:
                            Out["SignifY"].append("control")
                            Out["SignifS"].append("control")
                        else:
                            Out["SignifY"].append("yes" if math.log10(1./thisp[0][col])>2 else "no")
                            Out["SignifS"].append("yes" if math.log10(1./thisp[1][col])>2 else "no")
                        if _datopt:
                            Out["Temp"].append(temp)
                        else:
                            Out["Temp"].append(thislabels[col][-3:-1] + "ºC")

    return pd.DataFrame(Out)
