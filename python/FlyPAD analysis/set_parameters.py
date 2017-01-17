import sys
from tkinter import *
from tkinter import messagebox, filedialog

## This is the name of the file where the data will be stored
"""
[DataFilename DataPathName ] = uiputfile;                                     # opens filedialog
if strcmp(DataFilename(end-3:end),'.rpt')
    DataFilename(end-3:end)='.mat';                                             # force ending to be .mat, instead .rpt
end
cd(DataPathName)
DataFilename2=[DataPathName DataFilename];                                      # Path + file variable
"""

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
    return filedialog.askopenfile(mode='r', defaultextension=ext, title = "Choose a file.", initialdir=filesdir)


def set_parameters(filesdir):
    """
    Return Events.ConditionLabel and Events.SubstrateLabel as python dictionary
    """
    Tk().withdraw()
    if messagebox.askquestion("Load log file", "Do you want to load the log file?", default=messagebox.YES):
        ### USER SAYS YES
        with openf("txt", filesdir) as f:                                       # opens file from filedialog
            lines = f.readlines()                                               # reading line by line
            condLabels = []                                                     # temp. list for condition labels
            substrLabels = []                                                   # temp. list for substrate labels
            for line in lines:
                data = cutstr(line, [("{","}"), ("'","'")])                 # relevant data from line
                if "ConditionLabel" in line:
                    condLabels.append(data)
                elif "SubstrateLabel" in line:
                    substrLabels.append(data)
            condLabels.sort(key=lambda x: x[0])
            substrLabels.sort(key=lambda x: x[0])
        events = {"ConditionLabel": [conds[1] for conds in condLabels], "SubstrateLabel": [subs[1] for subs in substrLabels]}
        return events
    else:
        ### USER SAYS NO
        print("no")
        print("using default values instead")

Events = set_parameters("/Users/degoldschmidt/Google Drive/PhD Project/Data/DN-TrpA1/09012017")
print("Condition labels:\n", Events["ConditionLabel"])
print("Substrate labels:\n", Events["SubstrateLabel"])
