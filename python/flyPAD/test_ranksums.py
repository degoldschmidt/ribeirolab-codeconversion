import scipy.stats as stat
import numpy as np
import matplotlib.pyplot as plt

N = 10
mu = [1000., 1200., 2500.]
var = [200., 500., 100.]
x = [0,0,0]
col = ["#26c8fe", "#ffce00", "#ff4e00"]
for ind in range(len(mu)):
    x[ind] = var[ind] * np.random.randn(N)+ mu[ind]
    plt.plot(np.zeros(N)+ind, x[ind], ".", color=col[ind])
plt.xlim([-1,len(mu)])

pvals = np.zeros((len(mu), len(mu)))
for i in range(len(mu)):
    for j in range(len(mu)):
        print((i,j), stat.wilcoxon(x[i], x[j]))
        s, p = stat.wilcoxon(x[i], x[j])

        print(stat.ttest_ind(a= x[i], b= x[j], equal_var=False)) 
        pvals[i, j] = p
print(pvals)
plt.show()
