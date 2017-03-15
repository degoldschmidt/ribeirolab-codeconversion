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
        "Inverse_of_Median_duration_of_activity_bout_IBI",
        "Number_of_activity_bouts",
        "Number_of_sips" ]

TrpAFF = ["control", "0730", "0732", "1046", "1073", "1077", "1543", "1545", "1549", "1550", "1561", "1576", "1588", "2259", "2275", "2279", "2310", "2384", "2538"]
TrpA8dD = ["control", "0730", "1046", "1054", "1554", "1576", "2259", "2275", "2310", "2324", "2554"]
Kir8dD = ["control", "0923", "1046", "1052", "1061", "1063", "1550", "1561", "1576", "2324", "2378"]

def main():
    Tk().withdraw()
    _files = filedialog.askopenfilenames(title='Choose file to load')

    #plot_scatter(_files, "Number_of_sips")
    for each_id in ids:
        for _file in _files:
            if "Jan" in _file:
                _lim = [[0, 12, 0, 12], [0, 1000, 0, 500], [0,4,0,4], [0, 400, 0, 250]]
            if "Feb" in _file:
                _lim = [[0, 20, 0, 20], [0, 6000, 0, 500], [0,4,0,4], [0, 1500, 0, 100]]

            """
            if each_id == "Median_nSips_per_feeding_bursts":
                plot_id(_file, each_id, _sort="S", lims= _lim[0], _title="Median #sips per FB")##[0, 1600, 0, 500]) #[0, 6000, 0, 200]
                plot_id(_file, each_id, lims= _lim[0], _title="Median #sips per FB")##[0, 1600, 0, 500]) #[0, 6000, 0, 200]


            if each_id == "Number_of_sips":
                plot_pi(_file)
                plot_id(_file, each_id, _sort="S", lims= _lim[1])##[0, 1600, 0, 500]) #[0, 6000, 0, 200]
                plot_id(_file, each_id, lims= _lim[1])##[0, 1600, 0, 500]) #[0, 6000, 0, 200]
            """
            """ USE THIS FOR MICROSTRUCTURE FEEDING BURSTS
            """

            if each_id == "Inverse_of_Median_duration_of_feeding_burst_IBI":
                plot_id(_file, each_id, _sort="S", _title="Median Freq. FB IBI [1/s]", _only=Kir8dD, lims=[0, 2, 0, 2])##[0, 1600, 0, 500]) #[0, 6000, 0, 200]
                plot_id(_file, each_id, _title="Median Freq. FB IBI [1/s]", _only=Kir8dD, lims=[0, 2, 0, 2])##[0, 1600, 0, 500]) #[0, 6000, 0, 200]
                plot_id(_file, each_id, _sort="S", _title="Median Freq. FB IBI [1/s]", _only=Kir8dD, lims=[0, 0.05, 0, 0.05], _fsuff="zoom")## TODO: Y: 0.01 [0, 1600, 0, 500]) #[0, 6000, 0, 200]
                plot_id(_file, each_id, _title="Median Freq. FB IBI [1/s]", _only=Kir8dD, lims=[0, 0.05, 0, 0.05], _fsuff="zoom")##[0, 1600, 0, 500]) #[0, 6000, 0, 200]
            """
            if each_id == "Number_of_feeding_bursts_":
                plot_id(_file, each_id, _sort="S", _title="Number of feeding bursts", _only=Kir8dD, lims=[-0.1,250,-0.1,12])#, lims= [0,150,0,50])##[0, 1600, 0, 500]) #[0, 6000, 0, 200]
                plot_id(_file, each_id, _title="Number of feeding bursts", _only=Kir8dD, lims=[-0.1,250,-0.1,12])#, lims= [0,150,0,50])##[0, 1600, 0, 500]) #[0, 6000, 0, 200]
                plot_id(_file, each_id, _sort="S", _title="Number of feeding bursts", _only=Kir8dD, lims=[-1, 20, -1, 2], _fsuff="zoom")#, lims= [0,150,0,50])##[0, 1600, 0, 500]) #[0, 6000, 0, 200]
                plot_id(_file, each_id, _title="Number of feeding bursts", _only=Kir8dD, lims=[-1, 20, -1, 2], _fsuff="zoom")#, lims= [0,150,0,50])##[0, 1600, 0, 500]) #[0, 6000, 0, 200]
            """
            if each_id == "Median_nSips_per_feeding_bursts":
                plot_id(_file, each_id, _sort="S", _title="Median #sips per FB", _only=Kir8dD, lims= [0, 15, 0, 20])##[0, 1600, 0, 500]) #[0, 6000, 0, 200]
                plot_id(_file, each_id, _title="Median #sips per FB", _only=Kir8dD, lims= [0, 15, 0, 20])##[0, 1600, 0, 500]) #[0, 6000, 0, 200]

            """ USE THIS FOR MICROSTRUCTURE ACTIVITY BOUTS
            if each_id == "Median_duration_of_activity_bouts":
                plot_id(_file, each_id, _sort="S", _title="Median Dur. AB [s]", _only=Kir8dD, lims=[0, 15.,0, 9.5]) #4.1])#, lims= [0,8,0,8])##[0, 1600, 0, 500]) #[0, 6000, 0, 200]
                plot_id(_file, each_id, _title="Median Dur. AB [s]", _only=Kir8dD, lims=[0, 15.,0,4.1])#, lims= [0,8,0,8])##[0, 1600, 0, 500]) #[0, 6000, 0, 200]

            if each_id == "Inverse_of_Median_duration_of_activity_bout_IBI":
                plot_id(_file, each_id, _sort="S", _title="Median Freq. AB IBI [1/s]", _only=Kir8dD, lims=[0, 1, 0, 0.25])#, lims=[0,0.2,0,0.5])##[0, 1600, 0, 500]) #[0, 6000, 0, 200]
                plot_id(_file, each_id, _title="Median Freq. AB IBI [1/s]", _only=Kir8dD, lims=[0, 1, 0, 1])#, lims=[0,0.2,0,0.5])##[0, 1600, 0, 500]) #[0, 6000, 0, 200]
                plot_id(_file, each_id, _sort="S", _title="Median Freq. AB IBI [1/s]", _only=Kir8dD, lims=[0,0.05,0,0.01], _fsuff="zoom")#lims=[0, 0.05, 0, 0.05], _fsuff="zoom")##[0, 1600, 0, 500]) #[0, 6000, 0, 200]
                plot_id(_file, each_id, _title="Median Freq. AB IBI [1/s]", _only=Kir8dD, lims=[0,0.05,0,0.01], _fsuff="zoom")##[0, 1600, 0, 500]) #[0, 6000, 0, 200]

            if each_id == "Inverse_of_Median_duration_of_transition_IBI":
                plot_id(_file, each_id, _sort="S", _title="Median Freq. trans. FB IBI [1/s]", _only=Kir8dD, lims=[0, 0.2, 0, 0.3])#, lims= [0,0.1,0,0.1])##[0, 1600, 0, 500]) #[0, 6000, 0, 200]
                plot_id(_file, each_id, _title="Median Freq. trans. FB IBI [1/s]", _only=Kir8dD, lims=[0, 0.2, 0, 0.3])#, lims= [0,0.1,0,0.1])##[0, 1600, 0, 500]) #[0, 6000, 0, 200]
                plot_id(_file, each_id, _sort="S", _title="Median Freq. trans. FB IBI [1/s]", _only=Kir8dD, lims=[0, 0.01, 0, 0.05], _fsuff="zoom")#, lims= [0,0.1,0,0.1])##[0, 1600, 0, 500]) #[0, 6000, 0, 200]
                plot_id(_file, each_id, _title="Median Freq. trans. FB IBI [1/s]", _only=Kir8dD, lims=[0, 0.01, 0, 0.05], _fsuff="zoom")#, lims= [0,0.1,0,0.1])##[0, 1600, 0, 500]) #[0, 6000, 0, 200]
            """

            """
            if each_id == "Median_duration_of_feeding_bursts":
                plot_id(_file, each_id, _sort="S", _title="Median Dur. FB IBI [s]", lims=_lim[2])##[0, 1600, 0, 500]) #[0, 6000, 0, 200]
                plot_id(_file, each_id, _title="Median Dur. FB IBI", lims=_lim[2])##[0, 1600, 0, 500]) #[0, 6000, 0, 200]
            """
            """
            if each_id == "Total_duration_of_activity_bouts":
                plot_id(_file, each_id, _sort="S", _title="Total Dur. AB [s]", lims=_lim[3])##[0, 1600, 0, 500]) #[0, 6000, 0, 200]
                plot_id(_file, each_id, _title="Total Dur. AB [s]", lims=_lim[3])##[0, 1600, 0, 500]) #[0, 6000, 0, 200]
            """
            """
            if each_id == "Median_duration_of_activity_bouts":
                plot_id(_file, each_id, _sort="S", _title="Median Dur. AB [s]")##[0, 1600, 0, 500]) #[0, 6000, 0, 200]
                plot_id(_file, each_id, _title="Median Dur. AB [s]")##[0, 1600, 0, 500]) #[0, 6000, 0, 200]
            """
        #else:
        #    plot_id(_file, _cond, each_id)




if __name__ == "__main__":
    startdt = now()
    main()
    print("Done. Runtime:", strfdelta(now() - startdt, "%H:%M:%S"))
