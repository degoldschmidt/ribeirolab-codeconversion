import os
import tkinter as tk
from tkinter import messagebox, filedialog

def set_path(*args):
    if os.name == 'nt':
        homedir = os.environ['ALLUSERSPROFILE']
    else:
        homedir = os.environ['HOME']
    pathfile = homedir+os.sep+"profile.txt"
    if not is_set(pathfile):
        print("created file:"+pathfile)
        with open(pathfile, 'w+') as f:
            f.close()
    with open(pathfile, 'w') as f:
        if len(args) > 0:
            print(args)
            f.write(args[0])
        else:
            tk.Tk().withdraw()
            f.write(filedialog.askdirectory(title="Set path to log"))
    with open(pathfile, 'r') as f:
        print("Path set to: "+f.readlines()[0])

def get_path():
    if os.name == 'nt':
        homedir = os.environ['ALLUSERSPROFILE']
    else:
        homedir = os.environ['HOME']
    return homedir+os.sep+"profile.txt"
def is_set(pathfile):
    return os.path.exists(pathfile)

if __name__ == "__main__":
    set_path()
