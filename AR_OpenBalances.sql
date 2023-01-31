UPDATE AR_OpenBalances SET Company = 'IMC' WHERE Company IS Null

UPDATE AR_OpenBalances SET RmdTypal = CASE WHEN DebitAmt < 0 THEN 7 ELSE 1 END WHERE Company = 'IMC'

