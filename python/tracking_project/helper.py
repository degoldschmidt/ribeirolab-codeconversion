import numpy as np
import os
from datetime import datetime as dt
from datetime import timedelta
from string import Template

### datetime helpers

def get_datetime(_file, printit=False):
    dtlen = 19
    jfile = os.path.basename(_file)
    for index in range(len(jfile)-dtlen+1):
        if is_timestamp(jfile[index:index+dtlen]):
            j = index
            break
    this_time = dt.strptime(jfile[j:j+dtlen], '%Y-%m-%dT%H_%M_%S')
    if printit:
        print(this_time)
    return this_time

def get_endtime(_dtime, _len):
    return (_dtime) + millisecs(_len)

def has_timestamp(_file, printit=False, index=19):
    dtlen = 19
    try:
        this_time = dt.strptime(_file[index:index+dtlen], '%Y-%m-%dT%H_%M_%S')
    except ValueError:
        if printit:
            print("ValueError.")
        return False
    else:
        if printit:
            print("Is timestamp.")
        return True

def is_timestamp(_file, printit=False):
    dtlen = 19
    try:
        this_time = dt.strptime(_file, '%Y-%m-%dT%H_%M_%S')
    except ValueError:
        if printit:
            print("ValueError")
        return False
    else:
        if printit:
            print(this_time)
        return True

def millisecs(_ms):
    return timedelta(microseconds=_ms*1000)

def now():
    return dt.now()

def secs(_tdelta):
    return _tdelta.total_seconds()

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

def base(_file):
    return os.path.basename(_file)

def dirn(_file):
    return os.path.dirname(_file)

def get_data(_file, dur=360000, nch=64):
    with open(_file, 'rb') as f:                                                # with opening
        cap_data = np.fromfile(f, dtype=np.ushort)                              # read binary data into numpy ndarray (1-dim.)
        rows = cap_data.shape[0]                                                # to shorten next line
        cap_data = (cap_data.reshape(nch, int(rows/nch), order='F').copy())     # reshape array into 64-dim. matrix and take the transpose (rows = time, cols = channels)
        if dur == -1:                                                           # take all of the data
            pass
        elif np.isfinite(dur) and dur < cap_data.shape[1]:
            cap_data = cap_data[:,:dur]                                         # cut off data longer than duration
        else:
            if dur > cap_data.shape[1]:                                         # warning
                print("Warning: data shorter than given duration")
        #cap_data[cap_data==-1]=0
        return cap_data

def get_data_len(_file, nch=64):
    with open(_file, 'rb') as f:                                                # with opening
        cap_data = np.fromfile(f, dtype=np.ushort)                              # read binary data into numpy ndarray (1-dim.)
    return int(len(cap_data)/nch)

def get_raw_data(_file):
    with open(_file, 'rb') as f:                                                # with opening
        cap_data = np.fromfile(f, dtype=np.ushort)                              # read binary data into numpy ndarray (1-dim.)
        return cap_data

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

def write_data(_file, _data):
    ushdata = _data.astype(np.ushort)
    print(ushdata.dtype)

    with open(_file, mode='wb') as f:
        ushdata.tofile(f)
    f.close()

if __name__ == '__main__':
    print(millisecs(1000)) ## 1 second
    print(millisecs(10000)) ## 10 seconds
    print(millisecs(100000)) ## 1:40 minutes
    delta = get_endtime(now(),10) - now()
    print(now(), get_endtime(now(),100000))
    print(secs(delta))
