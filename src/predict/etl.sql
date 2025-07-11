SELECT 
    t1.dtRef,
    t1.idCustomer,
    t1.recenciaDias,
    t1.frequenciaDias,
    t1.valorPoints,
    t1.idadeBaseDias,
    t1.flEmail,
    t3.qtdePointsManha,
    t3.qtdePointsTarde,
    t3.qtdePointsNoite,
    t3.pctPointsManha,
    t3.pctPointsTarde,
    t3.pctPointsNoite,
    t3.qtdTransactionsManha,
    t3.qtdTransactionsTarde,
    t3.qtdTransactionsNoite,
    t3.pctTransactionsManha,
    t3.pctTransactionsTarde,
    t3.pctTransactionsNoite,
    t4.saldoPointsD21,
    t4.pointsAcumuladosD21,
    t4.pointsAcumuladosD14,
    t4.pointsAcumuladosD7,
    t4.pointsResgatadosD21,
    t4.pointsResgatadosD14,
    t4.pointsResgatadosD7,
    t4.pointsAcumuladosVida,
    t4.pointsResgatadosVida,
    t4.pointsPorDia,
    t5.frequenciaDiasD21,
    t5.frequenciaDiasD14,
    t5.frequenciaDiasD7,
    t5.avgTempoLive,
    t5.totalTempoLive,
    t5.minTempoLive,
    t5.maxTempoLive,
    t5.qtdTransactionsVida,
    t5.avgTransPorDia,
    t6.qtdeResgatarPonei,
    t6.qtdeChatMessage,
    t6.qtdeListaPresença,
    t6.qtdeAirflowLover,
    t6.qtdeRLover,
    t6.qtdePresençaStreak,
    t6.qtdeTrocaPontosStreamElements,
    t6.pointsResgatarPonei,
    t6.pointsChatMessage,
    t6.pointsListaPresença,
    t6.pointsAirflowLover,
    t6.pointsRLover,
    t6.pointsPresençaStreak,
    t6.pointsTrocaPontosStreamElements,
    t6.pctResgatarPonei,
    t6.pctChatMessage,
    t6.pctListaPresença,
    t6.pctAirflowLover,
    t6.pctRLover,
    t6.pctPresençaStreak,
    t6.pctTrocaPontosStreamElements,
    t6.avgChatLive,
    t6.NameProduct

FROM fs_general t1

LEFT JOIN fs_horario t3
ON t1.idCustomer = t3.idCustomer
AND t1.dtRef = t3.dtRef

LEFT JOIN fs_points t4
ON t1.idCustomer = t4.idCustomer
AND t1.dtRef = t4.dtRef

LEFT JOIN fs_transacoes t5
ON t1.idCustomer = t5.idCustomer
AND t1.dtRef = t5.dtRef

LEFT JOIN fs_produtos t6
ON t1.idCustomer = t6.idCustomer
AND t1.dtRef = t6.dtRef

WHERE t1.dtRef = (SELECT MAX(dtRef) FROM fs_general)