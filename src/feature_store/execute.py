# %%
import pandas as pd
import sqlalchemy
from datetime import datetime, timedelta
from tqdm import tqdm
import argparse
from sqlalchemy import exc

# %%
def import_query(path = str)->str:
    with open(f"{path}","r") as open_file:
        return open_file.read()

def date_range(start, stop):
    dt_start = datetime.strptime(start, '%Y-%m-%d')
    dt_stop = datetime.strptime(stop, '%Y-%m-%d')
    dates = []
    while dt_start <= dt_stop:
        dates.append(dt_start.strftime('%Y-%m-%d'))
        dt_start += timedelta(days=1)
    return dates

def ingest_date(query:str, table:str, date:str):

    # Substituição das datas na query
    query_fmt = query.format(date = date)

    # Executa e traz o resultado em DataFrame
    df = pd.read_sql(query_fmt, con = origin_engine)

    # Delete dos dados com a data_ref para garantir integridade
    with target_engine.connect() as con:
        try:
            state = f"DELETE FROM {table} WHERE dtRef = '{date}'"
            con.execute(sqlalchemy.text(state))
            con.commit()
        except exc.OperationalError:
            print("Erro: Tabela não existe. Ignorando erro: Criando a Tabela")


    # Enviando os dados para o novo database
    df.to_sql(table, target_engine, index = False, if_exists='append')

# %%

now = datetime.now().strftime("%Y-%m-%d")

parser = argparse.ArgumentParser()
parser.add_argument("--feature_store", "-f", help="Nome da feature store", type = str)
parser.add_argument("--start", "-s", help = "Data de início", default= now)
parser.add_argument("--stop","-p", help = "Data de fim", default = now)
args = parser.parse_args()

origin_engine = sqlalchemy.create_engine("sqlite:///../../data/database.db")
target_engine = sqlalchemy.create_engine("sqlite:///../../data/feat_store.db")

#Importando a query
query = import_query(f'{args.feature_store}.sql')
dates = date_range(args.start, args.stop)

for dt in tqdm(dates,"Enviando dados ao banco:"):
    ingest_date(query, args.feature_store, dt)
