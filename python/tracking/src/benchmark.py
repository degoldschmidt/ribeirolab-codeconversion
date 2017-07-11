from timeit import default_timer as timer
import numpy as np

class benchmark(object):

    def __init__(self, msg, fmt="%0.9g"):
        self.msg = msg
        self.fmt = fmt

    def __enter__(self):
        self.start = timer()
        return self

    def __exit__(self, *args):
        t = timer() - self.start
        if len(self.msg) > 0:
            print(("%s : " + self.fmt + " seconds") % (self.msg, t))
        self.time = t

class multibench(object):

    def __init__(self, times=1, msg="", fmt="%0.9g", _SILENT=True):
        if not _SILENT:
            print("Start benchmark")
            self.msg = msg
        else:
            self.msg = ""
            self.t = np.zeros(times)

    def __call__(self, f):
        self.f = f
        for i,thistime in enumerate(self.t):
            with benchmark(self.msg) as result:
                self.f()
            self.t[i] = result.time

    def __del__(self):
        print("Test {:} for {:} repititions. Total time: {:} s. Avg: {:} s. Max: {:} s.".format(self.f.__name__, len(self.t), np.sum(self.t), np.mean(self.t), np.max(self.t)))
