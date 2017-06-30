import tkinter as tk
from tkinter import ttk

root = tk.Tk()
tree = ttk.Treeview(root)
tree.pack(fill=tk.BOTH,expand=True)

testdict = {"Main": ["Stuff1", "Stuff2"]}

tree.insert("", index="end",iid="Main", text="main branch")
tree.insert("Main", index="end", text="Stuff 1")
tree.insert("Main", index="end", text="Stuff 2")

root.mainloop()
