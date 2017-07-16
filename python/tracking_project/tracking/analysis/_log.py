import inspect, itertools
import logging
from functools import wraps
import os, sys
import yaml

if os.name == 'nt':
    HOMEDIR = os.environ['ALLUSERSPROFILE']
    NAME = os.environ["COMPUTERNAME"]
    OS = os.environ["OS"]
else:
    HOMEDIR = os.environ['HOME']
    NAME = os.environ["LOGNAME"]
    OS = os.name
USER_DATA_DIR = os.path.join(HOMEDIR, "tracking_user_data")
PROFILE = os.path.join(USER_DATA_DIR, "profile.yaml")
with open(PROFILE, 'r') as stream:
    test = yaml.load(stream)
    if '$LINK' in test.keys():
        link = test['$LINK']
        print("Found link to {:}".format(link))
        PROFILE = os.path.join(link, "profile.yaml")

def get_log_path():
    with open(PROFILE, 'r') as stream:
        profile = yaml.load(stream)
    return profile[profile['active']]['systems'][NAME]['log']


def get_log(_module, _func, _logfile):
    """
    The main entry point of the logging
    """
    logger = logging.getLogger(_module.__class__.__name__+"."+_func)
    logger.setLevel(logging.DEBUG)

    # create the logging file handler
    if not os.path.exists(_logfile):
        print("created file:"+_logfile)
        with open(_logfile, 'w+') as f:
            f.close()
    fh = logging.FileHandler(_logfile)

    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    fh.setFormatter(formatter)
    # add handler to logger object
    logger.addHandler(fh)
    return logger


def logged_f(_logfile):
    def wrapper(func):
        @wraps(func)
        def func_wrapper(*args, **kwargs):
            logger = get_log(args[0], func.__name__, _logfile)
            if func.__name__ == "__init__":
                logger.info("Initializing: "+ args[0].__class__.__name__+" (version: "+args[0].vcommit+")")
            else:
                logger.info("calling: "+func.__name__)
            # if you want names and values as a dictionary:
            if len(args) > 0:
                args_name = inspect.getargspec(func)[0]
                args_dict = dict(zip(args_name, [type(arg) for arg in args]))
                logger.info("takes arg: "+str(args_dict))
            if len(args) == 0:
                logger.info("takes arg: "+str(None))

            if len(kwargs) > 0:
                kwargs_name = inspect.getargspec(func)[2]
                kwargs_dict = dict(zip(kwargs_name, type(kwargs)))
                logger.info("takes kwarg: "+str(kwargs_dict))
            if len(kwargs) == 0:
                logger.info("takes kwarg: "+str(None))
            out = func(*args, **kwargs)
            logger.info("returns: "+str(type(out)))
            return out
        return func_wrapper
    return wrapper
