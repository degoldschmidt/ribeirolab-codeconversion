import numpy as np
import pandas as pd
import os

### Kinematics class loads centroid data and metadata >> processes and returns kinematic data

## ** FUNC: distance_from_patch ** (Inputs: fly pos [tuple], patch_id [int] >> look-up from meta OR patch_pos [tuple])

## ** FUNC: linear_speed ** (Inputs: old fly pos [tuple], new fly pos [tuple], px2mm, framerate)

## ** FUNC: angular_speed ** (Inputs: old fly pos [tuple], new fly pos [tuple], px2mm, framerate)

## ** FUNC: detect_jumps **

## ** FUNC: clear_jumps **

## ** FUNC: detect_jumps **


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
