#%%
import pandas as pd
import sqlalchemy
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.feature_selection import RFE
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestClassifier
from sklearn import metrics
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import datetime
import mlflow

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

y = df['flChurn']
X = df.drop(columns = ['flChurn','dtRef','idCustomer'])

y_oot = df_oot['flChurn']
X_oot = df_oot.drop(columns = ['flChurn','dtRef','idCustomer'])

# Split dos dados de treino
X_train, X_test, y_train, y_test = train_test_split(X, y, train_size=0.8, random_state=42, stratify= y)

print("Taxa de resposta na base Train", y_train.mean())
print("Taxa de resposta na base Test", y_test.mean() )

# %%
# Split de variaveis categóricas e numéricas

cat_features = X_train.select_dtypes(include = 'object').columns.tolist()
num_features = X_train.select_dtypes(exclude = 'object').columns.tolist()

print("Features Categóricas:", cat_features)
print("Features Numéricas:", num_features)

features = cat_features + num_features

X_oot = X_oot[features]

# %%
# Verificação de Nulos
print(X_train.isna().sum().sort_values(ascending = False))
print()
print(y.value_counts(normalize=True))

#%%
# Configurando MLFLOW
mlflow.set_tracking_uri(uri="http://127.0.0.1:8080/")
mlflow.set_experiment(experiment_id=722439221145935631)
mlflow.autolog()

# %%
#Construindo as Pipelines

preprocessor = ColumnTransformer([('onehot', OneHotEncoder(), cat_features),
                    ('scaler', StandardScaler(), num_features)])

model = RandomForestClassifier(min_samples_leaf=50)

pipe = Pipeline([
    ('preprocessor', preprocessor),
    ('model', model)
])

#%%
# Fit do modelo
pipe.fit(X_train, y_train)

# %%
# Função de Avaliação do Modelo
def report(y_true, y_pred, y_proba, data_name:str= None):

    print(pd.crosstab(y_true, y_pred, rownames=['Real'], colnames = ['Predito']),"\n")

    print("Recall:", metrics.recall_score(y_true, y_pred))
    print("Precision:", metrics.precision_score(y_true, y_pred))
    print("Acurácia:", metrics.accuracy_score(y_true, y_pred))
    print("ROC-AUC Score:", metrics.roc_auc_score(y_true, y_proba[:,1]))
    print()

    results = { f"{data_name}Recall": metrics.recall_score(y_true, y_pred),
                f"{data_name}Precision": metrics.precision_score(y_true, y_pred),
                f"{data_name}Acurácia": metrics.accuracy_score(y_true, y_pred),
                f"{data_name}ROC-AUC": metrics.roc_auc_score(y_true, y_proba[:,1])}

    return results



#%%
# Predições de treino
y_pred_train = pipe.predict(X_train)
y_proba_train = pipe.predict_proba(X_train)

report(y_train, y_pred_train, y_proba_train, 'train')

# Predições de teste
y_pred_test = pipe.predict(X_test)
y_proba_test = pipe.predict_proba(X_test)

report(y_test, y_pred_test, y_proba_test)

# Predições OOT
y_pred_oot = pipe.predict(X_oot)
y_proba_oot = pipe.predict_proba(X_oot)

report(y_oot, y_pred_oot, y_proba_oot)

# %%
# Rodando com MLFLOW e Salvando Métricas Personalizadas
with mlflow.start_run():

    # Experimentando Hiperparametros
    params = {
        'model__n_estimators': [25,50,100,150],
        'model__max_depth':[5, 10, 20, 25],
        'model__min_samples_leaf':[15, 25, 50]
    }

    grid = GridSearchCV(pipe, param_grid=params, cv=5, n_jobs=-1, verbose=3, scoring='roc_auc')

    grid.fit(X_train, y_train)


    # Predições com melhor modelo do Grid
    final_pipe = grid.best_estimator_

    print("Best Model Score", grid.best_score_,"\n")

    # Predições de treino
    y_pred_train = pipe.predict(X_train)
    y_proba_train = pipe.predict_proba(X_train)

    report_train = report(y_train, y_pred_train, y_proba_train, 'Treino')

    # Predições de teste
    y_pred_test = pipe.predict(X_test)
    y_proba_test = pipe.predict_proba(X_test)
    report_test = report(y_test, y_pred_test, y_proba_test, 'Teste')

    # Predições OOT
    y_pred_oot = pipe.predict(X_oot)
    y_proba_oot = pipe.predict_proba(X_oot)

    report_oot = report(y_oot, y_pred_oot, y_proba_oot, 'OOT')

    # Relatórios de Resultado do Modelo
    model_reports = {}
    model_reports.update(report_train)
    model_reports.update(report_test)
    model_reports.update(report_oot)
    mlflow.log_metrics(model_reports)

# %%
# Salvando o modelo
model_series = pd.Series(
    {
        'model': final_pipe,
        'features': features,
        'metrics':model_reports,
        'train_date': datetime.datetime.now()
    }
)

model_series.to_pickle("../../models/model_rf.pkl")
# %%
