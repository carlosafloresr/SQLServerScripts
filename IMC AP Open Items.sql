-- SELECT * FROM IMCT.dbo.PM00400 WHERE LEFT(DocNumbr, 4) = 'FLYJ' ORDER BY DocNumbr

DECLARE @DocNumbr	Char(22)
SET		@DocNumbr = 'A_112801R_1'
SELECT DocNumbr FROM IMCT.dbo.PM00400 WHERE DocNumbr = @DocNumbr UNION SELECT DocNumbr FROM IMCT.dbo.PM10000 WHERE DocNumbr = @DocNumbr

SELECT * FROM AP_OpenBalances WHERE Company = 'IMCT' order by vendorid and vendorid = 'WEYC' ORDER BY DocDate
UPDATE AP_OpenBalances SET VENDORID = 'WEYCO' WHERE vendorid = 'WEYC'

SELECT * FROM AP_OpenBalances WHERE vendorid not in (SELECT vendorid FROM IMCT.dbo.PM00200)

select * from ais.dbo.RM50104