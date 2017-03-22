import numpy as np
np.set_printoptions(threshold=np.nan)
_file = "./dn.csv"

data = np.genfromtxt(_file, dtype=str, delimiter=",",filling_values=np.nan)

outdata =[]
roff = 2 # first two rows are headers
for eachrow in data[roff:]:
    outrow = []
    outrow.append(eachrow[0])
    CRG = []
    VNC = []
    coff = 1
    for j, eachcol in enumerate(eachrow[coff:]):
        if len(eachcol)>0:
            if "VNC" in data[1, j+coff]:
                VNC.append(data[1, j+coff])
            else:
                CRG.append(data[1, j+coff])
    outrow.append(VNC)
    outrow.append(CRG)
    outdata.append(outrow)

print(outdata)
