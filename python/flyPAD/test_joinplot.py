import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# simulate some artificial data
# ========================================
np.random.seed(0)
data1 = np.random.multivariate_normal([0,0], [[1,0.5],[0.5,1]], size=200)
data2 = np.random.multivariate_normal([3,3], [[1,-0.8],[-0.8,1]], size=100)

# both df1 and df2 have bivaraite normals, df1.size=200, df2.size=100
df1 = pd.DataFrame(data1, columns=['x', 'y'])
df2 = pd.DataFrame(data2, columns=['x', 'y'])


# plot
# ========================================
graph = sns.jointplot(x=df1.x, y=df1.y, color='r', alpha=.1)
#graph = sns.jointplot(x=df2.x, y=df2.y, color='b', alpha=.1)

graph.x = df2.x
graph.y = df2.y
graph.plot_joint(plt.scatter, marker='x', c='b', s=50)
graph = graph.plot_marginals(sns.distplot, kde=False, color="b")
plt.show()
