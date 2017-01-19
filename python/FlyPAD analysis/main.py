#!/usr/bin/env python
"""
Main script for flyPAD data analysis
"""

# import packages
import os, sys
from tkinter import *
from tkinter import messagebox, filedialog
from set_parameters import cutstr, openf, set_parameters
from process_data import process_data

# metadata
__author__                  = "Dennis Goldschmidt and Pavel Itskov"
__copyright__               = "2017"
__credits__                 = ["Dennis Goldschmidt", "Pavel Itskov"]
__license__                 = "GNU GENERAL PUBLIC LICENSE v3"
__version__                 = "1.0"
__maintainer__              = "Dennis Goldschmidt"
__email__                   = "dennis.goldschmidt@neuro.fchampalimaud.org"
__status__                  = "In development"
pyversion = '{0}.{1}'.format(sys.version_info[0], sys.version_info[1])
print("Running mode for Python", pyversion)
data_dir = "/Users/degoldschmidt/Google Drive/PhD Project/Data/DN-TrpA1/10012017/"

##### Fixed Parameters
narenas                     = 32                                                # number of arenas
Remove                      = [ ]                                               # which arenas to remove for analysis
Events                      = {}                                                # Events data structure as dictionary
Events["ThisScriptName"]    = os.getcwd()                                       # current working directory
DatabaseOffset              = 0

##### Settings
removeDrift                 = True
BonsaiStyleActivityBouts    = False
Dur                         = 360000                                            # duration of experiment
TimeWindow                  = 60000                                             # Time bin for the timecourse analysis in samples

"""
specify whether or not you want to remove substrate non eaters (this will
remove all the data from channels which had less than 'NonEaterThreshold'
activity bouts)
"""
RemoveSubstrateNoneaters    = False                                             # False -> do not do anything, True -> remove

"""
specify whether or not you want to remove global non eaters(this will
remove all the data from flies which had less than 'NonEaterThreshold'
activity bouts on both of the channels)
"""
RemoveGlobalNoneaters       = True                                              # False -> do not do anything, True -> remove
NonEaterThreshold           = 2                                                 # threshold for non-eaters

"""
if this variables is set to '1' it will run a quality check and remove
the flies  which had suspected leak of food between the internal and the
outer electrodes
"""
RemoveSpillQuality          = True                                              # False -> do not do anything, True -> remove DO NOT CHANGE THIS
RemoveSpillQualityThreshold = 0.01
#PlotYN{1}                   = 'Y'
PlotYN                      = True
secRecording                = 5                                                 # duration of act bouts to plot
ConditionsToTake            = []                                                # sets conditions of interest. Leave [] if you want to take all conditions
sipThreshold                = []                                                # calibrates Events acording to sipThreshold number of sips. Leave [] if you do not want to calibrate for sips
MergeChannels               = 0

SaveEps                     = True                                              # save files in eps format
VeroTypeStatsFile           = False                                             # Which format of stats should you use(I recommend 0)
PreSipForm                  = 10                                                # irrelevant
PostSipForm                 = 10                                                # irrelevant
"""
Write 2 if
all substrates are the same across conditions,
but you want to see the results of channel 1 vs channel 2 for each condition.

Write 1 if the substrates are different in different conditions and
then fill the substrates in Events.Diff_Subs_Labels.
2 columns for the 2 substrates and 1 row per condition (as many rows as
conditions you have).
Example: if you have 6 conditions, this cell should have 6 rows.
Even if that implies that 3 of them are repeated.
"""
Different_Subs              = 0                                                 # Default is 0 (No comparison between channels).

Threshold1                  = 30000                                             # ???
Threshold2                  = 4095                                              # ???
channels                    = [[2*ind, 2*ind+1] for ind in range(narenas)]      # all channels by arena
remove_ch                   = [channels[ind] for ind in Remove]                 # channels of arenas to remove
remove_ch                   = [it for array in remove_ch for it in array]       # flattens array to 1D list
DateOffset                  = 4
RMSWindow                   = 50
PlayFrameRate               = 10
RMSThresh                   = 10
Window                      = 100                                               # maximum duration of the sip in samples
MinWindow                   = 4                                                 # minimum duration of the bout in samples
EqualityFactor              = 0.5                                               # set to 50\%, meaning that the down transition should be at least 50\% the size of the up transition
ProximityWindow             = MinWindow+3                                       # How many samples far should the transitions be
RemoveBoxPlotOutliers       = 1                                                 # This has been defined globally in Matlab

"""
Filedialog for using existing datafile
"""
Tk().withdraw()                                                                 # this is for not opening a blank window GUI
options =  {}
options['filetypes'] = [('Matlab files', '.mat'), ('csv files', '.csv')]        # allowed save filetypes

if messagebox.askyesno("Load existing datafile", \
                       "Do you want to use existing datafile?", \
                       default=messagebox.NO):                                  # File dialog: loading existing datafile
    fullpath = filedialog.askopenfilename(title="Load datafile...", \
                                                            **options)          # only open mat files
    data_file, data_dir = os.path.basename(fullpath), os.path.dirname(fullpath)
else:
    fullpath = filedialog.asksaveasfilename(title="Save datafile as...", \
                                                                **options)      # only open mat files
    data_file, data_dir = os.path.basename(fullpath), os.path.dirname(fullpath)
    Events["ConditionLabel"], Events[ "SubstrateLabel"]\
    = set_parameters(data_dir)
    process_data(data_dir, Dur, Events)
#print(Events)


#### PostProcessData02122016

#LookForInteractionBouts
#[stats2, data2, LABELS,SCORES] = PlotFLYPAD_ForScreen_17082016(Events,uSubs,blanks,screen_size,labels,Colors,BoxPlotYN,Dur,Different_Subs,TimeWindow,nCond,'Events',DataPathName);
# STATUSES=[1 2];
# SUBSTRATES=[1 2];
# ParamsToTake=1:length(fields(data2));
# PlotAndClustersScreenData(SCORES,stats2,data2,LABELS,STATUSES,SUBSTRATES,ParamsToTake)
## Save stats etc into mrep folder
#cd([DataPathName, filesep,'mrep'])
#save ('statsAnDdata2.mat', 'stats2', 'data2', 'LABELS', 'SCORES','-v7.3')
#save ('PostProcessedData.mat', 'Events','-v7.3')
