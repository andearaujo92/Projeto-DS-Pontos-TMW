
WITH tb_trans_product AS(
    SELECT 
        trans.*,
        tr_prod.NameProduct,
        tr_prod.QuantityProduct

FROM transactions AS trans

LEFT JOIN transactions_product AS tr_prod
ON trans.IdTransaction = tr_prod.IdTransaction

WHERE dtTransaction < f'{date}'
AND dtTransaction >= DATE(f'{date}', '-21 days')),

tb_qtd_share_products AS
(SELECT
    IdCustomer,
    SUM(CASE WHEN NameProduct = 'Resgatar Ponei' THEN QuantityProduct ELSE 0 END) AS qtdeResgatarPonei,
    SUM(CASE WHEN NameProduct = 'ChatMessage' THEN QuantityProduct ELSE 0 END) AS qtdeChatMessage,
    SUM(CASE WHEN NameProduct = 'Lista de presença' THEN QuantityProduct ELSE 0 END) AS qtdeListaPresença,
    SUM(CASE WHEN NameProduct = 'Airflow Lover' THEN QuantityProduct ELSE 0 END) AS qtdeAirflowLover,
    SUM(CASE WHEN NameProduct = 'R Lover' THEN QuantityProduct ELSE 0 END) AS qtdeRLover,
    SUM(CASE WHEN NameProduct = 'Presença Streak' THEN QuantityProduct ELSE 0 END) AS qtdePresençaStreak,
    SUM(CASE WHEN NameProduct = 'Troca de Pontos StreamElements' THEN QuantityProduct ELSE 0 END) AS qtdeTrocaPontosStreamElements,

    SUM(CASE WHEN NameProduct = 'Resgatar Ponei' THEN pointsTransaction ELSE 0 END) AS pointsResgatarPonei,
    SUM(CASE WHEN NameProduct = 'ChatMessage' THEN pointsTransaction ELSE 0 END) AS pointsChatMessage,
    SUM(CASE WHEN NameProduct = 'Lista de presença' THEN pointsTransaction ELSE 0 END) AS pointsListaPresença,
    SUM(CASE WHEN NameProduct = 'Airflow Lover' THEN pointsTransaction ELSE 0 END) AS pointsAirflowLover,
    SUM(CASE WHEN NameProduct = 'R Lover' THEN pointsTransaction ELSE 0 END) AS pointsRLover,
    SUM(CASE WHEN NameProduct = 'Presença Streak' THEN pointsTransaction ELSE 0 END) AS pointsPresençaStreak,
    SUM(CASE WHEN NameProduct = 'Troca de Pontos StreamElements' THEN pointsTransaction ELSE 0 END) AS pointsTrocaPontosStreamElements,

    1.0 * SUM(CASE WHEN NameProduct = 'Resgatar Ponei' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS pctResgatarPonei,
    1.0 * SUM(CASE WHEN NameProduct = 'ChatMessage' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS pctChatMessage,
    1.0 * SUM(CASE WHEN NameProduct = 'Lista de presença' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS pctListaPresença,
    1.0 * SUM(CASE WHEN NameProduct = 'Airflow Lover' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS pctAirflowLover,
    1.0 * SUM(CASE WHEN NameProduct = 'R Lover' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS pctRLover,
    1.0 * SUM(CASE WHEN NameProduct = 'Presença Streak' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS pctPresençaStreak,
    1.0 * SUM(CASE WHEN NameProduct = 'Troca de Pontos StreamElements' THEN QuantityProduct ELSE 0 END) / SUM(QuantityProduct) AS pctTrocaPontosStreamElements,

    1.0 * SUM(CASE WHEN NameProduct = 'ChatMessage' THEN QuantityProduct ELSE 0 END) / COUNT(DISTINCT DATE(dtTransaction)) AS avgChatLive

FROM tb_trans_product

GROUP BY IdCustomer),

tb_grouped AS 
(SELECT
    IdCustomer,
    NameProduct,
    SUM(pointsTransaction) AS saldoPoints,
    SUM(QuantityProduct) AS Qtde

FROM tb_trans_product

GROUP BY 
    IdCustomer,
    NameProduct),

tb_rn AS
(SELECT *,
        ROW_NUMBER() OVER(PARTITION BY IdCustomer ORDER BY Qtde DESC, saldoPoints DESC) AS rn
FROM tb_grouped),

tb_produto_max AS (
    SELECT * 
    FROM tb_rn 
    WHERE rn = 1)


SELECT 
    f'{date}' AS dtRef,
    tqsp.*,
    tpm.NameProduct
FROM tb_qtd_share_products AS tqsp
LEFT JOIN tb_produto_max AS tpm
ON tqsp.IdCustomer = tpm.IdCustomer


