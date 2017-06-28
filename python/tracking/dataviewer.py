import csv
import numpy as np
import pandas as pd
from tkinter import *
from tkinter import messagebox, filedialog
from tkinter import ttk
import datetime as dt
import os
import codecs,json

def read_csv(_file, delimiter=';'):
    with open(_file,'r') as dest_f:
        data_iter = csv.reader(dest_f,
                               delimiter = delimiter,
                               quotechar = '"')
        data = [data for data in data_iter]
    return data

def json_dump(_files, labels=["CANS", "ORCO", "TBEH"]):
    outdict = [{},{},{}]
    exp = labels
    for _file in os.listdir(_files):
        for idx,ex in enumerate(exp):
            filedict = {}
            if ex+"_Info" in _file and ".csv" in _file:
                #print(_file)
                data = read_csv(_files+os.sep+_file, delimiter=';')
                for i,entry in enumerate(data[0]):
                    if entry == "":
                        pass
                    elif entry == "PatchPositions":
                        array = []
                        for row in data[1:]:
                            if len(row) > 0:
                                array.append([float(row[i]) , float(row[i+1])])
                        filedict[str(entry)] = array
                    elif entry == "Date":
                        filedict[str(entry)+"time"] = str(data[1][i])
                    elif entry == "SubstrateType":
                        array = []
                        for row in data[1:]:
                            if len(row) > 0:
                                array.append(int(row[i]))
                        filedict[str(entry)] = array
                    else:
                        if len(data[1][i]) > 1:
                            filedict[str(entry)] = str(data[1][i])
                        else:
                            filedict[str(entry)] = int(data[1][i])
                    splfil = _file.split("_")
                    filedict["Datafile"] = splfil[0] + "_" + splfil[3]
                    outdict[idx][splfil[0] + "_" + splfil[3].split(".")[0]] = filedict
    for idx,ex in enumerate(exp):
        print(outdict[idx].keys())
        json.dump(outdict[idx],codecs.open(_files+"/new_files/"+ex+".json", 'w', encoding='utf-8'), separators=(',', ':'), sort_keys=True, indent=4)

def data_dump(_files, labels=["CANS", "ORCO", "TBEH"]):
    outdict = [{},{},{}]
    exp = labels
    for _file in os.listdir(_files):
        for idx,ex in enumerate(exp):
            filedict = {}
            if ex in _file and "Centroids.csv" in _file:
                print(_file)
                df = pd.read_csv(_files+os.sep+_file, delimiter=';', nrows=10)
                print(df.head(10))

if __name__ == "__main__":
    Tk().withdraw()
    if os.name == 'nt':
        _files = "E:/Dennis/Google Drive/PhD Project/Archive/VERO/tracking_data/"
    else:
        #_files = filedialog.askopenfilenames(title='Choose file to load')
        _files = filedialog.askdirectory(title='Choose files to load')
    #json_dump(_files)
    data_dump(_files)


    ### READ OUT CSV HEAD and BODY CENTROID and BUILD DATAFILE PER SESSION
    #print(_file)
    #data = np.genfromtxt(_file, delimiter=';')
