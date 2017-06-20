# Import Modules
import pandas as pd
import numpy as np

pd.set_option('expand_frame_repr', False)

def sort_pd(key=None,reverse=False,cmp=None):
    def sorter(series):
        series_list = list(series)
        return [series_list.index(i)
           for i in sorted(series_list,key=key,reverse=reverse)]
    return sorter

def filtered(_data, _ID, _date, _temp, _labels=[]):
    _data = _data.query("Id == '" + _ID + "'")
    _data = _data.query("Date == " +_date)
    if len(_temp) > 0 :
        _data = _data.query("Temp == '" +_temp+"'")
    if len(_labels) > 0:
        _data = _data.query(conj(_labels))
    return _data


_file = '/Users/degoldschmidt/Google Drive/PhD Project/Data/DN-AllFlyPADcombined/alldata.csv'##filedialog.askopenfilename(title='Choose file to load')
df = pd.read_csv(_file, sep='\t', encoding='utf-8')
df = filtered(df, "Number_of_sips", "170403", "")

labelorder = (df[df.Temp == '30ºC'].sort_values("MedianY"))["Label"].unique()
"""
df = df.set_index('Label')
df = df.loc[labelorder]
df.reset_index(level=['Label'], inplace=True)
"""
Labels = df["Label"].unique()
pvalY = []
pvalS = []
for label in Labels:
    dfH = df[df.Temp == "30ºC"]
    if len(dfH[dfH.Label == label]) > 0:
        pvalY.append(dfH[dfH.Label == label]["pValY"].iloc[0])
        pvalS.append(dfH[dfH.Label == label]["pValS"].iloc[0])
        print(dfH[dfH.Label == label].head(1))
for i,label in enumerate(Labels):
    print("{:s}: {:.3f}, {:.3f}".format(label, np.log10(1./np.array(pvalY[i])) , np.log10(1./np.array(pvalS[i]))) )

"""
YpVals = np.array([df[df.Label == label]["pValY"].unique()[1] for label in Labels])
SpVals = np.array([df[df.Label == label]["pValS"].unique()[1] for label in Labels])
print(Labels)
print(np.log10(1./YpVals))
print(np.log10(1./SpVals))
"""
"""
labelorder = (df[df.Temp == '30ºC'].sort_values("MedianY"))["Label"].unique()
print(labelorder)
df = df.set_index('Label')
counts = [df[df.index == label]["DataY"].count() for label in labelorder]
df = df.loc[labelorder]
df.reset_index(level=['Label'], inplace=True)
print(df.count())
"""



"""
months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']

df = pd.DataFrame([
    ['New York','Mar',12714],
    ['New York','Apr',89238],
    ['Atlanta','Jan',8161],
    ['Atlanta','Sep',5885],
  ],columns=['location','month','sales']).set_index(['location','month'])
sort_by_month = sort_pd(key=months.index)
print(months.index)
"""
