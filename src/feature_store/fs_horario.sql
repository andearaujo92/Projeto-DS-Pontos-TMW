WITH tb_hora AS
(SELECT
    idCustomer,
    CASE WHEN pointsTransaction > 0 THEN pointsTransaction ELSE 0 END AS pointsTransaction,
    CAST(STRFTIME('%H', DATETIME(dtTransaction, '-3 hour')) AS INTEGER) AS hour
FROM transactions

WHERE dtTransaction < '{date}'
AND dtTransaction >= DATE('{date}', '-21 days')
),
tb_share AS 
(SELECT
    IdCustomer,
    SUM(CASE WHEN hour >= 8 AND hour < 12 THEN pointsTransaction ELSE 0 END) AS qtdePointsManha,
    SUM(CASE WHEN hour >= 12 AND hour < 18 THEN pointsTransaction ELSE 0 END) AS qtdePointsTarde,
    SUM(CASE WHEN hour >= 18 AND hour < 23 THEN pointsTransaction ELSE 0 END) AS qtdePointsNoite,

    1.0 * SUM(CASE WHEN hour >= 8 AND hour < 12 THEN pointsTransaction  ELSE 0 END) / SUM(pointsTransaction) AS pctPointsManha,
    1.0 * SUM(CASE WHEN hour >= 12 AND hour < 18 THEN pointsTransaction  ELSE 0 END) / SUM(pointsTransaction) AS pctPointsTarde,
    1.0 * SUM(CASE WHEN hour >= 18 AND hour < 23 THEN pointsTransaction  ELSE 0 END) / SUM(pointsTransaction) AS pctPointsNoite,

    SUM(CASE WHEN hour >= 8 AND hour < 12 THEN 1  ELSE 0 END) AS qtdTransactionsManha,
    SUM(CASE WHEN hour >= 12 AND hour < 18 THEN 1  ELSE 0 END) AS qtdTransactionsTarde,
    SUM(CASE WHEN hour >= 18 AND hour < 23 THEN 1  ELSE 0 END) AS qtdTransactionsNoite,

    1.0 * SUM(CASE WHEN hour >= 8 AND hour < 12 THEN 1  ELSE 0 END) / SUM(1) AS pctTransactionsManha,
    1.0 * SUM(CASE WHEN hour >= 12 AND hour < 18 THEN 1  ELSE 0 END) / SUM(1) AS pctTransactionsTarde,
    1.0 * SUM(CASE WHEN hour >= 18 AND hour < 23 THEN 1  ELSE 0 END) / SUM(1) AS pctTransactionsNoite
    
FROM
    tb_hora
GROUP BY
    IdCustomer)

SELECT
    '{date}' AS dtRef,
    *
FROM tb_share