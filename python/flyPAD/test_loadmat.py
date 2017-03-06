import scipy.io
from tkinter import *
from tkinter import messagebox, filedialog
from tkinter import ttk
import h5py as h5

Tk().withdraw()
_file = filedialog.askopenfilename(title='Choose file to load')

with h5.File(_file, "r") as hf:
    for ind, key in enumerate(hf.keys()):
        if ind > 0:
            print(ind,":", key)
            for ind2, key2 in enumerate(hf[key].keys()):
                dataset = hf[key][key2]
                print("\t",ind2,":", key2, "->", type(dataset), "({:})".format(len(dataset)))
                for data in dataset:
                    print("\t\t", type(data), "({:})".format(len(data)))
                    break
