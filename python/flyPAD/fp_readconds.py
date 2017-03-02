import json as js
from tkinter import *
from tkinter import messagebox, filedialog
from tkinter import ttk
from PIL import Image, ImageTk
from helper import base, dirn, get_raw_data, get_data_len, get_datetime, get_endtime, icopath, millisecs, now, secs, strfdelta, write_data
import matplotlib
matplotlib.use("TkAgg")
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg, NavigationToolbar2TkAgg
from matplotlib import pyplot as plt
import numpy as np
from datetime import datetime as dt
import os
from pprint import pprint
import click

def dicti(_file):
    with open(_file) as json_file:
        return js.load(json_file)

def printd(_dict):
    for tskey in _dict.keys():
        print("------------------------------------------")
        print("File:", tskey)
        curfile = _dict[tskey]
        for condkey in curfile.keys():
            if type(curfile[condkey]) is dict:
                cond = curfile[condkey]
                print("|             ")
                print("+-- Condition:", condkey)
                for key in cond.keys():
                    if key == "range":
                        print("   |          ")
                        print("   +-- from", cond[key][0], "to", cond[key][1])
        print("------------------------------------------")
        print("")

def main():
    Tk().withdraw()
    deflist = []
    askload = messagebox.askquestion("Open file", "Do you want to load conditions from file?", icon='warning')
    if askload == 'yes':
        ofile = filedialog.askopenfilename(title='Choose defaults to load')
    indict = dicti(ofile)
    printd(indict)

if __name__ == "__main__":
    startdt = now()
    main()
    print("Done. Runtime:", strfdelta(now() - startdt, "%H:%M:%S"))
