import numpy as np
import argparse, datetime

parser = argparse.ArgumentParser()
parser.add_argument("indices", nargs='+', help="display data of file indices given",
                    type=int)
args = parser.parse_args()
print("Showing the following files:", args.indices)

linebreaker = 8

if __name__ == '__main__':
    data = np.load('events.npz')
    print()
    for key, value in data.items():
        print('Key:', key)
        print('========================\n')
        if len(value.shape) > 0:
            value = value.tolist()
            for no, entry in enumerate(value):
                if no in args.indices:
                    if key == 'ConditionLabel':
                        if no in data["Condition"]:
                            print("{0:02d}".format(no), ":", entry)
                    else:
                        if isinstance(entry,list):
                            print("{0:02d}".format(no), ":", "\n[")
                            #print(data["Filename"][no]+ "\n[")
                            for ind in range(0, len(entry), linebreaker):
                                print("\t".join([str(sub) for sub in entry[ind:ind+linebreaker]]))
                            print("]\n")
                        else:
                            print("{0:02d}".format(no), ":", entry)
            print("\n")
        else:
            print(value, '\n')
