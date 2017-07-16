import os
import ctypes
import logging
import traceback
from functools import wraps
from os.path import expanduser
import inspect, itertools
import sys
from project import is_set
def get_func():
    return traceback.extract_stack(None, 2)[0][2]
