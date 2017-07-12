"""
This will be the script in use to perform the kinematics pipeline
author: Dennis Goldschmidt (degoldschmidt)
date:   11-07-2017
"""
### Standard Python modules
import os

### Tracking framework modules
from tracking.database import Database
from tracking.preprocessing.filtering import gaussian_filter
from tracking.analysis.kinematics import Kinematics
from tracking.benchmark import multibench

### External modules
import psutil

def load_all_data(db):
        all_sessions = db.sessions() # list of all sessions
        length_db = len(all_sessions) # number of all sessions
        for i, session in enumerate(all_sessions):
                if i%(int(length_db/10))==0:
                        print(session)
                        mem = psutil.virtual_memory()
                        print("{:3d}% done. {:4.1f}% RAM used.".format(int(100*i/length_db), mem.percent))
                data, meta_data = session.load()

def main():
        if os.name == 'nt':
            _file = "E:/Dennis/Google Drive/PhD Project/Archive/VERO/vero_elife_2016/vero_elife_2016.txt"
        else:
            _file = "/Users/degoldschmidt/Google Drive/PhD Project/Archive/VERO/vero_elife_2016/vero_elife_2016.txt"
        db = Database(_file) # database from file
        data, meta_data = db.experiment("CANS").session("001").load()

        ## STEP 1: NaN removal + interpolation
        interpolated_data = data.interpolate()
        #print(interpolated_data.head(5))

        ## STEP 2: Gaussian filtering
        smoothed_data = gaussian_filter(interpolated_data)
        #print(smoothed_data.head(5))

        ## STEP 3: regrouping data to body and head position
        body_pos, head_pos = smoothed_data[['body_x', 'body_y']], smoothed_data[['head_x', 'head_y']]

        ## STEP 4: Distance from patch
        kine = Kinematics(smoothed_data, meta_data.dict)
        distance_patch = kine.distance_to_patch(smoothed_data, meta_data.dict)
        print(meta_data.keys())

        ## STEP 5: Speed

        #load_all_data(db)
        #print(data.head(10))
        #print(meta_data.px2mm)

if __name__=="__main__":
        test = multibench()
        test(main)
        del test
