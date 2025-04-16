WITH tb_transactions AS
(
    SELECT *
    FROM transactions
    WHERE dtTransaction < '{date}'
    AND dtTransaction >= DATE('{date}', '-21 days')
),

tb_freq AS (
SELECT 
    IdCustomer,
    COUNT(DISTINCT DATE(dtTransaction)) AS frequenciaDiasD21,
    COUNT(DISTINCT CASE WHEN DATE(dtTransaction) > DATE('{date}','-14 days') THEN DATE(dtTransaction) END) AS frequenciaDiasD14,
    COUNT(DISTINCT CASE WHEN DATE(dtTransaction) > DATE('{date}','-7 days') THEN DATE(dtTransaction) END) AS frequenciaDiasD7

FROM tb_transactions

GROUP BY IdCustomer),

tb_tempo_live_aux AS
(SELECT

    IdCustomer,
    DATE(DATETIME(dtTransaction, '-3 hour')) dtTransactionDate,
    MIN(DATETIME(dtTransaction, '-3 hour')) dtInicio,
    MAX(DATETIME(dtTransaction, '-3 hour')) dtFim

FROM tb_transactions

GROUP BY 
   1,2
),

tb_tempo_live AS
(SELECT 
    IdCustomer,
    dtTransactionDate,
    (julianday(dtFim) - julianday(dtInicio))*24*60 AS tempoEmLive
FROM tb_tempo_live_aux),


tb_summary_tempo_live AS
(SELECT

    IdCustomer,
    AVG(tempoEmLive) avgTempoLive,
    SUM(tempoEmLive) totalTempoLive,
    MIN(tempoEmLive) minTempoLive,
    MAX(tempoEmLive) maxTempoLive

FROM tb_tempo_live

GROUP BY IdCustomer),

tb_vida AS
(SELECT
    IdCustomer,
    COUNT(DISTINCT idTransaction) qtdTransactionsVida,
    COUNT(DISTINCT idTransaction) / MAX(julianday('{date}') - julianday((dtTransaction))) AS avgTransPorDia
FROM tb_transactions

GROUP BY IdCustomer)

SELECT
    '{date}' AS dtRef,
    t1.*,
    t2.frequenciaDiasD21,
    t2.frequenciaDiasD14,
    t2.frequenciaDiasD7,
    t3.tempoEmLive,
    t4.avgTempoLive,
    t4.totalTempoLive,
    t4.minTempoLive,
    t4.maxTempoLive,
    t5.qtdTransactionsVida,
    t5.avgTransPorDia

FROM tb_transactions t1

JOIN tb_freq t2
ON t1.IdCustomer = t2.IdCustomer

JOIN tb_tempo_live t3
ON t2.IdCustomer = t3.IdCustomer

JOIN tb_summary_tempo_live t4
ON t3.IdCustomer = t4.IdCustomer

JOIN tb_vida t5
ON t4.idCustomer = t5.IdCustomer
