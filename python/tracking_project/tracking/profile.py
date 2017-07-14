### Native
import os, sys
from datetime import datetime as date
import logging
import logging.config
from functools import wraps

### External modules
import tkinter as tk
from tkinter import messagebox, filedialog
import yaml
import io

### Global Constants (based on OS)
RED   = "\033[1;31m"
BLUE  = "\033[1;34m"
CYAN  = "\033[1;36m"
YELLOW = "\033[1;33m"
GREEN = "\033[1;32m"
RESET = "\033[0;0m"
BOLD    = "\033[;1m"
REVERSE = "\033[;7m"
if os.name == 'nt':
    HOMEDIR = os.environ['ALLUSERSPROFILE']
    NAME = os.environ["COMPUTERNAME"]
    OS = os.environ["OS"]
else:
    HOMEDIR = os.environ['HOME']
    NAME = os.environ["LOGNAME"]
    OS = os.name
USER_DATA_DIR = os.path.join(HOMEDIR, "tracking_user_data")
if not os.path.exists(USER_DATA_DIR):
    os.makedirs(USER_DATA_DIR)
PROFILE = os.path.join(USER_DATA_DIR, "profile.yaml")
if not os.path.exists(PROFILE):
    # Write YAML file
    with io.open(PROFILE, 'w+', encoding='utf8') as outfile:
        yaml.dump({'$USERS': [], '$PROJECTS': []}, outfile, default_flow_style=False, allow_unicode=True)
with open(PROFILE, 'r') as stream:
    test = yaml.load(stream)
    if test is None:
        with io.open(PROFILE, 'w+', encoding='utf8') as outfile:
            yaml.dump({'$USERS': [], '$PROJECTS': []}, outfile, default_flow_style=False, allow_unicode=True)
    elif '$USERS' not in test.keys() or '$PROJECTS' not in test.keys():
        with io.open(PROFILE, 'w+', encoding='utf8') as outfile:
            yaml.dump({'$USERS': [], '$PROJECTS': []}, outfile, default_flow_style=False, allow_unicode=True)


### Project class
def get_profile( _name, _user, script=""):
    tk.Tk().withdraw()
    nowdate = date.now().strftime("%Y-%m-%d %H:%M:%S")

    ### Read YAML profile file
    with open(PROFILE, 'r') as stream:
        profile = yaml.load(stream)

    for projects in profile['$PROJECTS']:
        profile[projects]["active"] = False
    ### PROJECT EXISTS
    if _name in profile['$PROJECTS']:
        project = profile[_name]
        project["last active"] = nowdate
        project["active"] = True

        systems = project["systems"]
        ### CURRENT COMPUTERNAME IS NOT IN PROFILE
        if NAME not in systems.keys():
            systems[NAME] = {}
            system = systems[NAME]
            system["os"] = OS
        else:
            system = systems[NAME]
        system["python"] = sys.version
        system = systems[NAME]

    ### CREATE NEW PROJECT
    else:
        profile["$PROJECTS"].append(_name)
        profile[_name] = {}
        project = profile[_name]
        project["users"] = []
        project["users"].append(_user)
        project["created"] = nowdate
        project["last active"] = nowdate
        project["active"] = True

        project["systems"] = {}
        systems = project["systems"]
        ### ADD COMPUTERNAME TO PROFILE
        systems[NAME] = {}
        system = systems[NAME]
        system["os"] = OS
        system["python"] = sys.version

        ### SET UP DATABASE LOCATION
        dbfile, viddir = set_database(forced=True)
        if dbfile is not None and viddir is not None:
            system["database"] = dbfile
            system["videos"] = viddir

        ### SET UP OUTPUT LOCATION
        out, log, plot = set_output(forced=True)
        if out is not None:
            system["output"] = out
            system["log"] = log
            system["plot"] = plot
        print("Created [PROJECT] {:}.".format(_name))

    ### CREATE NEW USER
    users = profile['$USERS']
    if _user not in users:
        users.append(_user)

    ### ADD USER TO PROJECT
    if _user not in project["users"]:
        project["users"].append(_user)

    ### RETURN
    print("Loaded [PROJECT] {:}".format(_name))
    with io.open(PROFILE, 'w+', encoding='utf8') as outfile:
        yaml.dump(profile, outfile, default_flow_style=False, allow_unicode=True)
    return profile

def set_database(forced=False):
    if not forced:
        asksave = messagebox.askquestion("Set database path", "Are you sure you want to set a new path for the database?", icon='warning')
        if asksave == "no":
            return None, None
    dbfile = filedialog.askopenfilename(title="Load database")
    viddir = filedialog.askdirectory(title="Load directory with raw video files")
    return dbfile, viddir


def set_output(forced=False):
    if not forced:
        asksave = messagebox.askquestion("Set output path", "Are you sure you want to set a new path for the output/logging?", icon='warning')
        if asksave == "no":
            return None, None, None
    outfolder = filedialog.askdirectory(title="Load directory for output")
    ### IF ANYTHING GIVEN
    if len(outfolder) > 0:
        out = outfolder
        log = os.path.join(outfolder,"main.log")
        plot = os.path.join(outfolder,"plots")
    else:
        out = os.path.join(USER_DATA_DIR, "output")
        log = os.path.join(out,"main.log")
        plot = os.path.join(out,"plots")
    ### CHECK WHETHER FOLDERS EXIST
    for each in [out, plot]:
        if not os.path.exists(each):
            os.makedirs(each)
    ### RETURN
    return out, log, plot

def show_profile(profile):
    print
    for projects in profile['$PROJECTS']:
        if profile[projects]["active"]:
            current = projects
    profile_dump = yaml.dump(profile, default_flow_style=False, allow_unicode=True)
    thisstr = profile_dump.split("\n")
    sys.stdout.write(RED)
    for lines in thisstr:
        if lines == "$PROJECTS:" or lines == "$USERS:":
            sys.stdout.write(RED)
        elif lines.startswith("-"):
            sys.stdout.write(CYAN)
        elif current in lines:
            print()
            sys.stdout.write(GREEN)
        else:
            sys.stdout.write(RESET)
        print(lines)
    sys.stdout.write(RESET)

class Logger(object):
    def __init__(self, profile, scriptname):
        """
        The main entry point of the logging
        """
        self.profile = profile

        ### logfilename
        self.file_name = self.profile.get_log()
        if not os.path.exists(self.file_name):
            print("created file:"+self.file_name)
            with open(self.file_name, 'w+') as f:
                f.close()
        self.fh = logging.FileHandler(self.file_name)

        self.log = logging.getLogger(self.profile.name)
        self.log.setLevel(logging.DEBUG)

        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        self.fh.setFormatter(formatter)
        # add handler to logger object
        self.log.addHandler(self.fh)

        self.log.info("==================================================")
        self.log.info("===* STARTING SCRIPT: {:} *===".format(scriptname))
        self.log.info("Hosted @ {:} (OS: {:})".format(NAME, OS))
        self.log.info("Python version: {:}".format(sys.version))
        print("Log file @ " + self.file_name)

    def rename(self, _name, _func):
        self.log = logging.getLogger(_name+"."+_fun)
        self.log.setLevel(logging.DEBUG)
        self.log.addHandler(self.fh)

    def __del__(self):
        logger = logging.getLogger(self.profile.name)
        logger.setLevel(logging.DEBUG)
        logger.addHandler(self.fh)
        logger.info("===*  ENDING SCRIPT  *===")
        logger.info("==================================================")

def logged_f(logfile):
    def wrapper(func):
        @wraps(func)
        def func_wrapper(*args, **kwargs):
            print(logfile, func.__name__)
            return func(*args, **kwargs)
        return func_wrapper
    return wrapper
