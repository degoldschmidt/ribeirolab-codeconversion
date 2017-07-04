import tkinter as tk
import tkinter.ttk as ttk
import tkinter.font as tk_font
import os

class TreeListBox:

    def __init__(self, master, root, dict_group, app=None):
        self.master = master
        self.root = root
        self.app = app
        self.dict_group = dict_group
        self.level = 0
        self.setup_widget_tree()
        if len(dict_group.keys()) > 0:
            self.build_tree(self.root, '')

        # create a popup menu
        self.rcMenu = tk.Menu(master, tearoff=0)
        self.rcMenu.add_command(label="Open video annotator")
        self.rcMenu.add_command(label="Open analysis pipeline")

    def right_click(self, event):
        curItem = self.tree.focus()
        curText = self.tree.item(curItem)['text']
        if curText.split("\t")[1] == "[SESSION]":
            self.rcMenu.post(event.x_root, event.y_root)

    def setup_widget_tree(self):
        #container_tree = tk.Frame(self.master, width=500, height=300)
        #container_tree.propagate(False)
        #container_tree.pack(side="left", fill='y')
        self.tree = ttk.Treeview(self.master, show="tree", selectmode='browse')
        #fr_y = tk.Frame(container_tree)
        #fr_y.pack(side='right', fill='y')
        #tk.Label(fr_y, borderwidth=1, relief='raised', font="Arial 8").pack(side='bottom', fill='x')
        #sb_y = tk.Scrollbar(fr_y, orient="vertical", command=self.tree.yview)
        #sb_y.pack(fill='y')
        #fr_x = tk.Frame(container_tree)
        #fr_x.pack(side='bottom', fill='x')
        #sb_x = tk.Scrollbar(fr_x, orient="horizontal", command=self.tree.xview)
        #sb_x.pack(fill='x')
        #self.tree.configure(yscrollcommand=sb_y.set, xscrollcommand=sb_x.set)
        self.tree.bind('<ButtonRelease-1>', self.selectItem)
        self.tree.bind('<KeyRelease-Up>', self.selectItem)
        self.tree.bind('<KeyRelease-Down>', self.selectItem)
        if os.name == 'nt':
            self.tree.bind("<Button-3>", self.right_click)
        else:
            self.tree.bind("<Button-2>", self.right_click)
        self.tree.pack(fill=tk.BOTH,expand=True)


    def update_tree(self, _root, _dict):
        self.root = _root
        self.dict_group = _dict
        self.tree.heading('#0', text='Database')
        #self.tree.heading('#1', text='Experiment')
        #self.tree.heading('#2', text='Session')
        #self.tree.column('#1', stretch=Tkinter.YES)
        #self.tree.column('#2', stretch=Tkinter.YES)
        #self.tree.column('#0', stretch=Tkinter.YES)
        if len(_dict.keys()) > 0:
            self.build_tree(self.root, '')

    def build_tree(self, parent, id_stroki):
        self.level += 1
        id = self.tree.insert(id_stroki, 'end', text=parent)
        # -----------------
        col_w = tk_font.Font().measure(parent)
        if col_w > 1000:
            col_w -= 400
        elif col_w > 500:
            col_w -= 200
        elif col_w > 300:
            col_w -= 100
        col_w = col_w + 25 * self.level
        if col_w > self.tree.column('#0', 'width'):
            self.tree.column('#0', width=col_w)
        # -----------------
        for element in sorted(self.dict_group[parent]):
            self.build_tree(element, id)
        self.level -= 1

    def selectItem(self, a):
        curItem = self.tree.focus()
        #print(self.tree.item(curItem))
        self.app.set_item(self.tree.item(curItem))

class MenuBar(tk.Menu):
    def __init__(self, master, labels):
        tk.Menu.__init__(self, master)
        for label, llist in labels.items():
            menu = tk.Menu(self, tearoff=0)
            self.add_cascade(label=label, menu=menu)
            for slab in llist:
                if isinstance(slab, tuple):
                    menu.add_command(label=slab[0], command=slab[1])
                else:
                    menu.add_command(label=slab)


if __name__ == '__main__':
    dict_group = {'Nomenclature': ['ABC1', 'ABC2'],
                  'ABC1': ['ABC3', 'ABC4'],
                  'ABC2': ['ABC5'],
                  'ABC3': ['ABC______________________________________6'],
                  'ABC4': ['ABC--------------------------------------8'],
                  'ABC5': ['ABC######################################9'],
                  'ABC______________________________________6': [],
                  'ABC--------------------------------------8': [],
                  'ABC######################################9': []
                  }
    root = tk.Tk()
    myTest = TreeListBox(root, 'Nomenclature', dict_group)
    root.mainloop()
