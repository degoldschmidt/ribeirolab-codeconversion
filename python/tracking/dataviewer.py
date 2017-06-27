import csv
import numpy as np
import pandas as pd
from tkinter import *
from tkinter import messagebox, filedialog
from tkinter import ttk
import datetime as dt

def read_csv(_file, delimiter=';'):
    with open(_file,'r') as dest_f:
        data_iter = csv.reader(dest_f,
                               delimiter = delimiter,
                               quotechar = '"')
        data = [data for data in data_iter]
    return data


if __name__ == "__main__":
    Tk().withdraw()
    _file = "E:/Dennis/Google Drive/PhD Project/Archive/VERO/tracking_data/CANS_Info_fly_001.csv" #filedialog.askopenfilename(title='Choose file to load')
    #print(_file)
    data = read_csv(_file, delimiter=';')
    #data = np.genfromtxt(_file, delimiter=';')

    outdict = {}
    for i,entry in enumerate(data[0]):
        if i < len(data[0])-1:
            print(i)
            if data[0][i+1] != "" and entry != "":
                if len(data[1][i]) > 1:
                    outdict[str(entry)] = str(data[1][i])
                else:
                    outdict[str(entry)] = int(data[1][i])
            elif data[0][i+1] == "" and data[0][i+1] != "Date" and entry != "Date":
                array = []
                print(i, entry)
                for row in data[1:]:
                    if len(row) > 0:
                        array.append([float(row[i]) , float(row[i+1])])
                outdict[str(entry)] = np.array(array)
            elif entry == "Date":
                outdict[str(entry)+"time"] = dt.datetime.strptime(data[1][i], "%d-%b-%Y %H:%M:%S")
    print(outdict)
