from timeit import default_timer as timer

class benchmark(object):

    def __init__(self, msg, fmt="%0.9g", times=1):
        self.msg = msg
        self.fmt = fmt
        self.count = 0
        self.end = times
        self.measured = np.zeros(times)

    def __enter__(self):
        self.start = timer()
        return self

    def __exit__(self, *args):
        t = timer() - self.start
        print(("%s : " + self.fmt + " seconds") % (self.msg, t))
        self.time = t
