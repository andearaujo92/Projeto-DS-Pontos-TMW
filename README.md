# Projeto de Data Science: Previsão de Churn de Alunos da Live do Téo Me Why

# Objetivo
O Objetivo desse Projeto foi prever o Churn de Alunos do Téo de acordo com o comportamento
dos mesmos na Live, olhando a base ativa em uma Janela de 21 dias.

# Etapas
- Construção de Feature Store;
- Processamento das safras;
- Construção da variável resposta;
- Construção da ABT (Analytical Base Table);
- Treinamento de modelos preditivos;
- Deploy;

# Resultados do Modelo

**Best Model Score:** `0.8367`

---

### Conjunto de Treino

| Real \ Predito | 0   | 1   |
|----------------|-----|-----|
| 0              | 679 | 205 |
| 1              | 158 | 541 |

- **Recall:** 0.774  
- **Precision:** 0.725  
- **Acurácia:** 0.771  
- **ROC-AUC Score:** 0.849

---

### Conjunto de Teste

| Real \ Predito | 0   | 1   |
|----------------|-----|-----|
| 0              | 157 | 64  |
| 1              | 39  | 136 |

- **Recall:** 0.777  
- **Precision:** 0.680  
- **Acurácia:** 0.740  
- **ROC-AUC Score:** 0.797

---

### Conjunto Out Of Time (OOT)

| Real \ Predito | 0   | 1   |
|----------------|-----|-----|
| 0              | 174 | 51  |
| 1              | 41  | 128 |

- **Recall:** 0.757  
- **Precision:** 0.715  
- **Acurácia:** 0.766  
- **ROC-AUC Score:** 0.843

