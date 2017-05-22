import pandas as pd
from tkinter import *
from tkinter import messagebox, filedialog
from tkinter import ttk
from tkinter.font import Font
from demopanels import MsgPanel, SeeDismissPanel

class FlyLogger(ttk.Frame):

    # class variable to track direction of column
    # header sort
    SortDir = True     # descending

    def __init__(self, isapp=True, name='flylogger'):
        ttk.Frame.__init__(self, name=name)
        self.pack(expand=Y, fill=BOTH)
        self.master.title('FlyLogger')
        self.isapp = isapp
        self.dbdata = []
        self.dataCols = ('')
        self._create_widgets()
        self.master.config(menu=self._create_topmenu())
        self.master.minsize(width=600, height=400)

    def _create_topmenu(self):
        menubar = Menu(self.master)

        # create a pulldown menu, and add it to the menu bar
        filemenu = Menu(menubar, tearoff=0)
        filemenu.add_command(label="Open")
        filemenu.add_command(label="Load", command=self._load_file)
        filemenu.add_command(label="Save")
        filemenu.add_separator()
        filemenu.add_command(label="Exit", command=self.master.quit)
        menubar.add_cascade(label="File", menu=filemenu)

        # create more pulldown menus
        editmenu = Menu(menubar, tearoff=0)
        editmenu.add_command(label="Cut")
        editmenu.add_command(label="Copy")
        editmenu.add_command(label="Paste")
        menubar.add_cascade(label="Edit", menu=editmenu)

        # create more pulldown menus
        expmenu = Menu(menubar, tearoff=0)
        expmenu.add_command(label="New")
        expmenu.add_command(label="Import")
        expmenu.add_command(label="Export")
        menubar.add_cascade(label="Experiments", menu=expmenu)

        helpmenu = Menu(menubar, tearoff=0)
        helpmenu.add_command(label="About")
        menubar.add_cascade(label="Help", menu=helpmenu)

        # return the menu
        return menubar

    def _create_widgets(self):
        if self.isapp:
            """
            MsgPanel(self,
                     [ "One of the new Ttk widgets is a tree widget ",
                      "which can be configured to display multiple columns of data without ",
                      "displaying the tree itself. This is a simple way to build a listbox that has multiple ",
                      "columns.\n\n",
                      "Click a column heading to re-sort the data. ",
                      "Drag a column boundary to resize a column."])
            """
            SeeDismissPanel(self)

        self._create_panel()

    def _create_panel(self):
        self.demoPanel = Frame(self)
        self.demoPanel.pack(side=TOP, fill=BOTH, expand=Y)
        self.inner = ttk.Frame(self.demoPanel)
        self._init_treeview(self.demoPanel)

    def _init_treeview(self, parent):
        self.inner.pack_forget()
        self.inner.pack(side=TOP, fill=BOTH, expand=Y)

        # create the tree and scrollbars
        self.tree = ttk.Treeview(columns=self.dataCols, show = 'headings')

        ysb = ttk.Scrollbar(orient=VERTICAL, command= self.tree.yview)
        xsb = ttk.Scrollbar(orient=HORIZONTAL, command= self.tree.xview)
        self.tree['yscroll'] = ysb.set
        self.tree['xscroll'] = xsb.set

        # add tree and scrollbars to frame
        self.tree.grid(in_=self.inner, row=0, column=0, sticky=NSEW)
        ysb.grid(in_=self.inner, row=0, column=1, sticky=NS)
        xsb.grid(in_=self.inner, row=1, column=0, sticky=EW)

        # set frame resize priorities
        self.inner.rowconfigure(0, weight=1)
        self.inner.columnconfigure(0, weight=1)

        # configure column headings
        for c in self.dataCols:
            self.tree.heading(c, text=c.title(), command=lambda c=c: self._column_sort(c, FlyLogger.SortDir))
            self.tree.column(c, width=Font().measure(c.title()))

        # add data to the tree
        for item in self.dbdata:
            self.tree.insert('', 'end', values=item)

            # and adjust column widths if necessary
            for idx, val in enumerate(item):
                iwidth = Font().measure(val)
                if self.tree.column(self.dataCols[idx], 'width') < iwidth:
                    self.tree.column(self.dataCols[idx], width = iwidth)

    def _load_data(self, filename):
        # Read the CSV into a pandas data frame (df)
        #   With a df you can do many things
        #   most important: visualize data with Seaborn
        df = pd.read_csv(filename, sep=',')
        print(df)

        # Or export it in many ways, e.g. a list of tuples
        self.dataCols = tuple(df)
        print(self.dataCols)
        self.dbdata = [tuple(x) for x in df.values]

    def _load_file(self):
        filename = filedialog.askopenfilename(title='Choose file to load', defaultextension=".csv")
        self._load_data(filename)
        self._init_treeview(self.demoPanel)

    def _column_sort(self, col, descending=False):

        # grab values to sort as a list of tuples (column value, column id)
        # e.g. [('Argentina', 'I001'), ('Australia', 'I002'), ('Brazil', 'I003')]
        data = [(self.tree.set(child, col), child) for child in self.tree.get_children('')]

        # reorder data
        # tkinter looks after moving other items in
        # the same row
        data.sort(reverse=descending)
        for indx, item in enumerate(data):
            self.tree.move(item[1], '', indx)   # item[1] = item Identifier

        # reverse sort direction for next sort operation
        FlyLogger.SortDir = not descending

if __name__ == '__main__':
    FlyLogger().mainloop()
