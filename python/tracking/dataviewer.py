import tkinter as tk
from tkinter import messagebox, filedialog
from tkinter import ttk
import data_integrity as di
from gui_elements import TreeListBox, MenuBar
import os,sys,os.path
import numpy as np

import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg, NavigationToolbar2TkAgg
# implement the default mpl key bindings
from matplotlib.backend_bases import key_press_handler
from matplotlib.figure import Figure
from matplotlib import cm

#### test seaborn style
import seaborn as sns
sns.set_style("ticks")

FILEOPENOPTIONS = dict(defaultextension='.txt',
                  filetypes=[('All files','*.*'), ('Bin file','*.txt')])

import json
def json2dict(_file):
    with open(_file) as json_data:
        d = json.load(json_data)
    return d

def tabular(_keys, _vals):
    maxlen = 0
    tablen = 4
    out = ""
    for key in _keys:
        if len(key) > maxlen:
            maxlen = len(key)
    for i,key in enumerate(_keys):
        #print("diff:",maxlen-len(key))
        out += key
        out += "\t"
        if maxlen-len(key) > 7:
            if key != "patch_radius":
                out += "\t"
        out += _vals[i]
        out += "\n"
    return out



class DataViewerApp():
    def __init__(self, master):
        self.master = master
        self.master.wm_title("DataViewer")
        self.master.minsize(width=1200, height=600)
        menulabels = {"File": [
                                ("New database", self.gotcha),
                                ("Open database", self.file_open)
                                ],
                      "Edit": [
                                ("New experiment", self.gotcha),
                                ("Edit experiment", self.file_open)
                                ],
                      "View": [
                                ("Toggle preview", self.toggle_preview)
                      ]}
        menubar = MenuBar(self.master, menulabels)
        self.master.config(menu=menubar)

        self.lframe = tk.Frame(self.master)
        self.liframe = tk.LabelFrame(self.lframe, text = "Database structure")
        self.tree = TreeListBox(self.liframe, "", {}, app=self)
        self.liframe.pack(fill=tk.BOTH, expand=tk.YES)
        self.lframe.pack(fill=tk.BOTH, side=tk.LEFT, expand=tk.YES)

        self.rframe = tk.Frame(self.master, width=500)
        self.rtframe = tk.LabelFrame(self.rframe, text = "Parameters Info", width=500, height=500)
        self.rtframe.pack(fill=tk.BOTH, expand=tk.NO)

        self.rbframe = tk.LabelFrame(self.rframe, text = "Preview", width=500, height=500)
        self.rbframe.pack(fill=tk.BOTH)
        self.rframe.pack(fill=tk.BOTH, side=tk.RIGHT, expand=tk.NO)

        self.keys = tk.StringVar()
        self.vals = tk.StringVar()
        self.keytext = tk.Label(self.rtframe, textvariable = self.keys, justify=tk.RIGHT) #relief= tk.SUNKEN,
        self.valtext = tk.Label(self.rtframe, textvariable = self.vals, justify=tk.LEFT)
        self.keytext.pack(fill=tk.BOTH, side=tk.LEFT, expand=tk.NO)
        self.valtext.pack(fill=tk.BOTH, side=tk.LEFT, expand=tk.YES)


        # a tk.DrawingArea
        self.fig = Figure(figsize=(5, 5), dpi=90)
        self.canvas = FigureCanvasTkAgg(self.fig, master=self.rbframe)
        self.canvas.show()
        self.canvas.get_tk_widget().pack(side=tk.TOP)

        #self.toolbar = NavigationToolbar2TkAgg(self.canvas, self.rbframe)
        #self.toolbar.update()
        self.canvas._tkcanvas.pack(side=tk.TOP)

        self.preview_on = False

        try:
            with open("."+os.sep+"last_login.txt", 'r') as f:
                lines = f.readlines()
            if len(lines[0]) > 0:
                self.thisfile = lines[0]
                self.load_file()
        except OSError:
            pass

    def gotcha(self):
        print("Gotcha!")

    def file_open(self):
        self.thisfile = filedialog.askopenfilename(title='Choose database to load', parent=self.master, **FILEOPENOPTIONS)
        with open("."+os.sep+"last_login.txt", 'w') as f:
            f.write(self.thisfile)
        self.load_file()

    def load_file(self):
        self.dbdict = self.load_db(self.thisfile)
        self.dir = os.path.dirname(self.thisfile)
        self.dbname = os.path.basename(self.thisfile).split(".")[0]
        self.update_tree(self.dbname+"\t[DATABASE]", self.dbdict)
        self.metadata = {}
        for vals in self.dbdict[self.dbname+"\t[DATABASE]"]:
            self.metadata[vals.split("\t")[0]] = {}
        for key in self.metadata.keys():
            jfile = self.dir+os.sep+key+".json"
            self.metadata[key] = json2dict(jfile)

    def load_db(self, _file):
        try:
            with open(_file) as f:
                lines = f.readlines()
            lineids = [line.count('|') + line.count('!') + line.count('@') for line in lines]
        except NameError:
            print('Error: cannot open database file', arg)
        outdict = {}
        for i, line in enumerate(lines):
            if lineids[i] == 1:
                database = line.split('--')[1].split('.')[0]+"\t[DATABASE]"
                outdict[database] = []
            if lineids[i] == 2:
                experiment = line.split('--')[1][:-1]+"\t[EXPERIMENT]"
                outdict[database].append(experiment)
                outdict[experiment] = []
            if lineids[i] == 3:
                session = line.split('--')[1].split('.')[0]+"\t[SESSION]"
                outdict[experiment].append(session)
                outdict[session] = []
            if line == "==\n":
                break
        return outdict

    def load_preview(self):
        self.fig.clf()
        if self.preview_on:
            a = self.fig.add_subplot(111)
            a.set_title('Loading data...', fontsize=36)
            a.set_axis_off()
            self.canvas.show()
        else:
            a = self.fig.add_subplot(111)
            a.set_title('No preview', fontsize=36)
            a.set_axis_off()
            self.canvas.show()

    def plot_preview(self):
        self.plot_opt = "BASIC"

        if self.preview_on:
            self.fig.clf()
            a = self.fig.add_subplot(111)
            subsa=1
            time = np.arange(0,len(self.data[::subsa,0]))
            if self.plot_opt == "BASIC":
                a.scatter(self.data[::subsa,0],self.data[::subsa,1], s=0.25)
            elif self.plot_opt == "TIME":
                a.scatter(self.data[::subsa,0],self.data[::subsa,1], s=0.25, c=time, cmap=cm.viridis, alpha=0.5)
            else:
                pass
            self.canvas.show()


    def set_item(self, _item):
        curr_item = self.tree.get_item()
        curr_type = self.tree.get_type()
        keystring = ""
        valstring = ""

        ### DATABASE
        if curr_type == "[DATABASE]":
            keystring += "database name:\n"
            valstring += curr_item+"\n"
        ### Experiment
        if curr_item in self.metadata.keys():
            keystring += "experiment name:\n"
            valstring += curr_item+"\n"
            keystring += "# sessions:\n"
            valstring += "{:d}\n".format( len([label for label in self.metadata[curr_item].keys() if label.startswith(curr_item)]) )
        ### Session
        if curr_type == "[SESSION]":
            exp = curr_item[:4]
            keystring += "session name:\n"
            valstring += curr_item+"\n"

            for key,val in self.metadata[exp][curr_item[:-5]].items():
                keystring += key + "\n"
                if type(val) is not list:
                    valstring += str(val)+"\n"
                else:
                    valstring += "\n"

        self.keys.set(keystring)
        self.vals.set(valstring)

        if curr_type == "[SESSION]":
            self.update_preview(curr_item)

    def toggle_preview(self):
        self.preview_on = not self.preview_on
        curr_item = self.tree.get_item()
        curr_type = self.tree.get_type()
        if curr_type == "[SESSION]":
            self.update_preview(curr_item)

    def update_preview(self, curr_item):
        self.load_preview()
        if self.preview_on:
            self.data = np.loadtxt(self.dir+os.sep+curr_item+".csv", usecols=[0, 1])
        self.plot_preview()


    def update_tree(self, _title, _dict):
        self.tree.update_tree(_title, _dict)


if __name__ == "__main__":
        #Tk().withdraw()
        #_dir = filedialog.askdirectory(title='Choose database to load')
        #flags = di.data_check(_dir)
        root = tk.Tk()
        app = DataViewerApp(root)
        while True:
            try:
                root.mainloop()
                break
            except UnicodeDecodeError:
                pass
