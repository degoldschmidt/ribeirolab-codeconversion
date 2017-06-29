import os, sys
import os.path, time

def get_created(filepath):
    try:
        return time.ctime(os.path.getctime(filepath))
    except OSError:
        return 0

def get_modified(filepath):
    try:
        return time.ctime(os.path.getmtime(filepath))
    except OSError:
        return 0

def check_base(lines, lineids, _dir):
    for i,lidx in enumerate(lineids):
        if lidx == 1 and lines[i][0]=='|':
            if "--" in lines[i]:
                val = lines[i].split('--')[1][:-1]
            else:
                val = 0
            print("[O.K.]" if val in os.listdir(_dir) else "[FAILED]")
    return (val in os.listdir(_dir))

def check_meta(lines, lineids, _dir):
    flag = 0
    for i,lidx in enumerate(lineids):
        if "--" in lines[i]:
            val = lines[i].split('--')[1][:-1]
        if lidx == 2:
            if not val+".json" in os.listdir(_dir):
                flag = 1
    print("[O.K.]" if flag == 0 else "[FAILED]")
    return (flag == 0)

def check_data(lines, lineids, _dir):
    flag = 0
    for i,lidx in enumerate(lineids):
        if "--" in lines[i]:
            val = lines[i].split('--')[1][:-1]
        if lidx == 3:
            if not val in os.listdir(_dir):
                flag = 1
    print("[O.K.]" if flag == 0 else "[FAILED]")
    return (flag == 0)

def check_time(lines, lineids, _dir):
    flag = 0
    for i,lidx in enumerate(lineids):
        if lidx == 4:
            filen = lines[i-1].split('--')[1][:-1]
            val = lines[i].split('--')[1].split(' & ')
            mod = val[0]
            cre = val[1][:-1]
            if not cre == get_created(_dir) and mod == get_modified(_dir):
                flag = 1
    print("[O.K.]" if flag == 0 else "[FAILED]")
    return (flag == 0)

def data_check(_dir, _VERBOSE=False):
    if _VERBOSE:
        sys.stdout = sys.__stdout__
    else:
        sys.stdout = open(os.devnull, 'w')

    arg = _dir+os.sep+os.path.basename(_dir)+".txt"
    try:
        with open(arg) as f:
            lines = f.readlines()
        lineids = [line.count('|') + line.count('!') + line.count('@') for line in lines]
    except OSError:
        print('Error: cannot open database file', arg)

    print("STARTING DATA INTEGRITY TEST...")
    print("-------------------------------")
    print("CHECKING DATABASE...\t\t\t", end='')
    basefl = check_base(lines, lineids, _dir)
    print("CHECKING METAFILES...\t\t\t", end='')
    metafl = check_meta(lines, lineids, _dir)
    print("CHECKING DATAFILES...\t\t\t", end='')
    datafl = check_data(lines, lineids, _dir)
    print("CHECKING TIMESTAMPS...\t\t\t", end='')
    timefl = check_time(lines, lineids, _dir)

    """
    if lines[i].startswith('!'):
        print("CHECKING UNIQUE IDS...\t\t\t", end='')
        print("[O.K.]" if check_uni(val, _dir) else "[FAILED]")
    if lines[i].startswith('@'):
        print("CHECKING RELATIONS...\t\t\t", end='')
        print("[O.K.]" if check_rel(val, _dir) else "[FAILED]")
    """
    sys.stdout = sys.__stdout__
    return [basefl, metafl, datafl, timefl]
