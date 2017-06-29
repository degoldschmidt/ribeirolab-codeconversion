import tkinter as tk
from tkinter import messagebox, filedialog
from tkinter import ttk
import data_integrity as di

class DataViewerApp():
    def __init__(self, master):
        self.master = master
        self.master.wm_title("DataViewer")

if __name__ == "__main__":
        #Tk().withdraw()
        #_dir = filedialog.askdirectory(title='Choose database to load')
        #flags = di.data_check(_dir)
        root = tk.Tk()
        app = DataViewerApp(root)
        root.mainloop()
        #print(flags)
