from helper import now, strfdelta
from tkinter import *
from tkinter import messagebox, filedialog
from tkinter import ttk
import os, math
from fp_plot import plot_id, plot_pi, plot_scatter

ids = [ #"Fano_Factor_of_inBurst_sips_durations",
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
        "Number_of_activity_bouts",
        "Number_of_sips" ]

def main():
    Tk().withdraw()
    _files = filedialog.askopenfilenames(title='Choose file to load')
    if "Jan" in _files[0]:
        _lim = [[0, 12, 0, 12], [0, 1000, 0, 500]]
    if "Feb" in _files[0]:
        _lim = [[0, 20, 0, 20], [0, 6000, 0, 500]]
    for each_id in ids:
        if each_id == "Median_nSips_per_feeding_bursts":
            pass
            #plot_id(_file, each_id, _sort="S", lims= _lim[0])##[0, 1600, 0, 500]) #[0, 6000, 0, 200]
            #plot_id(_file, each_id, lims= _lim[0])##[0, 1600, 0, 500]) #[0, 6000, 0, 200]
        if each_id == "Number_of_sips":
            plot_scatter(_files, each_id)
            #plot_id(_file, each_id, _sort="S", lims= _lim[1])##[0, 1600, 0, 500]) #[0, 6000, 0, 200]
            #plot_id(_file, each_id, lims= _lim[1])##[0, 1600, 0, 500]) #[0, 6000, 0, 200]
        #else:
        #    plot_id(_file, _cond, each_id)




if __name__ == "__main__":
    startdt = now()
    main()
    print("Done. Runtime:", strfdelta(now() - startdt, "%H:%M:%S"))
