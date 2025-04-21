#%%
import pandas as pd

model_series = pd.read_pickle("../../models/model_rf.pkl")
model_series

# %%
# Conexão com banco de dados
engine = sqlalchemy.create_engine("sqlite:///../../data/feat_store.db")

with open("etl.sql", "r") as open_file:
    query = open_file.read()

df = pd.read_sql(query, engine)
df
# %%
