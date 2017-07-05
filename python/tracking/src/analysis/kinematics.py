import numpy as np
import pandas as pd
import os

if __name__ == "__main__":
    if os.name == 'nt':
        _file = "E:\Dennis\Google Drive\PhD Project\Archive\VERO\\vero_elife_2016\CANS_008.csv"
    else:
        _file = "/Users/degoldschmidt/Google Drive/PhD Project/Archive/VERO/vero_elife_2016/CANS_008.csv"
    _data = pd.read_csv(_file, sep="\t", escapechar="#")
    _data=_data.rename(columns = {" body_x":'body_x'})
    print(_data.head(5))
    _data = _data.assign(speed_body_x = _data["body_x"].diff())
    _data = _data.assign(speed_body_y = _data["body_y"].diff())
    print(_data.head(50))
