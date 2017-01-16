#import tkinter
from tkinter import *
from tkinter import messagebox

## This is the name of the file where the data will be stored
"""
[DataFilename DataPathName ] = uiputfile;                                     # opens filedialog
if strcmp(DataFilename(end-3:end),'.rpt')
    DataFilename(end-3:end)='.mat';                                             # force ending to be .mat, instead .rpt
end
cd(DataPathName)
DataFilename2=[DataPathName DataFilename];                                      # Path + file variable
"""

def askopenfilename(self):
    """
    Return a file name of chosen file.
    """
    # get filename
    filename = filedialog.askopenfilename(**self.file_opt)
    # open file on your own
    if filename:
        return open(filename, 'r')


def set_parameters():
    """
    Return Events.ConditionLabel and Events.SubstrateLabel
    """
    Tk().withdraw()
    if messagebox.askquestion("Load log file", "Do you want to load the log file?", default=messagebox.YES):
        print("yes")
        
    else:
        print("no")


"""

if strcmpi(LoadLOGFILE,'Y')                                                     # If Answer: YES
[LOGFilename LOGPathName]=uigetfile('*.txt','Please select the LOG file with condition labels and Substrate labels'); # file dialog for log file

cd (LOGPathName)
delimiter = ';';                                                                # log file delimiter
formatSpec = '#s#[^\n\r]';                                                      # string [^] ??
fileID = fopen(LOGFilename,'r');                                                # open log file for reading
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false); # scan log file text for entries
fclose(fileID);                                                                 # close log file
LOGFILEDATA = dataArray{:, 1};                                                  # make it 1D cell
for nEntries=1:length(LOGFILEDATA)                                              # go through log file data
    try
        eval(LOGFILEDATA{nEntries})                                             # evaluate as MATLAB command LOGFILEDATA >> Events.ConditionLabel and Events.SubstrateLabel
    catch
        warning('Check the log file, there were some lines that could not be executed')
    end
end
clearvars filename delimiter formatSpec fileID dataArray ans;                   # clear variables (!!!think about this!!!)

# default values if no log file
else
## Put analysis parameters here
# these are the labels for different conditions
Events.ConditionLabel{1}= 'attp2 1D@0';
Events.ConditionLabel{2}= 'R26E02 1D@0';
Events.ConditionLabel{3}= 'R28E01 1D@0';
Events.ConditionLabel{4}= 'R39E02 1D@0';
Events.ConditionLabel{5}= 'R72D06 1D@0';
Events.ConditionLabel{6}= 'R14A02 1D@0';
Events.ConditionLabel{7}= 'R17A11 1D@0';
Events.ConditionLabel{8}= 'R18A04 1D@0';
Events.ConditionLabel{9}= 'R17A10 1D@0';
Events.ConditionLabel{10}= 'R21H11 1D@0';
Events.ConditionLabel{11}= 'R20E08 1D@0';
Events.ConditionLabel{12}= 'R22E06 1D@0';
Events.ConditionLabel{13}= 'R18A12 1D@0';
Events.ConditionLabel{14}= 'attp2 1D@100';
Events.ConditionLabel{15}= 'R22E06 1D@100';
Events.ConditionLabel{16}= 'R18A12 1D@100';
Events.ConditionLabel{17}= 'R21H11 1D@100';
Events.ConditionLabel{18}= 'R20E08 1D@100';
Events.ConditionLabel{19}= 'R18A04 1D@100';
Events.ConditionLabel{20}= 'R17A10 1D@100';
Events.ConditionLabel{21}= 'R17A11 1D@100';
Events.ConditionLabel{22}= 'R14A02 1D@100';
Events.ConditionLabel{23}= 'R72D06 1D@100';
Events.ConditionLabel{24}= 'R39G02 1D@100';
Events.ConditionLabel{25}= 'R28E01 1D@100';
Events.ConditionLabel{26}= 'R26E02 1D@100';


## These are the labels for substrates (what goes on channel 1 and 2)
Events.SubstrateLabel{1}='10#Yeast';
Events.SubstrateLabel{2}='10#Sucrose';

end
"""
set_parameters()
