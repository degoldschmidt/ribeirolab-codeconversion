import numpy as np
import pandas as pd
import logging
import os
import os.path as osp
import subprocess as sub
import sys
# Adds parent folders (TODO: add to PYTHONPATH in setup)
def par(path, level=1):
    return os.path.normpath( os.path.join(path, *([".."] * level)) )
parf = par(os.path.realpath(__file__), level=2)
sys.path.append(parf)
from pipeline import Pipeline
from log import setup_log, get_func, logged, end_log

"""
Kinematics class: loads centroid data and metadata >> processes and returns kinematic data
"""
class Kinematics(Pipeline):

    @logged
    def __init__(self, _data, _metadata):
        """
        Initializes the class. Setting up internal variables for input data; setting up logging.
        """
        Pipeline.__init__(self, _data, _metadata)

        ## overrides path-to-file and hash of last file-modified commit (version)
        self.filepath = os.path.realpath(__file__)
        self.vcommit = sub.check_output(["git", "log", "-n 1", "--pretty=format:%H", "--", self.filepath]).decode('UTF-8')
        self.dt = 1/_metadata["framerate"]

        ## logging
        #logger = setup_log(self, get_func())
        #logger.info( "initialized Kinematics pipeline (version:"+str(self)+")" )

    @logged
    def angular_speed(self, _X):
        pass

    @logged
    def distance(self, _X, _Y):
        x1, y1 = np.array(_X[_X.columns[0]]), np.array(_X[_X.columns[1]])
        x2, y2 = np.array(_Y[_Y.columns[0]]), np.array(_Y[_Y.columns[1]])
        dist_sq = np.square(x1 - x2) + np.square(y1 - y2)
        dist = np.sqrt(dist_sq)
        dist[dist==np.nan] = -1 # NaNs to -1
        df = pd.DataFrame({'distance': dist})
        return df

    @logged
    def distance_to_patch(self, _X, _patch_pos):
        return 0

    @logged
    def forward_speed(self, _X):
        pass

    @logged
    def head_angle(self, _X):
        pass

    @logged
    def linear_speed(self, _X):
        pass

    @logged
    def sideward_speed(self, _X):
        pass

## ** FUNC: distance_from_patch ** (Inputs: fly pos [tuple], patch_id [int] >> look-up from meta OR patch_pos [tuple])

## ** FUNC: linear_speed ** (Inputs: old fly pos [tuple], new fly pos [tuple], px2mm, framerate)

## ** FUNC: angular_speed ** (Inputs: old fly pos [tuple], new fly pos [tuple], px2mm, framerate)

## ** FUNC: detect_jumps **

## ** FUNC: clear_jumps **


if __name__ == "__main__":
    """
    if os.name == 'nt':
        _file = "E:\Dennis\Google Drive\PhD Project\Archive\VERO\\vero_elife_2016\CANS_008.csv"
    else:
        _file = "/Users/degoldschmidt/Google Drive/PhD Project/Archive/VERO/vero_elife_2016/CANS_008.csv"
    _data = pd.read_csv(_file, sep="\t", escapechar="#")
    _data=_data.rename(columns = {" body_x":'body_x'})
    print(_data.head(5))
    """

    logger = setup_log(None, __name__)
    kin = Kinematics(np.random.rand(100,2), {"framerate": 50})
    this = kin.distance()
    end_log(logger)

    #_data = _data.assign(speed_body_x = _data["body_x"].diff())
    #_data = _data.assign(speed_body_y = _data["body_y"].diff())
    #print(_data.head(50))