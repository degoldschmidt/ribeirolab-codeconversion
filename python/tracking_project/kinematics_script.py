"""
This will be the script in use to perform the kinematics pipeline
"""
### Standard Python

### Tracking Framework Modules
from tracking.database import Database
from tracking.analysis.kinematics import Kinematics
from tracking.benchmark import multibench
import psutil


def load_all_data(db):
        all_sessions = db.sessions() # list of all sessions
        length_db = len(all_sessions) # number of all sessions
        for i, session in enumerate(all_sessions):
                if i%(int(length_db/10))==0:
                        print(session)
                        mem = psutil.virtual_memory()
                        print("{:3d}% done. {:4.1f}% RAM used.".format(int(100*i/length_db), mem.percent))
                data, meta_data = session.load()

def main():
        _file ="E:/Dennis/Google Drive/PhD Project/Archive/VERO/vero_elife_2016/vero_elife_2016.txt"
        db = Database(_file) # database from file
        data, meta_data = db.experiment("CANS").session("001").load()
        
        #load_all_data(db)
        #print(data.head(10))
        #print(meta_data.px2mm)

if __name__=="__main__":
        test = multibench()
        test(main)
        del test
