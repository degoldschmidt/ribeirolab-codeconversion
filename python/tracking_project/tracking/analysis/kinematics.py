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
from project import logged_f

"""
Kinematics class: loads centroid data and metadata >> processes and returns kinematic data
"""
class Kinematics(Pipeline):

    #@Logger.logged
    def __init__(self, _data, _metadata):
        """
        Initializes the class. Setting up internal variables for input data; setting up logging.
        """
        Pipeline.__init__(self, _data, _metadata, logger=None)

        ## overrides path-to-file and hash of last file-modified commit (version)
        self.filepath = os.path.realpath(__file__)
        self.vcommit = sub.check_output(["git", "log", "-n 1", "--pretty=format:%H", "--", self.filepath]).decode('UTF-8')
        self.dt = 1/_metadata["framerate"]

        ## logging
        #logger = setup_log(self, get_func())
        #logger.info( "initialized Kinematics pipeline (version:"+str(self)+")" )

    #@Pipeline.logged
    def angular_speed(self, _X):
        pass

    @logged_f("woo")
    def distance(self, _X, _Y):
        x1, y1 = np.array(_X[_X.columns[0]]), np.array(_X[_X.columns[1]])
        x2, y2 = np.array(_Y[_Y.columns[0]]), np.array(_Y[_Y.columns[1]])
        dist_sq = np.square(x1 - x2) + np.square(y1 - y2)
        dist = np.sqrt(dist_sq)
        dist[dist==np.nan] = -1 # NaNs to -1
        df = pd.DataFrame({'distance': dist})
        return df

    @logged_f("woo")
    def distance_to_patch(self, _X, _patch_pos):
        return 0

    #@logged("woo")
    def forward_speed(self, _X):
        pass

    #@logged
    def head_angle(self, _X):
        pass

    #@logged
    def linear_speed(self, _X):
        pass

    #@logged
    def sideward_speed(self, _X):
        pass

## ** FUNC: distance_from_patch ** (Inputs: fly pos [tuple], patch_id [int] >> look-up from meta OR patch_pos [tuple])

## ** FUNC: linear_speed ** (Inputs: old fly pos [tuple], new fly pos [tuple], px2mm, framerate)

## ** FUNC: angular_speed ** (Inputs: old fly pos [tuple], new fly pos [tuple], px2mm, framerate)

## ** FUNC: detect_jumps **

## ** FUNC: clear_jumps **
