import seaborn as sns
sns.set_style("ticks")
sns.despine(left=True)

import functools
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

def swarmbox(_data, _x, _y, _pval, _ax, ps=2, hueon=False):
    if hueon:
        un_med = [ _data[_data["Label"]==label]["Median"].unique()[0] for label in _data["Label"].unique()]
        pal = sns.diverging_palette(240, 10, s=99, n=201)
        pal = [pal[int(100*(med+1))] for med in un_med]
        _ax = sns.boxplot(x=_x, y=_y, palette=pal, data=_data, width=0.4, linewidth=0.5, showcaps=False, showfliers=False,whiskerprops={'linewidth':0}, ax=_ax)
    else:
        _ax = sns.boxplot(x=_x, y=_y, data=_data, width=0.4, linewidth=0.5, showcaps=False,boxprops={'facecolor':'.85'}, showfliers=False,whiskerprops={'linewidth':0}, ax=_ax)
    _ax = sns.swarmplot(x=_x, y=_y, hue="Signif", data=_data, size=ps, ax=_ax, palette=dict(Yes = 'r', No = 'k'))
    _ax = sns.pointplot(x=_x, y=_y, data=_data, estimator=np.median, ci=None, join=False, color="0.5", markers="_", scale=0.75, ax=_ax)
    return _ax

def screenplot(_axes, _dataframe, _ID, _sort="Y", _title="", _labels=[], _fsuff=""):
    Substr = ["10% Yeast", "20 mM Sucrose"]
    Substr = ["Y", "S"]

    Df = _dataframe.query(conj(_labels))

    if _sort == "Y":
        Df = Df.sort_values("Median")
    else:
        Df = Df.sort_values("MedianS")

    for i, ax in enumerate(_axes):
        ax = swarmbox(Df, "Label", "DataY", np.log10(1./np.array(plotpvals[i])), ax)
        ax2 = ax.twinx()
        ax2.plot(np.log10(1./np.array(plotpvals[i])), 'k-', linewidth=0.5)
        ax.set_xticklabels(Labels[i], rotation=60, ha='right')
        ax.grid(which='major', axis='y', linestyle='--')
        ax.tick_params(axis='both', direction='out', labelsize=9, pad=1)
        ax.tick_params(axis='y', labelsize=10)
        [lab.set_color("red") for j, lab in enumerate(ax.get_xticklabels()) if np.log10(1./np.array(plotpvals[i][j])) > 2.]
        ax.set_xlabel("JRC SplitGal4 Label", fontsize=8, fontweight='bold')
        ax.set_ylabel(title)
        ax.set_title(Substr[i], fontsize=12, loc='left', fontweight='bold')
        ax.legend(loc='upper left', title=" p < 0.01", labelspacing=0.25, handletextpad=-0.2, borderpad=0.,fontsize=8)


    """
    ID = _ID
    if _title == "":
        title = _ID.replace("_", " ")
    else:
        title = _title
    supptitle = get_cond(_file)
    Substr = ["10% Yeast", "20 mM Sucrose"]
    Df, pvals = h5_to_panda(_file, ID)
    fwid = 10
    if len(_only) > 0:
        Df[0] = Df[0].query(conj(_only))
        Df[1] = Df[1].query(conj(_only))
        if len(_only) > 15:
            fwid *= len(_only)/50
        else:
            fwid *= len(_only)/30
        supptitle= ""


    if _sort == "Y":
        Df[0] = Df[0].sort_values("Median")
        Df[1] = Df[1].reindex(Df[0].index)
    else:
        Df[1] = Df[1].sort_values("Median")
        Df[0] = Df[0].reindex(Df[1].index)
    Labels = [Df[0]["Label"].unique(), Df[1]["Label"].unique()]
    for j, substr_labels in enumerate(Labels):
        for i, labl in enumerate(substr_labels):
            if type(labl) is float:
                if np.isnan(labl):
                    print(j, labl, type(labl))
                    Labels[j] = np.delete(Labels[j], i)
    plotpvals = [[pvals[label][0] for label in Labels[0]], [pvals[label][1] for label in Labels[1]]]
    f, axes = plt.subplots(2, sharex=False, figsize=(fwid,5))
    for i,ax in enumerate(axes):
        ax = swarmbox(Df[i], "Label", "Data", np.log10(1./np.array(plotpvals[i])), ax)
        ax2 = ax.twinx()
        ax2.plot(np.log10(1./np.array(plotpvals[i])), 'k-', linewidth=0.5)
        ax.set_xticklabels(Labels[i], rotation=60, ha='right')
        ax.grid(which='major', axis='y', linestyle='--')
        ax.tick_params(axis='both', direction='out', labelsize=9, pad=1)
        ax.tick_params(axis='y', labelsize=10)
        [lab.set_color("red") for j, lab in enumerate(ax.get_xticklabels()) if np.log10(1./np.array(plotpvals[i][j])) > 2.]
        ax.set_xlabel("JRC SplitGal4 Label", fontsize=8, fontweight='bold')
        ax.set_ylabel(title)
        ax.set_title(Substr[i], fontsize=12, loc='left', fontweight='bold')
        ax.legend(loc='upper left', title=" p < 0.01", labelspacing=0.25, handletextpad=-0.2, borderpad=0.,fontsize=8)
    plt.suptitle(supptitle, fontsize=12)
    if len(lims)>1:
        axes[0].set_ylim([lims[0], lims[1]])
    if len(lims)>3:
        axes[1].set_ylim([lims[2], lims[3]])
    plt.tight_layout()
    #folder = os.path.dirname(_file)+os.sep+"plots"+os.sep
    folder = "/Users/degoldschmidt/Google Drive/PhD Project/Data/2017_01/Final plots/" ## MacOS fullpath
    fullfile = get_filename(_file, ID, _sort,_suf=_fsuff)
    print("Saving plot for", title, "as:", folder+fullfile)
    plt.savefig(folder+fullfile, dpi=300)
    plt.clf()
    plt.close()
    """
