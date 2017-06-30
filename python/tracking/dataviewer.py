import tkinter as tk
from tkinter import messagebox, filedialog
from tkinter import ttk
import data_integrity as di
from gui_elements import TreeListBox, MenuBar

class DataViewerApp():
    def __init__(self, master):
        self.master = master
        self.master.wm_title("DataViewer")
        menubar = MenuBar(self.master)
        self.master.config(menu=menubar)

        self.lframe = tk.LabelFrame(self.master, text = "Database structure")
        self.lframe.pack(fill=tk.BOTH, side=tk.LEFT, expand=tk.YES)
        self.tree = TreeListBox(self.lframe, "", {})

        self.rframe = tk.Frame(self.master)
        self.rtframe = tk.LabelFrame(self.rframe, text = "Parameters Info")
        self.rtframe.pack(fill=tk.BOTH)

        self.rbframe = tk.LabelFrame(self.rframe, text = "Preview")
        self.rbframe.pack(fill=tk.BOTH)
        self.rframe.pack(fill=tk.BOTH, side=tk.RIGHT)

        self.info = tk.StringVar()
        self.infotext = tk.Label(self.rtframe, textvariable = self.info, relief = tk.SUNKEN, justify=tk.LEFT)
        self.infotext.pack()

    def update_tree(self, _title, _dict):
        self.tree = TreeListBox(self.lframe, _title, _dict)


if __name__ == "__main__":
        #Tk().withdraw()
        #_dir = filedialog.askdirectory(title='Choose database to load')
        #flags = di.data_check(_dir)
        root = tk.Tk()
        app = DataViewerApp(root)
        root.mainloop()
        #print(flags)
