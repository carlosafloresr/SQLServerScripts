UPDATE AR_OpenBalances SET Company = 'IMC', RmdTypal = CASE WHEN DocAmt < 0 THEN 7 ELSE 1 END --, ACTNUMST2 = '1-00-4010'

UPDATE AR_OpenBalances SET CstPONbr = '', CustNmbr = 'PD' + LTRIM(RTRIM(CustNmbr)), Company = 'IMC', RmdTypal = CASE WHEN DocAmt < 0 THEN 7 ELSE 1 END WHERE BACHNUMB = 'PD_OpenItems'
UPDATE AR_OpenBalances SET RmdTypal = CASE WHEN DocAmt < 0 THEN 7 ELSE 1 END, CustNmbr = 'IC' + LTRIM(RTRIM(CustNmbr)) WHERE BACHNUMB = 'DEP_OpenItems'

SELECT * FROM AR_OpenBalances WHERE BACHNUMB = 'DEP_OpenItems'

DELETE AR_OpenBalances WHERE DOCNUMBR = 'DOCNUMBR'