import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("TkAgg")
import matplotlib.pyplot as plt
import seaborn as sns
sns.set_style("ticks")
sns.despine(left=True)

def conj(conditions, printit=False):
    outstr = ""
    for ind, cond in enumerate(conditions):
        outstr +=  "Label == "
        outstr += "'"
        outstr += cond
        outstr += "'"
        if ind < len(conditions)-1:
            outstr += " | "
    if printit:
        print(outstr)
    return outstr

def filtered(_data, _ID, _date, _temp, _labels=[]):
    _data = _data.query("Id == '" + _ID + "'")
    _data = _data.query("Date == " +_date)
    if len(_temp) > 0 :
        _data = _data.query("Temp == '" +_temp+"'")
    if len(_labels) > 0:
        _data = _data.query(conj(_labels))
    return _data

def scatter(_ax, _data, _ID, _date, _temp, _labels, _lim=8., _showdata=False):
    #_data = filtered(_data, _ID, _date, _temp, _labels=_labels)
    cY = _data[_data["Label"] == "emptySplitGal4"]["MedianY"].unique()[0]
    cS = _data[_data["Label"] == "emptySplitGal4"]["MedianS"].unique()[0]
    _data["MedianY"] /= cY
    _data["MedianS"] /= cS

    ax = sns.FacetGrid(_data, hue="Label", palette=sns.color_palette("colorblind", n_colors=14), size=5)
    ax.map(plt.scatter, "MedianY", "MedianS", s=10, linewidth=.5, edgecolor="white")

    datax = np.array(_data["DataY"])/cY
    datay = np.array(_data["DataS"])/cS
    if _showdata:
        plt.plot(datax, datay, c="k", alpha=0.5, marker='.', ls = "None", markersize=2.5)
    x = np.arange(0.0, 20.0, 5.0)
    a = 25
    Sy1 = np.tan(np.pi*a/180)*(x-1) + 1 ##
    Sy2 = np.tan(-np.pi*a/180)*(x-1) + 1
    Yy1 = np.tan(np.pi*(90-a)/180)*(x-1) + 1
    Yy2 = np.tan(np.pi*(90+a)/180)*(x-1) + 1
    plt.plot(x, Sy1, c='#f30000', ls="dotted", lw=0.5, alpha=0.5)
    plt.plot(x, Sy2, c='#f30000', ls="dotted", lw=0.5, alpha=0.5)
    plt.plot(x, Yy1, c='#0000f3', ls="dotted", lw=0.5, alpha=0.5)
    plt.plot(x, Yy2, c='#0000f3', ls="dotted", lw=0.5, alpha=0.5)
    plt.axhline(y=1.0, xmin=0.0, xmax=1., linewidth=0.5, color = 'r', ls = "-", alpha=0.5)
    plt.axvline(x=1.0, ymin=0.0, ymax=1., linewidth=0.5, color = 'b', ls = "-", alpha=0.5)
    for label in _labels:
        _x = _data[_data["Label"] == label]["MedianY"].unique()[0]
        _y = _data[_data["Label"] == label]["MedianS"].unique()[0]
        plt.text(_x+0.01, _y+0.01, label, fontsize=8)
    plt.xlim([0.,_lim])
    plt.ylim([0.,_lim])
    plt.xlabel("Norm. median #sips yeast")
    plt.ylabel("Norm. median #sips sucrose")
    return ax

def swarmbox( _ax, _data, _x, _y, _pval, _s, ps=2, _onlybox=True, _grouped=""):
    if not _onlybox:
        if len(_grouped)==0:
            _ax = sns.swarmplot(x=_x, y=_y, hue="Signif"+_s, data=_data, size=ps, ax=_ax, palette=dict(yes = 'r', no = 'k', control = 'b'))
    if len(_grouped)==0:
        _ax = sns.boxplot(x=_x, y=_y, data=_data, width=0.4, linewidth=0.5, showcaps=False,boxprops={'facecolor':'.85'}, showfliers=False,whiskerprops={'linewidth':0}, ax=_ax)
        _ax = sns.pointplot(x=_x, y=_y, hue="Signif"+_s, data=_data, estimator=np.median, ci=None, join=False, color="0.5", markers="_", scale=0.75, ax=_ax, palette=dict(yes = 'r', no = 'k', control = 'b' ))
    else:
        _ax = sns.boxplot(x=_x, y=_y, data=_data, hue=_grouped, width=0.4, linewidth=0.5, showcaps=False, showfliers=False,whiskerprops={'linewidth':0}, palette="RdBu_r", ax=_ax)
        #_ax = sns.pointplot(x=_x, y=_y, hue="Signif"+_s, data=_data, estimator=np.median, ci=None, join=False, color="0.5", markers="_", scale=0.75, ax=_ax, palette=dict(yes = 'r', no = 'k', control = 'b' ))
        #_ax = sns.violinplot(x=_x, y=_y, hue=_grouped, data=_data, split=True, inner="stick", palette="RdBu_r");
    return _ax

def screenplot(_axes, _dataframe, _ID, _date, _temp, _sort="Y", _title="", _labels=[], _fsuff="", _onlybox=True, _grouped=""):
    Substr = ["10% Yeast", "20 mM Sucrose"]
    sr = ["Y", "S"]
    if _title == "":
        title = _ID.replace("_", " ")
    else:
        title = _title


    Df = _dataframe #filtered(_dataframe, _ID, _date, _temp, _labels=_labels)
    #print(Df["Temp"].unique())

    if _sort == "Y":
        labelorder = (Df[Df.Temp == '30ºC'].sort_values("MedianY"))["Label"].unique()
    else:
        labelorder = (Df[Df.Temp == '30ºC'].sort_values("MedianS"))["Label"].unique()
    Df = Df.set_index('Label')
    Df = Df.loc[labelorder]
    Df.reset_index(level=['Label'], inplace=True)

    for i, ax in enumerate(_axes):
        s = sr[i]
        Labels = Df["Label"].unique()
        if len(_grouped) > 0:
            Df30 = Df[Df.Temp == '30ºC']
            pVals = np.array( [ Df30[Df30.Label == label]["pVal"+s].unique()[0] for label in Labels ] )
            print(sr[i])
            for jj, label in enumerate(Labels):
                print(label, np.log10(1./pVals[jj]))
        else:
            pVals = np.array( [ Df[Df.Label == label]["pVal"+s].unique()[0] for label in Labels ] )

        cmedian = Df[Df.Label == "emptySplitGal4"]["Median"+s].unique()[0]
        ax2 = ax.twinx()
        ax2.plot(np.log10(1./pVals), 'k-', linewidth=0.5)
        ax = swarmbox(ax, Df, "Label", "Data"+s, np.log10(1./np.array(pVals[i])), s, _onlybox = _onlybox, _grouped=_grouped)
        ax.axhline(y=cmedian, xmin=0.0, xmax=1., linewidth=1, color = 'b', ls = "dotted", alpha=0.5)

        ax.set_xticklabels(Labels, rotation=60, ha='right')
        ax.grid(which='major', axis='y', linestyle='--')
        ax.tick_params(axis='both', direction='out', labelsize=9, pad=1)
        ax.tick_params(axis='y', labelsize=10)
        [lab.set_color("red") for j, lab in enumerate(ax.get_xticklabels()) if np.log10(1./np.array(pVals[j])) > 2.]
        xticks = [item.get_text() for item in ax.get_xticklabels()]
        for ix, item in enumerate(xticks):
            if xticks[ix] == 'emptySplitGal4':
                xticks[ix] = 'control'
        ax.set_xticklabels(xticks)
        [lab.set_color("blue") for j, lab in enumerate(ax.get_xticklabels()) if lab.get_text() == "control"]
        ax.set_xlabel("Split-Gal4 Label", fontsize=8, fontweight='bold')
        ax.set_ylabel(title)
        ax2.set_ylabel("log10(1/p)")
        ax.set_title(Substr[i], fontsize=12, loc='left', fontweight='bold')
        ax.legend(loc='upper left', title=" p < 0.01", labelspacing=0.25, handletextpad=-0.2, borderpad=0.,fontsize=8)

    return _axes
