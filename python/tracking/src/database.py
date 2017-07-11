""" Only for testing
"""
import tkinter as tk
from tkinter import messagebox, filedialog
from tkinter import ttk

""" Really required for classes
"""
import os
from fileio import json2dict
from graphdict import GraphDict

class Database(object):
    def __init__(self, _filename):
        dictstruct = self.load_db(_filename)
        self.struct = GraphDict(dictstruct)
        self.dir = os.path.dirname(_filename)
        self.name = os.path.basename(_filename).split(".")[0]

        ### set up experiments
        self.experiments = []
        for key in dictstruct[self.name].keys():
            jfile = self.dir+os.sep+key+".json"
            self.experiments.append(Experiment(jfile))

    def experiment(self, identifier):
        """
        identifier: int or string identifying the experiment
        """
        if identifier == "":
            endstr = ""
            for ses in self.sessions:
                endstr += str(ses)+"\n"
            return endstr
        elif type(identifier) is int:
            return self.experiments[identifier]
        elif type(identifier) is str:
            for exp in self.experiments:
                if exp.name == identifier:
                    return exp
        return "[ERROR]: experiment not found."

    def load_db(self, _file):
        try:
            with open(_file) as f:
                lines = f.readlines()
            lineids = [line.count('|') + line.count('!') + line.count('@') for line in lines]
        except NameError:
            print('[ERROR]: cannot open database file', arg)

        outdict = {}
        for i, line in enumerate(lines):
            if lineids[i] == 1:
                database = line.split('--')[1].split('.')[0]
                outdict[database] = {}
            if lineids[i] == 2:
                experiment = line.split('--')[1][:-1]
                outdict[database][experiment] = []
            if lineids[i] == 3:
                session = line.split('--')[1].split('.')[0]
                outdict[database][experiment].append(session)
            if line == "==\n":
                break
        return outdict

    def __str__(self):
        return str(self.struct)


class Experiment(object):
    def __init__(self, _file):
        self.dict = json2dict(_file)
        self.file = _file
        self.name = _file.split(os.sep)[-1].split(".")[0]

        ### set up sessions inside experiment
        self.sessions = []
        for key, val in self.dict.items():
            if self.name in key:
                self.sessions.append(Session(val, _file, key))
        #print(self.sessions[-1])

    def __getattr__(self, name):
        return self.dict[name]

    def __str__(self):
        return self.name +" <class '"+ self.__class__.__name__+"'>"

    def session(self, identifier):
        """
        identifier: int or string identifying the experiment
        """
        if identifier == "":
            endstr = ""
            for ses in self.sessions:
                endstr += str(ses)+"\n"
            return endstr
        if type(identifier) is int:
            return self.sessions[identifier]
        elif type(identifier) is str:
            for ses in self.sessions:
                if ses.name == identifier:
                    return ses
        return "[ERROR]: session not found."


class Session(object):
    """
    Session class creates an object that hold meta-data of single session and has the functionality to load data into pd.DataFrame or np.ndarray
    """
    def __init__(self, _dict, _file, _key):
        self.dict = _dict
        self.file = _file
        self.name = _key

    def __getattr__(self, name):
        return self.dict[name]

    def __str__(self):
        return self.name +" <class '"+ self.__class__.__name__+"'>"

    def keys(self):
        str = ""
        lkeys = self.dict.keys()
        for i, k in enumerate(lkeys):
            str += "({:})\t{:}\n".format(i,k,self.dict[k])
        str += "\n"
        return str

    def load(self, load_as="pd"):
        if load_as == "pd":
            pass
        elif load_as == "np":
            pass
        else:
            print("[ERROR]: session not found.")

    def nice(self):
        str = """
=================================
Meta-data for session {:}
=================================\n\n
""".format(self.name)
        lkeys = self.dict.keys()
        for i, k in enumerate(lkeys):
            str += "({:})\t{:}:\n\t\t\t{:}\n\n".format(i,k,self.dict[k])
        str += "\n"
        return str

if __name__=="__main__":
    """ only needed for filedialog
    FILEOPENOPTIONS = dict(defaultextension='.txt',
                      filetypes=[('All files','*.*'), ('Bin file','*.txt')])
    tk.Tk().withdraw()
    """

    _file ="E:/Dennis/Google Drive/PhD Project/Archive/VERO/vero_elife_2016/vero_elife_2016.txt" ##filedialog.askopenfilename(title='Choose database to load', **FILEOPENOPTIONS)
    db = Database(_file)
    print(db.experiment("CANS").session(0).keys())
