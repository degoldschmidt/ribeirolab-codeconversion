import json

def json2dict(_file):
    with open(_file) as json_data:
        d = json.load(json_data)
    return d
