import tkinter as tk
from tkinter import messagebox, filedialog
from tkinter import ttk
import data_integrity as di
from gui_elements import TreeListBox, MenuBar
import os,sys,os.path

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
    print("max:", maxlen)
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
        self.master.minsize(width=800, height=600)
        menulabels = {"File": [
                                ("New database", self.gotcha),
                                ("Open database", self.file_open)
                                ]}
        menubar = MenuBar(self.master, menulabels)
        self.master.config(menu=menubar)

        self.lframe = tk.Frame(self.master, width=600)
        self.liframe = tk.LabelFrame(self.lframe, text = "Database structure", width=600)
        self.tree = TreeListBox(self.liframe, "", {}, app=self)
        self.liframe.pack(fill=tk.BOTH, expand=tk.YES)
        self.lframe.pack(fill=tk.BOTH, side=tk.LEFT, expand=tk.YES)

        self.rframe = tk.Frame(self.master, width=500)
        self.rtframe = tk.LabelFrame(self.rframe, text = "Parameters Info", width=500, height=500)
        self.rtframe.pack(fill=tk.BOTH, expand=tk.NO)

        self.rbframe = tk.LabelFrame(self.rframe, text = "Preview", width=500, height=500)
        self.rbframe.pack(fill=tk.BOTH)
        self.rframe.pack(fill=tk.BOTH, side=tk.RIGHT, expand=tk.NO)

        self.info = tk.StringVar()
        self.infotext = tk.Label(self.rtframe, textvariable = self.info, relief = tk.SUNKEN, justify=tk.LEFT)
        self.infotext.pack(fill=tk.BOTH)

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
        except OSError:
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

    def set_item(self, _item):
        curr_item = _item['text'].split("\t")[0]
        curr_type = _item['text'].split("\t")[1]
        infostring = ""

        ### DATABASE
        if curr_type == "[DATABASE]":
            infostring += "database name:\t"+curr_item+"\n"
        ### Experiment
        if curr_item in self.metadata.keys():
            infostring += "experiment name:\t"+curr_item+"\n"
            infostring += "# sessions:\t{:d}\n".format( len([label for label in self.metadata[curr_item].keys() if label.startswith(curr_item)]) )
        ### Session
        if curr_type == "[SESSION]":
            exp = curr_item[:4]
            infostring += "session name:\t"+curr_item+"\n"

            listkeys = []
            listvals = []
            for key,val in self.metadata[exp][curr_item[:-5]].items():
                listkeys.append(key)
                if type(val) is not list:
                    listvals.append(str(val))
                else:
                    listvals.append("")
            infostring+=tabular(listkeys, listvals)

        self.info.set(infostring)



    def update_tree(self, _title, _dict):
        self.tree.update_tree(_title, _dict)


if __name__ == "__main__":
        #Tk().withdraw()
        #_dir = filedialog.askdirectory(title='Choose database to load')
        #flags = di.data_check(_dir)
        root = tk.Tk()
        app = DataViewerApp(root)
        root.mainloop()
        #print(flags)
