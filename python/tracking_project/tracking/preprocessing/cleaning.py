import pandas as pd

def interpolate(_data):
    return _data.interpolate()

def to_mm(_data, px2mm):
    return _data * px2mm
