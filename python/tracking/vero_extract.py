import csv
import numpy as np
import pandas as pd
from tkinter import *
from tkinter import messagebox, filedialog
from tkinter import ttk
import datetime as dt
import os
import codecs, json
from helper import now, strfdelta

def read_csv(_file, delimiter=';'):
    with open(_file,'r') as dest_f:
        data_iter = csv.reader(dest_f,
                               delimiter = delimiter,
                               quotechar = '"')
        data = [data for data in data_iter]
    return data

def json_dump(_files, labels=["CANS", "ORCO", "TBEH"]):
    outdict = [{},{},{}]
    gendict = {}
    exp = labels
    for _file in os.listdir(_files):
        if "NumberCode" in _file:
            df = pd.read_csv(_files+os.sep+_file, sep=";")
            df = df.set_index("Number code")
            ndic = df.to_dict()
            toremove = []
            for k,v in ndic.items():
                for k2,v2 in v.items():
                    if type(v2) is float:
                        toremove.append([k,k2])
            for eachkey in toremove:
                ndic[eachkey[0]].pop(eachkey[1])
        for idx,ex in enumerate(exp):
            filedict = {}
            if ex+"_General_Info.csv" in _file:
                #print(_file)
                data = read_csv(_files+os.sep+_file, delimiter=';')
                for i,entry in enumerate(data[0]):
                    if entry == "":
                        pass
                    elif entry == "framerate" or entry == "num_flies" or entry == "max_frame":
                        filedict[str(entry)] = int(data[1][i])
                    elif "condition" in entry:
                        array = []
                        for row in data[1:]:
                            if len(row) > 0:
                                if "index" in entry:
                                    array.append(int(row[i]))
                                else:
                                    if len(row[i])>0:
                                        array.append(str(row[i]))
                        filedict[str(entry)] = array
                    else:
                        filedict[str(entry)] = float(data[1][i])
                gendict[ex] = filedict
            elif ex+"_Info" in _file and ".csv" in _file:
                #print(_file)
                currgen = gendict[ex]
                filedict = currgen.copy()
                number = int(_file.split("_")[3].split(".")[0])-1
                filedict.pop('condition_index', None)
                filedict.pop('condition_labels', None)
                filedict['condition'] = currgen['condition_index'][number]
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
        outdict[idx]["condition"] = {}
        for index, label in enumerate(gendict[ex]['condition_labels']):
            outdict[idx]["condition"][index+1] = str(label)
        for k,v in ndic.items():
            newdic = v.copy()
            outdict[idx][k] = {}
            for k2, v2 in newdic.items():
                outdict[idx][k][str(k2)] = str(v2)

        #print(outdict[idx].keys())
        if os.name == 'nt':
            outfold = "E:/Dennis/Google Drive/PhD Project/Archive/VERO/vero_elife_2016/"
        else:
            outfold = "/Users/degoldschmidt/Google Drive/PhD Project/Archive/VERO/vero_elife_2016/"
        json.dump(outdict[idx],codecs.open(outfold+ex+".json", 'w', encoding='utf-8'), separators=(',', ':'), sort_keys=True, indent=4)

def data_dump(_files, labels=["CANS", "ORCO", "TBEH"]):
    outdict = [{},{},{}]
    exp = labels
    for idx,ex in enumerate(exp):
        _file = ex+"_BodyXCentroids.csv"
        df = pd.read_csv(_files+os.sep+_file, delimiter=';', usecols=[0], skip_blank_lines=True, header=0)
        N=df.shape[0]
        bit = pd.read_csv(_files+os.sep+_file, delimiter=';', skip_blank_lines=True, header=0, nrows=1)
        nflies = len(bit.columns)
        print("Found", nflies, "flies.")
        parts = ["BodyX", "BodyY", "HeadX", "HeadY"]
        for flies in range(nflies):
            filearray = np.full((N, len(parts)), np.nan)
            for idx, part in enumerate(parts):
                _file = ex+"_"+part+"Centroids.csv"
                df = pd.read_csv(_files+os.sep+_file, delimiter=';', usecols=[flies], skip_blank_lines=True, header=0)
                filearray[:,idx] = np.array(df)[:,0]
                del df
            fname = ex + "_{:03d}".format(flies+1)
            if os.name == 'nt':
                outfold = "E:/Dennis/Google Drive/PhD Project/Archive/VERO/vero_elife_2016/"
            else:
                outfold = "/Users/degoldschmidt/Google Drive/PhD Project/Archive/VERO/vero_elife_2016/"
            #fullname = _files+os.sep+"new_files"+os.sep+fname
            fullname = outfold + fname
            print("Saving data for:", fname)
            print("Runtime:", strfdelta(now() - startdt, "%H:%M:%S"))
            np.savetxt(fullname+".csv", filearray, fmt='%.3f', delimiter='\t', newline='\n', header='body_x\tbody_y\thead_x\thead_y')
            #np.save(fullname+".npy", filearray)

def open_file():
    root = Tk()
    root.withdraw()
    #_files = filedialog.askopenfilenames(title='Choose file to load')
    root.update()
    out = filedialog.askdirectory(title='Choose files to load')
    root.destroy()
    return out


if __name__ == "__main__":
    startdt = now()
    if os.name == 'nt':
        _files = "E:/Dennis/Google Drive/PhD Project/Archive/VERO/tracking_data/"
    else:
        _files = open_file()

    json_dump(_files)
    data_dump(_files)
    print("Done. Runtime:", strfdelta(now() - startdt, "%H:%M:%S"))
