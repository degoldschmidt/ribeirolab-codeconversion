from tkinter import *
from tkinter import messagebox, filedialog
from tkinter import ttk
import data_integrity as di

if __name__ == "__main__":
        Tk().withdraw()
        _dir = filedialog.askdirectory(title='Choose database to load')
        flags = di.data_check(_dir)
        #print(flags)
