"""
This will be the script in use to perform the kinematics pipeline
author: Dennis Goldschmidt (degoldschmidt)
date:   11-07-2017
"""
### Standard Python modules
import os

### Tracking framework modules

## Load profile for this project
from tracking.profile import get_profile, logged_f, show_profile
thisscript = os.path.basename(__file__).split(".")[0]                        # filename of this script
PROFILE = get_profile("Vero eLife 2016", "degoldschmidt", script=thisscript) # project object
#show_profile(PROFILE)

## other modules
from tracking.database import Database
from tracking.preprocessing.cleaning import interpolate, to_mm
from tracking.preprocessing.filtering import gaussian_filter
#from tracking.analysis.kinematics import Kinematics
from tracking.benchmark import multibench
import tracking.pubplot as pplt

### External modules
import numpy as np
import pandas as pd
import psutil # if I want to monitor RAM usage. >>> mem = psutil.virtual_memory(); print(mem.precent)
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
"""
def main(project):
        _file = project.get_db()
        db = Database(_file) # database from file
        #print(db.find('Videofilename=0003A01R01Cam03.avi'))
        raw_data, meta_data = db.experiment("CANS").session("005").load()
        #print(raw_data.head(5))

        ## STEP 1: NaN removal + interpolation + px-to-mm conversion
        clean_data = interpolate(raw_data)
        clean_data = to_mm(clean_data, meta_data.px2mm)
        #print(clean_data.head(5))

        ## STEP 2: Gaussian filtering
        window_len = 16 # = 0.32 s
        smoothed_data = gaussian_filter(clean_data, _len=window_len, _sigma=window_len/10)
        #print(smoothed_data.head(5))

        ## STEP 3: regrouping data to body and head position
        body_pos, head_pos = smoothed_data[['body_x', 'body_y']], smoothed_data[['head_x', 'head_y']]

        ## STEP 4: Distance from patch
        kinematics = Kinematics(smoothed_data, meta_data.dict)
        distance_patch = kinematics.distance_to_patch(smoothed_data, meta_data.dict)
        dist = kinematics.distance(smoothed_data[['body_x', 'body_y']], clean_data[['body_x', 'body_y']])

        ## STEP 5: Speed


        ## PLOTTING
        figure = []
        pplt.set_path(project.get_plot())

        ## Fig 1
        start = 55900#58085
        end = 65500#62577
        test = head_pos.loc[start:end,['head_x', 'head_y']]
        figure.append(pplt.trajectory2D(test[['head_x', 'head_y']], title= "Raw data"))
        pplt.savefig(figure[0], title="test", as_fmt="png", dpi=300)

        #pplt.show()

if __name__=="__main__":
        #### BENCHMARKING
        #test = multibench()
        #test(main)
        #del test
        ####
        try:
            main(proj)
        except (RuntimeError, TypeError, NameError):
            pass
        del proj
"""
