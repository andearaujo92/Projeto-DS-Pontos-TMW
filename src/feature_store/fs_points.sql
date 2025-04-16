WITH tb_pontos_D AS
(SELECT
    idCustomer,
    SUM(pointsTransaction) AS saldoPointsD21,

     SUM(CASE 
            WHEN pointsTransaction > 0 THEN pointsTransaction
            ELSE 0 
            END) AS pointsAcumuladosD21,

     SUM(CASE 
            WHEN pointsTransaction > 0 AND dtTransaction >= DATE('{date}','-14 days') THEN pointsTransaction
            ELSE 0 
            END) AS pointsAcumuladosD14,

     SUM(CASE 
            WHEN pointsTransaction > 0 AND dtTransaction >= DATE('{date}','-7 days') THEN pointsTransaction
            ELSE 0 
            END) AS pointsAcumuladosD7,

     SUM(CASE 
            WHEN pointsTransaction < 0 THEN pointsTransaction 
            ELSE 0
            END) AS pointsResgatadosD21,

     SUM(CASE 
            WHEN pointsTransaction < 0 AND dtTransaction >= DATE('{date}','-14 days') THEN pointsTransaction 
            ELSE 0
            END) AS pointsResgatadosD14,

     SUM(CASE 
            WHEN pointsTransaction < 0 AND dtTransaction >= DATE('{date}','-7 days') THEN pointsTransaction 
            ELSE 0
            END) AS pointsResgatadosD7

FROM transactions

WHERE dtTransaction < '{date}'
AND dtTransaction >= DATE('{date}', '-21 days')

GROUP BY idCustomer),

tb_vida AS (
SELECT

    tpd.idCustomer,
    SUM(trans.pointsTransaction) AS saldoPoints,
    SUM(CASE WHEN trans.pointsTransaction > 0 THEN trans.pointsTransaction ELSE 0 END) AS pointsAcumuladosVida,
    SUM(CASE WHEN trans.pointsTransaction < 0 THEN trans.pointsTransaction ELSE 0 END) AS pointsResgatadosVida,
    ROUND(MAX(julianday('{date}') - julianday(dtTransaction)))+1 AS diasVida 

FROM tb_pontos_D AS tpd

LEFT JOIN transactions AS trans

ON tpd.idCustomer = trans.idCustomer

WHERE trans.dtTransaction < '{date}'

GROUP BY tpd.idCustomer)

SELECT 
        '{date}' AS dtRef,
        tpd.*,
        tbv.pointsAcumuladosVida,
        tbv.pointsResgatadosVida,
        (1.0 * tbv.pointsAcumuladosVida / tbv.diasVida) AS pointsPorDia

FROM tb_pontos_D AS tpd

LEFT JOIN tb_vida AS tbv
ON tpd.idCustomer = tbv.idCustomer



