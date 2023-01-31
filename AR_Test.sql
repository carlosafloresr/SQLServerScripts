--SELECT DISTINCT CustNmbr FROM AR_OpenBalances WHERE CustNmbr NOT IN (SELECT CustNmbr FROM IMC.dbo.RM00101)

SELECT * FROM AR_OpenBalances WHERE BachNumb = 'IMC_OpenItems' ORDER BY DocNumbr
SELECT SUM(abs(DocAmt)) FROM AR_OpenBalances WHERE BachNumb = 'IMC_OpenItems'
-- delete AR_OpenBalances WHERE BachNumb = 'IMC_OpenItems'
-- select min(docdate) from AR_OpenBalances

UPDATE AR_OpenBalances SET ActNumSt2 = '1-00-4010', BachNumb = 'IMC_OpenItems', Company = 'IMC', RmdTypal = CASE WHEN DocAmt < 0 THEN 7 ELSE 1 END WHERE BachNumb = 'IMC_OpenItems'

select * from Dynamics.dbo.SY00801

delete Dynamics.dbo.SY00800 where userid = 'cflores'