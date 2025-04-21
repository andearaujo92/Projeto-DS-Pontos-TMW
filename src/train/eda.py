#%%
import pandas as pd
import sqlalchemy
from sklearn.model_selection import train_test_split
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import warnings
warnings.filterwarnings('ignore')

#%%
# Conexão com banco de dados
engine = sqlalchemy.create_engine("sqlite:///../../data/feat_store.db")

# Query
with open("abt.sql", "r") as open_file:
    query = open_file.read()

df = pd.read_sql(query, engine)

df.head()

# %%
# Dividindo os dados em Treino e OOT
df_oot = df[df['dtRef'] == df['dtRef'].max()]
df_train = df[df['dtRef'] < df['dtRef'].max()]

print("Shape dos dados de Treino:", df_train.shape)
print("Shape dos dados de OOT:", df_oot.shape)

#%%
# Box Plots das Variáveis Numéricas
cat_features = df_train.select_dtypes(include = 'object').columns.tolist()
num_features = df_train.select_dtypes(exclude = 'object').columns.tolist()

nrows, ncols = 30, 2

fig, ax = plt.subplots(nrows=nrows, ncols=ncols, figsize = (15, 60))

for i, col in enumerate(df_train[num_features].columns):
    
    idx = i // ncols  # linha
    idy = i % ncols   # coluna

    sns.boxplot(df_train[num_features], y = col, hue='flChurn', ax= ax[idx, idy])
    plt.tight_layout()

# %%

# Distribuições das Variáveis Numéricas
cat_features = df_train.select_dtypes(include = 'object').columns.tolist()
num_features = df_train.select_dtypes(exclude = 'object').columns.tolist()

nrows, ncols = 30, 2

fig, ax = plt.subplots(nrows=nrows, ncols=ncols, figsize = (15, 60))

for i, col in enumerate(df_train[num_features].columns):
    
    idx = i // ncols  # linha
    idy = i % ncols   # coluna

    sns.histplot(df_train[num_features], x = col, ax= ax[idx, idy])
    plt.tight_layout()
# %%
# Correlação com o Target
df_train.corr(numeric_only = True)['flChurn']

