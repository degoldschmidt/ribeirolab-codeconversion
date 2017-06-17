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
from fp_swarmbox import screenplot

def get_conds_pd(_file, _date):
    DATA = pd.read_csv(_file, sep='\t', encoding='utf-8')
    DATA = DATA.query("Date == 170109")



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

def save_plot(_data, _conds):
        f, axes = plt.subplots(2, sharex=False, figsize=(10,5))
        ### required keys
        _id = _conds["id"]
        _date = _conds["date"]
        _sort = _conds["sort"]
        axes = screenplot(axes, _data, _id, _date, _sort=_sort)
        plt.tight_layout()

        savedirname = filedialog.askdirectory(title="Where do you wanna save the plots")
        fullfile = _date
        for key in _conds.keys():
            if key is not "date":
                fullfile += "_" + _conds[key]
        fullfile += ".png"
        print("Saving plot for", _conds, "as:", savedirname+fullfile)
        plt.savefig(savedirname+fullfile, dpi=300)
        plt.clf()
        plt.close()

def main():
    Tk().withdraw()
    askload = messagebox.askquestion("Load dataframe", "Wanna load some dataframe?", icon='warning')
    if askload == 'yes':
        _file = filedialog.askopenfilename(title='Choose file to load')
        ### Conditions
        _conds = {}
        _conds["id"] = "Number_of_sips"
        _conds["sort"] = "Y"
        _conds["date"] = "170109"

        DATA = pd.read_csv(_file, sep='\t', encoding='utf-8')
        save_plot(DATA, _conds)
        #DATA = DATA.query("Id == 'Number_of_sips'")
        #DATA = DATA.query("Date == 170109")
        #DATA = DATA.sort_values("MedianY")
        #few_labs = ["control", "0923", "1046", "1052", "1061", "1063", "1550", "1561", "1576", "2324", "2378"]
        #scale = len(few_labs)/66
        #if scale == 0:
        #    scale = 1

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
