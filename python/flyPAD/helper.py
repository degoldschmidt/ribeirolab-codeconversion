import numpy as np
import os
from datetime import datetime as dt
from datetime import timedelta
from string import Template

### datetime helpers

def get_datetime(_file, printit=False):
    this_time = dt.strptime(_file[-19:], '%Y-%m-%dT%H_%M_%S')
    if printit:
        print(this_time)
    return this_time

def has_timestamp(_file, printit=False):
    try:
        this_time = dt.strptime(_file[-8:], '%H_%M_%S')
    except ValueError:
        return False
    else:
        if printit:
            print(this_time)
        return True

def millisecs(_ms):
    return timedelta(microseconds=_ms*1000)

def now():
    return dt.now()

class DeltaTemplate(Template):
    delimiter = "%"

def strfdelta(tdelta, fmt):
    d = {"D": tdelta.days}
    hours, rem = divmod(tdelta.seconds, 3600)
    minutes, seconds = divmod(rem, 60)
    d["H"] = '{:02d}'.format(hours)
    d["M"] = '{:02d}'.format(minutes)
    d["S"] = '{:06.3f}'.format(seconds + tdelta.microseconds/1000000)
    t = DeltaTemplate(fmt)
    return t.substitute(**d)

### filehandling helpers

def arg2files(_args):
    files = []
    for arg in _args:
        if os.path.isfile(arg):
            files.append(arg)
        if os.path.isdir(arg):
            for _file in os.listdir(arg):
                if os.path.isfile(os.path.join(arg, _file)) and is_binary_cap(os.path.join(arg, _file)):
                    files.append(arg+_file)
    return files

def get_data_len(_file, nch=64):
    with open(_file, 'rb') as f:                                                # with opening
        cap_data = np.fromfile(f, dtype=np.ushort)                              # read binary data into numpy ndarray (1-dim.)
    return int(len(cap_data)/nch)

def icopath():
    return '..'+ os.sep + '..' + os.sep + 'ico'+ os.sep

def is_binary_cap(_file):
    with open(_file, 'rb') as f:
        if b'\x00' in f.read():
            if has_timestamp(_file):                                            #### TODO: has timestamp function
                    return True
            else:
                return False
        else:
            return False
