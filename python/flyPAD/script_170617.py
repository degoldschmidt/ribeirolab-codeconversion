from tkinter import *
from tkinter import messagebox, filedialog
from tkinter import ttk
from helper import now, strfdelta
import os, math
from fp_loadmat import h5_to_panda
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("TkAgg")
import matplotlib.pyplot as plt
from fp_swarmbox import screenplot, filtered, scatter
import h5py

"""
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
"""

def get_conds_pd(_file, _date):
    DATA = pd.read_csv(_file, sep='\t', encoding='utf-8')
    DATA = DATA.query("Date == 170109")

def get_mat_ids(_file):
    arrays = {}
    f = h5py.File(_file)
    for k, v in f.items():
        if "data" in k:
            ids = list(v.keys())
    return ids

def get_filename(_file, ID, _sort="", _suf=""):
    _effect = ""
    onlyfile = os.path.basename(_file)
    _c = ""
    print(onlyfile[7:])
    _date = onlyfile[:7]
    if "KIR" in _file:
        _effect = "Kir"
    if "TrpA" in _file:
        _effect = "TrpA"
    if onlyfile[7:].startswith("01_"):
        _c = "FF"
    if onlyfile[7:].startswith("03_"):
        _c = "8dD"
    if "3600" in _file:
        _len = "3600"
    if "1800" in _file:
        _len = "1800"
    if "900" in _file:
        _len = "900"
    file_prefix = _date + _c + "_" + _effect + "_" + _len
    return file_prefix+_sort+"_"+ID+"_"+_suf+".png"

def save_plot(_data, _conds, savedirname):
        ### required keys
        _id = _conds["id"]
        _date = _conds["date"]
        _sort = _conds["sort"]
        _onlybox = _conds["onlybox"]
        _temp = _conds["temp"]
        _grouped = _conds["grouped"]
        if "labels" in _conds.keys():
            _labels = _conds["labels"]
        else:
            _labels = []

        ### FILTER DATA by keys
        fdata = filtered(_data, _id, _date, _temp, _labels=_labels)

        ### PLOTTING
        if len(_labels) > 0:
            nl = len(_conds["labels"])
        else:
            nl = len(fdata["Label"].unique())
        fwid = 10 * math.sqrt( nl/65 )
        print("Labels:", nl, "-> FigW:", "{:.2f}".format(fwid), "in")
        f, axes = plt.subplots(2, sharex=False, figsize=(fwid,5))
        axes = screenplot(axes, fdata, _id, _date, _temp, _sort=_sort, _labels=_labels, _onlybox=_onlybox, _grouped=_grouped)

        ## handle legend
        for ax in axes:
            handles, labels = ax.get_legend_handles_labels()
            ax.legend_ = None
            l = ax.legend(handles[0:3], labels[0:3], fontsize=7, loc=2)

        plt.tight_layout()

        fullfile = _date
        for key in _conds.keys():
            if key is not "date":
                if key is not "onlybox":
                    if key is "labels":
                        fullfile += "_fewer"
                    else:
                        fullfile += "_" + _conds[key]
                else:
                    onb = "_box" if _conds[key] else "_data"
                    fullfile += onb
        fullfile += ".png"
        print("Saving plot for", _conds, "as:", savedirname+os.sep+fullfile)
        plt.savefig(savedirname+os.sep+fullfile, dpi=300)
        plt.clf()
        plt.close()

def save_scatter(_data, _conds, savedirname, _lim=8., _showdata=False):
    _id = _conds["id"]
    _date = _conds["date"]
    if "labels" in _conds.keys():
        _labels = _conds["labels"]
    else:
        _labels = []
    _temp = _conds["temp"]

    ### FILTER DATA by keys
    fdata = filtered(_data, _id, _date, _temp, _labels=_labels)

    f, ax = plt.subplots(1, figsize=(5,5))
    ax = scatter(ax, fdata, _id, _date, _temp, _labels, _lim=_lim, _showdata=_showdata)
    plt.tight_layout()

    fullfile = _date
    for key in _conds.keys():
        if key is not "date":
            if key is not "onlybox":
                if key is "labels":
                    fullfile += "_fewer"
                else:
                    fullfile += "_" + _conds[key]
    extra = "_dat" if _showdata else ""
    fullfile += "_"+str(_lim)+ extra +"_scatter.png"
    print("Saving plot for", _conds, "as:", savedirname+os.sep+fullfile)
    plt.savefig(savedirname+os.sep+fullfile, dpi=300)
    plt.clf()
    plt.close()

def load_data():
    askload = messagebox.askquestion("Load dataframe", "Wanna load some dataframe?", icon='warning')
    if askload == 'yes':
        _file = '/Users/degoldschmidt/Google Drive/PhD Project/Data/DN-AllFlyPADcombined/alldata.csv'##filedialog.askopenfilename(title='Choose file to load')
        return pd.read_csv(_file, sep='\t', encoding='utf-8')
    else:
        return 0

def extract_data():
    _files = filedialog.askopenfilenames(title='Choose file/s to load')

    dfs = []
    for _file in _files:
        print(_file)
        _date = os.path.basename(_file)[0:6]
        print(_date)
        if "04" in _date[2:4]:
            mult = True
        else:
            mult = False
        _ids = get_mat_ids(_file)
        if _file == _files[0]:
            print(_ids)
        _opt = "new" not in _file
        print("DATAOPT:", _opt)
        df = h5_to_panda(_file, _ids, _multic=mult, _datopt=_opt)
        dfs.append(df)
    if len(dfs) > 1:
        outdf = pd.concat(dfs, ignore_index=True)
    else:
        outdf = dfs[-1]
    print(outdf)
    asksave = messagebox.askquestion("Saving data", "Do you want to save dataframe into file?", icon='warning')
    if asksave == 'yes':
        save_file = filedialog.asksaveasfilename(defaultextension='.csv', title='Choose filename to save',
                                                        filetypes=[("Comma-separated values","*.csv"),
                                                          ("All files","*.*")])
        outdf.to_csv(save_file, sep='\t', encoding='utf-8', index=False)
    return outdf


def main():
    Tk().withdraw()
    outdf = load_data()
    if type(outdf) is int:
        outdf = extract_data()
    ### Conditions
    savedirname = '/Users/degoldschmidt/Google Drive/PhD Project/Data/DN-AllFlyPADcombined/plots/' #filedialog.askdirectory(title="Where do you wanna save the plots")
    for dates in ["170210"]: # ["170109", "170210", "170403", "170408"]
        _conds = {}
        _conds["id"] = "Number_of_sips"
        _conds["date"] = dates
        _conds["onlybox"] = True
        if dates == "170210":
            _conds["temp"] = "30ºC"
            _conds["grouped"] = ""
            sigs = ["emptySplitGal4", "0730", "1576", "1554", "1557", "2259", "1581", "1054", "1052", "2388", "2538", "2618", "2310", "2324", "2275", "1077"]
            _conds["labels"] = sigs
            save_scatter(outdf, _conds, savedirname, _lim=8., _showdata=True)
            save_scatter(outdf, _conds, savedirname, _lim=8., _showdata=False)
            save_scatter(outdf, _conds, savedirname, _lim=3., _showdata=False)
        if dates == "170109":
            _conds["temp"] = "30ºC"
            _conds["grouped"] = ""
            sigs = ["emptySplitGal4", "0730", "0732", "1046", "1073", "1077", "1549", "1550", "1561", "1576", "1588", "2275", "2279", "2384", "2538", "2547"]
            _conds["labels"] = sigs
            save_scatter(outdf, _conds, savedirname, _lim=8., _showdata=True)
            save_scatter(outdf, _conds, savedirname, _lim=8., _showdata=False)
            save_scatter(outdf, _conds, savedirname, _lim=3., _showdata=False)
        for sorts in ["Y", "S"]:
            if dates == "170210":
                _conds["sort"] = sorts
                save_plot(outdf, _conds, savedirname)
                _conds.pop("labels", None)
                save_plot(outdf, _conds, savedirname)
                _conds["onlybox"] = False
                save_plot(outdf, _conds, savedirname)
                _conds["onlybox"] = True
                sigs = ["emptySplitGal4", "0730", "1576", "1554", "1557", "2259", "1581", "1054", "1052", "2388", "2538", "2618", "2310", "2324", "2275"]
                _conds["labels"] = sigs
            if dates == "170109":
                _conds["sort"] = sorts
                save_plot(outdf, _conds, savedirname)
                _conds.pop("labels", None)
                save_plot(outdf, _conds, savedirname)
                _conds["onlybox"] = False
                save_plot(outdf, _conds, savedirname)
                _conds["onlybox"] = True
                sigs = ["emptySplitGal4", "0730", "0732", "1046", "1073", "1077", "1549", "1550", "1561", "1576", "1588", "2275", "2279", "2384", "2538", "2547"]
                _conds["labels"] = sigs
            if dates == "170403":
                _conds["temp"] = ""
                _conds["grouped"] = "Temp"
                _conds["sort"] = sorts
                save_plot(outdf, _conds, savedirname)



if __name__ == "__main__":
    startdt = now()
    main()
    print("Done. Runtime:", strfdelta(now() - startdt, "%H:%M:%S"))
