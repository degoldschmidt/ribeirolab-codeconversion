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
from helper import get_datetime, icopath, now, strfdelta
import matplotlib
matplotlib.use("TkAgg")
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg, NavigationToolbar2TkAgg
from matplotlib import pyplot as plt
import numpy as np

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

        self.listbox = Listbox(self.root)
        lbxw = 5
        self.listbox.grid(column=0, columnspan=lbxw, row=0)

        scrollbar = Scrollbar(self.root)
        #scrollbar.config(bg='white', highlightcolor='#45d69c', activebackground='#45d69c', troughcolor='#45d69c')
        scrollbar.grid(column=lbxw+1, row=0, sticky=W+E+N+S)

        # attach listbox to scrollbar
        self.listbox.config(width=40, yscrollcommand=scrollbar.set)
        scrollbar.config(command=self.listbox.yview)

        # add button
        add = self.add_button(self.root, "add.png", self.add)
        # remove button
        remove = self.add_button(self.root, "remove.png", lambda lb=self.listbox: self.listbox.delete(ANCHOR))
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
        self.dtime = []
        self.len = []

    def add(self):
        files = filedialog.askopenfilenames(title='Choose file/s to load')
        for _file in files:
            self.dtime.append(get_datetime(_file))
            self.listbox.insert(END, self.dtime[-1])
        self.refresh_fig(np.array([1,2,3,4]),np.array([1,1,1,1]))

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

    def glue(self):
        return 0

    def next_button(self):
        self.nextbutton += 1
        return self.nextbutton

    def refresh_fig(self,x,y):
        self.ax.plot(x,y,'r-')
        ax = self.canvas.figure.axes[0]
        ax.set_xlim(x.min(), x.max())
        ax.set_ylim(0.95, 1.05)
        self.canvas.draw()


def main(argv):
    app = App()
    app.root.mainloop()

if __name__ == "__main__":
    startdt = now()
    main(sys.argv[1:])
    print("Done. Runtime:", strfdelta(now() - startdt, "%H:%M:%S"))
