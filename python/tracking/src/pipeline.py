import os
import subprocess as sub

"""
Pipeline class:
"""
class Pipeline():

    def __init__(self, _data, _metadata):
        self.data = _data
        self.metadata = _metadata
        self.filepath = os.path.realpath(__file__)
        self.vcommit = sub.check_output(["git", "log", "-n 1", "--pretty=format:%H", "--", self.filepath]).decode('UTF-8')

    def __repr__(self):
        return self.__class__.__name__

    def __str__(self):
        return self.vcommit
