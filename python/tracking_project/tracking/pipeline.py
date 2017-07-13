import os
import subprocess as sub

"""
Operator class:
"""
class Operator():
    def __init__(self, _f):
        self.func = _f

    def __mul__(self, other):
        if other is not Operator:
            return self.func(other)

    def __rmul__(self, other):
        return self.func(other)


"""
Pipeline class:
"""
class Pipeline():

    def __init__(self, _data, _metadata, logger=None):
        self.data = _data.copy()
        self.metadata = _metadata.copy()
        self.filepath = os.path.realpath(__file__)
        self.vcommit = sub.check_output(["git", "log", "-n 1", "--pretty=format:%H", "--", self.filepath]).decode('UTF-8')

        self.logger = logger

        ### pipeline contains operations, variables and parameters
        self.ops = {}
        self.vars = {}
        self.params = {}

        """ example of pipeline graph
        V
        |
        #== inputdata:
        |
        *-- function1: __name__, args, kwargs, ret
        |
        #== data1:
        |
        *-- function2: __name__, args, kwargs, ret
        |\
        | *-- function2.1: __name__, args, kwargs, ret
        | |
        *-|-- function2.2: __name__, args, kwargs, ret
        | |
        | #== data2.2:
        V
        """

    def __repr__(self):
        return self.__class__.__name__

    def __str__(self):
        return self.vcommit

    def __and__(self, other):
        pass
    ### total_pipeline = pipelineA & pipelineB & pipelineC
