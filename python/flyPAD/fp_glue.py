#!/usr/bin/env python
"""
Script for connecting flyPAD data files together. Fills lost timepoints with NaNs.

###
Usage:

"""

from tkinter import *
from tkinter import messagebox, filedialog
from tkinter import ttk
from PIL import Image, ImageTk
from helper import base, dirn, get_raw_data, get_data_len, get_datetime, get_endtime, icopath, millisecs, now, secs, strfdelta
import matplotlib
matplotlib.use("TkAgg")
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg, NavigationToolbar2TkAgg
from matplotlib import pyplot as plt
import numpy as np
from datetime import datetime as dt

class App():
    def __init__(self):
        self.root = Tk()
        ico = icopath() + 'glue.png'
        img = ImageTk.PhotoImage(file=ico)
        self.root.tk.call('wm', 'iconphoto', self.root._w, img)
        self.root.title('flyPAD Glue')
        self.root.configure(bg='white')
        self.root.resizable(0,0)
        self.nextbutton = -1

        style = ttk.Style()
        style.configure('.', font=('Helvetica', 12))

        self.lb = Listbox(self.root)
        lbxw = 5
        self.lb.grid(column=0, columnspan=lbxw, row=0)

        scrollbar = Scrollbar(self.root)
        scrollbar.grid(column=lbxw+1, row=0, sticky=W+E+N+S)

        # attach listbox to scrollbar
        self.lb.config(width=40, yscrollcommand=scrollbar.set)
        scrollbar.config(command=self.lb.yview)

        # add button
        add = self.add_button(self.root, "add.png", self.add)
        # remove button
        remove = self.add_button(self.root, "remove.png", self.remove)
        # glue button
        glue = self.add_button(self.root, "glue.png", self.glue)

        # canvas for data
        f = plt.Figure(figsize=(2,0.5), dpi=100)
        self.ax = f.add_subplot(111)
        self.ax.axis('off')
        self.canvas = FigureCanvasTkAgg(f, master=self.root)
        self.canvas.draw()
        self.canvas.get_tk_widget().grid(row=2, column=0, columnspan=lbxw+1, sticky=W+E+N+S)

        ### data structure
        self.data = {}
        self.buffer = []    # list of buffer times in secs

    def add(self):
        files = filedialog.askopenfilenames(title='Choose file/s to load')
        for _file in files:
            dtime = get_datetime(_file)
            self.data[dtime] = {}
            self.data[dtime]["filename"] = _file
            self.data[dtime]["length"] = 10.*get_data_len(_file)  # in millisecs

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
        button.grid(column=self.next_button()+1, row=1)

    def add_image(self, _name):
        image = Image.open(icopath()+_name)
        image = image.resize((36, 36), Image.ANTIALIAS) #The (250, 250) is (height, width)
        return ImageTk.PhotoImage(image)

    def clear_fig(self):
        self.ax.cla()
        self.ax.axis('off')
        self.canvas.draw()

    def glue(self, nch=64, fs=100):
        sortkeys = sorted(self.data.keys())
        files = [self.data[sortkey]["filename"] for sortkey in sortkeys]
        fulldata = get_raw_data(files[0])
        for ind, _file in enumerate(files[1:]):
            data = get_raw_data(_file)
            bufferdata = np.zeros(int(nch*fs*self.buffer[ind]))
            fulldata = np.concatenate((fulldata, data, bufferdata))

        ### CHECK LENGTHS #print(secs(self.totallen), " == ", fulldata.shape[0]/(nch*fs), "?")
        # saving file
        asksave = messagebox.askquestion("Saving glued data", "Do you want to save glued data into file?", icon='warning')
        if asksave == 'yes':
            savefile = filedialog.asksaveasfilename(title="Save datafile as...", defaultextension="", initialdir=dirn(files[0]), initialfile="GLUED"+base(files[0]))

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
    startdt = now()
    main(sys.argv[1:])
    print("Done. Runtime:", strfdelta(now() - startdt, "%H:%M:%S"))
