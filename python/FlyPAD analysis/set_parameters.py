import sys
from tkinter import *
from tkinter import messagebox, filedialog

def cutstr(s, between):
    try:
        out = []
        if len(s) > 0:
            for ind in between:
                if ind[0] not in s:
                    print("Warning: string does not contain delimiter.")
                    return None
                if ind[1] not in s:
                    print("Warning: string does not contain delimiter.")
                    return None
                out.append(s.split(ind[0])[1].split(ind[1])[0])
            return tuple(out)
        else:
            print("Warning: empty string.")
            return None
    except:
        print(s)
        print("Unexpected error:", sys.exc_info()[0])



def openf(ext, filesdir):
    """
    Return an opened file in read mode.
    Parameters:
    - ext: default extension of the file  [string]
    """
    options =  {}
    options['filetypes'] = [('txt files', '.txt'),
                            ('log files', '.log'),
                            ('dat files', '.dat')]                              # allowed load filetypes
    return filedialog.askopenfile(mode='r', **options, defaultextension=ext, title = "Choose a file.", initialdir=filesdir)


def set_parameters(filesdir):
    """
    Return Events.ConditionLabel and Events.SubstrateLabel as python dictionary
    """
    if messagebox.askyesno ("Load log file", \
                            "Do you want to load the log file?", \
                            default=messagebox.YES):                            # filedialog to load log file
        ### USER SAYS YES
        with openf("txt", filesdir) as f:                                       # opens file from filedialog
            lines = f.readlines()                                               # reading line by line
            condLabels = []                                                     # temp. list for condition labels
            substrLabels = []                                                   # temp. list for substrate labels
            for line in lines:
                data = cutstr(line, [("{","}"), ("'","'")])                     # relevant data from line
                if "ConditionLabel" in line:
                    condLabels.append(data)
                elif "SubstrateLabel" in line:
                    substrLabels.append(data)
            condLabels.sort(key=lambda x: x[0])
            substrLabels.sort(key=lambda x: x[0])
        return [conds[1] for conds in condLabels],\
                [subs[1] for subs in substrLabels]                              # return two lists with condition and substrate labels, respectively
    else:
        ### USER SAYS NO
        print("no")
        print("using default values instead")

"""
This is a unit test function
"""
if __name__=='__main__':
    Events = set_parameters("/Users/degoldschmidt/Google Drive/PhD Project/Data/DN-TrpA1/09012017")
    print("Condition labels:\n", Events["ConditionLabel"])
    print("Substrate labels:\n", Events["SubstrateLabel"])
