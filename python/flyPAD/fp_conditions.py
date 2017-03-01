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

def dicto(_file, _dict):
    with open(_file, "w") as json_file:
        js.dump(_dict, json_file)

def dicti(_file):
    with open(_file) as json_file:
        return js.load(json_file)

def printd(_dict):
    for tskey in _dict.keys():
        print("File:", tskey)
        curfile = _dict[tskey]
        for condkey in curfile.keys():
            cond = curfile[condkey]
            print("|             ")
            print("+-- Condition:", condkey)
            #print("   |          ")
            #print("   +-- from", cond["range"][0], "to", cond["range"][1])

class App():
    def __init__(self):
        self.root = Tk()
        ico = icopath() + 'glue.png'
        img = ImageTk.PhotoImage(Image.open(ico))
        self.root.tk.call('wm', 'iconphoto', self.root._w, img)
        self.root.title('flyPAD Conditioner')
        self.root.configure(bg='white')
        self.root.resizable(0,0)
        self.nextbutton = -1

        style = ttk.Style()
        style.configure('.', font=('Helvetica', 12))

        topframe = Frame(self.root)
        topframe.pack()
        self.lb = Listbox(topframe)
        lbxw = 5
        self.lb.pack(side=LEFT)

        scrollbar = Scrollbar(topframe)
        scrollbar.pack(side=LEFT)

        # attach listbox to scrollbar
        self.lb.config(width=50, yscrollcommand=scrollbar.set)
        scrollbar.config(command=self.lb.yview)

        bottomframe = Frame(self.root)
        bottomframe.pack(side=BOTTOM)
        # add button
        add = self.add_button(bottomframe, "add.png", self.add)
        # remove button
        remove = self.add_button(bottomframe, "remove.png", self.remove)
        # glue button
        glue = self.add_button(bottomframe, "edit.png", self.edit)

        ### data structure
        self.data = {}
        self.buffer = []    # list of buffer times in secs

    def add(self):
        files = filedialog.askopenfilenames(title='Choose file/s to load')
        for _file in files:
            dtime = get_datetime(_file)
            self.data[dtime] = {}
            self.data[dtime]["filename"] = _file
            self.data[dtime]["range"] = [1 , 16]  # arena indices

        self.lb.delete(0, END)
        sortkeys = sorted(self.data.keys())
        for key in sortkeys:
            self.lb.insert(END, key)
        self.update()


    def add_button(self, _root, _name, _command):
        button = Button(_root,justify = LEFT, highlightthickness=0,bd=0, bg='white', command=_command)
        im = self.add_image(_name)
        button.config(image=im, width=40, height=40)
        button.image = im
        button.pack(side=LEFT)

    def add_image(self, _name):
        image = Image.open(icopath()+_name)
        image = image.resize((36, 36), Image.ANTIALIAS) #The (250, 250) is (height, width)
        return ImageTk.PhotoImage(image)

    def clear_fig(self):
        self.ax.cla()
        self.ax.axis('off')
        self.canvas.draw()

    def edit(self, nch=64, fs=100):
        sortkeys = sorted(self.data.keys())
        if len(sortkeys):
            files = [self.data[sortkey]["filename"] for sortkey in sortkeys]
            fulldata = get_raw_data(files[0])
            lastvalue = fulldata[-64:]
            for ind, _file in enumerate(files[1:]):
                data = get_raw_data(_file)
                bufferdata = np.tile(lastvalue, int(fs*self.buffer[ind]))
                fulldata = np.concatenate((fulldata, bufferdata, data))

            ### CHECK LENGTHS
            print(self.totallen, " == ", fulldata.shape[0]/nch, "?")
            # saving file
            asksave = messagebox.askquestion("Saving glued data", "Do you want to save glued data into file?", icon='warning')
            if asksave == 'yes':
                savefile = filedialog.asksaveasfilename(title="Save datafile as...", defaultextension="", initialdir=dirn(files[0]), initialfile="GLUED"+base(files[0]))
                write_data(savefile, fulldata)

    def next_button(self):
        self.nextbutton += 1
        return self.nextbutton

    def refresh_fig(self,x,y,col,resize=True):
        self.ax.plot(x,y,col, linewidth=4)
        ax = self.canvas.figure.axes[0]
        if resize:
            ax.set_xlim(0, x.max())
            ax.set_ylim(0.95, 1.05)
        self.canvas.draw()

    def remove(self):
        cursel = self.lb.curselection()[0]
        remkey = dt.strptime(self.lb.get(cursel), "%Y-%m-%d %H:%M:%S")
        self.data.pop(remkey, None)
        self.lb.delete(ANCHOR)
        self.update()

    def update(self):
        sortkeys = sorted(self.data.keys())
        if len(sortkeys) > 0:
            endtime = get_endtime(sortkeys[-1], self.data[sortkeys[-1]]["length"])
            self.totallen = endtime - sortkeys[0]
            self.refresh_fig(np.array([0, secs(self.totallen)]),np.array([1,1]), 'k-')
            if len(sortkeys) > 1:
                self.buffer = []
                for ind in range(len(sortkeys)-1):
                    #print(ind)
                    start = get_endtime(sortkeys[ind], self.data[sortkeys[ind]]["length"]) - sortkeys[0]
                    end = sortkeys[ind+1] - sortkeys[0]
                    delta = secs(end) - secs(start)
                    if delta < 0:
                        this_file = self.data[sortkeys[ind]]["filename"]
                        that_file = self.data[sortkeys[ind+1]]["filename"]
                        messagebox.showwarning("Warning: Overlap detected", base(this_file)+ " and "+base(that_file)+" seem to overlap. Glued data will be invalid.")
                        self.buffer.append(0)
                    else:
                        self.buffer.append(secs(end) - secs(start))
                    self.refresh_fig(np.array([ secs(start) , secs(end)]),np.array([1,1]), 'r-', resize=False)
        else:
            self.clear_fig()

def main(argv):
    app = App()
    app.root.mainloop()

if __name__ == "__main__":
    #startdt = now()
    #main(sys.argv[1:])
    #print("Done. Runtime:", strfdelta(now() - startdt, "%H:%M:%S"))
    print("Unit test - fp_conditions.py")
    conditions = {}
    NA = 32 #number of arenas
    Tk().withdraw()
    deflist = []
    askload = messagebox.askquestion("Open defaults file", "Do you want to load defaults from file?", icon='warning')
    deffile = "E:/Dennis/Google Drive/PhD Project/Data/Jan-Feb/fulllist.txt"
    if askload == 'yes':
        deffile = filedialog.askopenfilename(title='Choose defaults to load')
        print(deffile)
    with open(deffile) as f:
        for line in f:
            symb = "'"
            st = line.find(symb)+1
            en = line.rfind(symb)-4 ## removes 8dD
            deflist.append(line[st:en])

    files = filedialog.askopenfilenames(title='Choose file/s to load')
    counter = 0
    for _file in files:
        dtime = get_datetime(_file)
        strtime = dtime.strftime("%y-%m-%dT%H:%M:%S")
        conditions[strtime] = {}
        dictf = conditions[strtime]
        dictf["filename"] = _file
        done = False
        conds = []
        print("Enter conditions for "+strtime+":")
        while done == False:
            if len(conds) > 0:
                print("Conditions:", conds)
            click.echo('Next line: ' + deflist[counter] + ' Correct? [y/n/d=done]', nl=True)
            c = click.getchar().decode("utf-8")
            print(c)
            if c == "y" or c == "b'y'":
                conds.append(deflist[counter])
                counter += 1
            elif c == "n" or c == "b'n'":
                counter += 1
                if counter == len(deflist):
                    counter = 0
            elif c == "d" or c == "b'd'":
                done = True
            elif c == "b" or c == "b'd'":
                counter -= 1
            elif c == "r" or c == "b'd'":
                conds.pop()
            elif c == "c" or c == "b'd'":
                conds.append(deflist[0])
            else:
                inp = input("custom lines:\n")
                conds = [int(s) for s in inp.split() if s.isdigit()]
                done = False
        for ind, cond in enumerate(conds):
            cond = "JRC_SS0" + cond
            dictf[cond] = {}
            dictc = dictf[cond]
            st = ind*int(NA/len(conds))+1
            en = (ind+1)*int(NA/len(conds))
            dictc["range"] = [st , en]  # arena indices
    printd(conditions)

    asksave = messagebox.askquestion("Saving conditions file", "Do you want to save conditions into a file?", icon='warning')
    if asksave == 'yes':
        savefile = filedialog.asksaveasfilename(title="Save datafile as...", defaultextension="", initialdir=dirn(files[0]))
        dicto = (savefile, conditions)
