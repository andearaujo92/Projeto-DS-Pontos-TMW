#%%
import pandas as pd
import sqlalchemy
from sqlalchemy import exc
import mlflow
import mlflow.sklearn

#%%
# Importando Modelo do ML FLOW
mlflow.set_tracking_uri(uri="http://127.0.0.1:8080/")
model = mlflow.pyfunc.load_model("models:/Churn TMW@production")

features = [col.name for col in model.metadata.get_input_schema()]
print(features)

# %%
# Conexão com banco de dados
engine = sqlalchemy.create_engine("sqlite:///../../data/feat_store.db")

with open("etl.sql", "r") as open_file:
    query = open_file.read()

df = pd.read_sql(query, engine)
df
# %%
# Predições de Deploy
model = mlflow.sklearn.load_model("models:/Churn TMW@production")

preds = model.predict(df[features])
proba_churn = model.predict_proba(df[features])[:,1]

df_predict = pd.DataFrame(data = {
    'dtRef': df['dtref'],
    'idCustomer':df['idCustomer'],
    'proba_churn':proba_churn
})

df_predict.sort_values('proba_churn', ascending = False)

#%%
# Ingestão no Banco
with engine.connect() as con:

    state = sqlalchemy.text(f"DELETE FROM tb_churn WHERE dtref = {df_predict['dtRef']}")
    try:
        con.execute(state)
        con.commit()
    except exc.OperationalError as e:
        print("Tabela não encontrada... Criando Tabela")

df_predict.to_sql("tb_churn", engine, if_exists='append', index = False)

# %%
