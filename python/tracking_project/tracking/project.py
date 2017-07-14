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
        yaml.dump({'USERS': [], 'PROJECTS': []}, outfile, default_flow_style=False, allow_unicode=True)
with open(PROFILE, 'r') as stream:
    test = yaml.load(stream)
    if test is None:
        with io.open(PROFILE, 'w+', encoding='utf8') as outfile:
            yaml.dump({'USERS': [], 'PROJECTS': []}, outfile, default_flow_style=False, allow_unicode=True)
    elif 'USERS' not in test.keys() or 'PROJECTS' not in test.keys():
        with io.open(PROFILE, 'w+', encoding='utf8') as outfile:
            yaml.dump({'USERS': [], 'PROJECTS': []}, outfile, default_flow_style=False, allow_unicode=True)


### Project class
class Project(object):
    def __init__(self, _name, _user, script=""):
        tk.Tk().withdraw()
        self.name = _name
        self.user = _user
        self.date = date.now().strftime("%Y-%m-%d %H:%M:%S")
        # Read YAML profile file
        with open(PROFILE, 'r') as stream:
            self.profile = yaml.load(stream)

        self.set_project() if self.name in self.profile['PROJECTS'] else self.add_project()
        if self.user not in self.profile['USERS']:
            self.profile["USERS"].append(self.user)
        if _user not in self.profile[self.name]["users"]:
            self.add_user()
        print("Loaded [PROJECT] {:}".format(self.name))

    def __del__(self):
        with io.open(PROFILE, 'w+', encoding='utf8') as outfile:
            yaml.dump(self.profile, outfile, default_flow_style=False, allow_unicode=True)

    def __str__(self):
        return str(yaml.dump(self.profile, default_flow_style=False, allow_unicode=True))

    def add_project(self):
        self.profile["PROJECTS"].append(self.name)
        self.profile[self.name] = {}
        project = self.profile[self.name]
        project["users"] = []
        project["users"].append(self.user)
        project["systems"] = {}
        systems = project["systems"]
        systems[NAME] = {}
        self.system = systems[NAME]
        self.system["os"] = OS
        self.system["python"] = sys.version
        project["created"] = self.date
        project["last active"] = self.date
        self.set_database(forced=True)
        self.set_output(forced=True)
        print("Created [PROJECT] {:}.".format(self.name))

    def add_logger(self, _name):
        return self.log.rename(_name)

    def add_user(self):
        project = self.profile[self.name]
        project["users"].append(self.user)

    def get_db(self):
        return self.system["database"]

    def get_log(self):
        return self.system["log"]

    def get_plot(self):
        return self.system["plot"]

    def set_database(self, forced=False):
        """
        if not forced:
            asksave = messagebox.askquestion("Set database path", "Are you sure you want to set a new path for the database?", icon='warning')
            if asksave == "no":
                return
        """
        dbfile = filedialog.askopenfilename(title="Load database")
        self.system["database"] = dbfile
        viddir = filedialog.askdirectory(title="Load directory with raw video files")
        self.system["videos"] = viddir

    def set_project(self):
        project = self.profile[self.name]
        project["last active"] = self.date
        systems = project["systems"]
        if NAME not in systems.keys():
            systems[NAME] = {}
            self.system["os"] = OS
            self.system["python"] = sys.version
        self.system = systems[NAME]

    def set_output(self, forced=False):
        """
        if not forced:
            asksave = messagebox.askquestion("Set output path", "Are you sure you want to set a new path for the output/logging?", icon='warning')
            if asksave == "no":
                return
        """
        outfolder = filedialog.askdirectory(title="Load directory for output")
        if len(outfolder) > 0:
            self.system["output"] = outfolder
            self.system["log"] = os.path.join(outfolder,"main.log")
            self.system["plot"] = os.path.join(outfolder,"plots")
        else:
            self.system["output"] = os.path.join(USER_DATA_DIR, "output")
            self.system["log"] = os.path.join(self.system["output"],"main.log")
            self.system["plot"] = os.path.join(self.system["output"],"plots")

        for each in [self.system["output"], self.system["plot"]]:
            if not os.path.exists(each):
                os.makedirs(each)
        self.plot = self.system["plot"]

    def set_user(self, _name):
        print("Set user to {:}.".format(_name))
        self.user = _name

    def show(self):
        print()
        inn = False
        thisstr = str(self).split("\n")
        sys.stdout.write(RED)
        for lines in thisstr:
            if lines == "PROJECTS:" or lines == "USERS:":
                sys.stdout.write(RED)
            elif lines.startswith("-"):
                sys.stdout.write(CYAN)
            elif self.name in lines:
                print()
                sys.stdout.write(GREEN)
                inn = True
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
