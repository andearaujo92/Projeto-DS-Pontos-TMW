WITH tb_rfv AS (

SELECT
    idCustomer,
    ROUND(
        MIN(julianday((SELECT MAX(dtTransaction) FROM transactions)) - julianday(dtTransaction))
        ) + 1 AS recenciaDias,
     COUNT(DISTINCT DATE(dtTransaction)) AS frequenciaDias,
     SUM(CASE 
            WHEN pointsTransaction > 0 THEN pointsTransaction 
            END) AS valorPoints
FROM transactions

WHERE dtTransaction < (SELECT MAX(dtTransaction) FROM transactions)
AND dtTransaction >= DATE((SELECT MAX(dtTransaction) FROM transactions), '-21 days')

GROUP BY idCustomer

),
tb_idade_base AS (

SELECT 
    idCustomer,
    ROUND(
        MAX(julianday((SELECT MAX(dtTransaction) FROM transactions)) - julianday((dtTransaction)))
        ) + 1 AS idadeBaseDias
FROM transactions
GROUP BY idCustomer 
)

SELECT 
    tb_rfv.idCustomer,
    frequenciaDias,
    recenciaDias,
    valorPoints,
    idadeBaseDias,
    flEmail
FROM tb_rfv
LEFT JOIN tb_idade_base
ON tb_rfv.idCustomer = tb_idade_base.idCustomer
LEFT JOIN customers
ON customers.idCustomer = tb_idade_base.idCustomer

