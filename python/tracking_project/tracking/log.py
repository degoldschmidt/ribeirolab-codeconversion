import os
import ctypes
import logging
import traceback
from functools import wraps
from os.path import expanduser
import inspect, itertools
import sys
from set_path import is_set

if os.name == 'nt':
    HOMEDIR = os.environ['ALLUSERSPROFILE']
    NAME = os.environ["COMPUTERNAME"]
    OS = os.environ["OS"]
else:
    HOMEDIR = os.environ['HOME']
    NAME = os.environ["LOGNAME"]
    OS = os.name
PROFILE = HOMEDIR+os.sep+"profile.txt"
if is_set(PROFILE):
    with open(PROFILE, 'r') as f:
        LOGFILE = f.readlines()[0] + os.sep
else:
    LOGFILE = HOMEDIR+os.sep+"tracking_user_data"+os.sep+"log"+os.sep
if not os.path.exists(LOGFILE):
    os.makedirs(os.path.dirname(LOGFILE))

#FILE_ATTRIBUTE_HIDDEN = 0x02


def end_log(logger):
    logger.info("===*  ENDING SCRIPT  *===")
    logger.info("==================================================")

def get_func():
    return traceback.extract_stack(None, 2)[0][2]

def logged(f):
    @wraps(f)
    def wrapper(*args, **kwargs):
        ret = f(*args, **kwargs)
        logger = setup_log(args[0], f.__name__)
        if f.__name__ == "__init__":
            logger.info("Initializing: "+ args[0].__class__.__name__+" (version: "+args[0].vcommit+")")
        else:
            logger.info("calling: "+f.__name__)
        # if you want names and values as a dictionary:
        if len(args) > 0:
            args_name = inspect.getargspec(f)[0]
            args_dict = dict(zip(args_name, [type(arg) for arg in args]))
            logger.info("takes arg: "+str(args_dict))
        if len(args) == 0:
            logger.info("takes arg: "+str(None))

        if len(kwargs) > 0:
            kwargs_name = inspect.getargspec(f)[2]
            kwargs_dict = dict(zip(kwargs_name, type(kwargs)))
            logger.info("takes kwarg: "+str(kwargs_dict))
        if len(kwargs) == 0:
            logger.info("takes kwarg: "+str(None))
        logger.info("returns: "+str(type(ret)))
        return ret
    return wrapper

def setup_log(_module, _func, filename="main.log", scriptname="MyScript"):
    """
    The main entry point of the logging
    """
    if _module is None:
        logger = logging.getLogger(_func)
    else:
        logger = logging.getLogger(_module.__class__.__name__+"."+_func)
    logger.setLevel(logging.DEBUG)

    # create the logging file handler
    prefix = '.' if os.name != 'nt' else ''
    file_name = LOGFILE + filename
    if not os.path.exists(file_name):
        print("created file:"+file_name)
        with open(file_name, 'w+') as f:
            f.close()
    fh = logging.FileHandler(file_name)

    ## WINDOWS hidden file
    if os.name == 'nt':
        ret = ctypes.windll.kernel32.SetFileAttributesW(file_name, FILE_ATTRIBUTE_HIDDEN)
        if not ret: # There was an error.
            raise ctypes.WinError()

    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    fh.setFormatter(formatter)

    # add handler to logger object
    logger.addHandler(fh)

    if _func == "__main__":
        logger.info("==================================================")
        logger.info("===* STARTING SCRIPT: {:} *===".format(scriptname))
        logger.info("Hosted @ {:} (OS: {:})".format(NAME, OS))
        logger.info("Python version: {:}".format(sys.version))
        print("Log file @ " + file_name)
    else:
        pass
        #logger.info("Logger initialized")
    return logger