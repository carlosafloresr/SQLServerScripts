/*
SELECT	CustNmbr,
		COUNT(Inv_No) AS Counter
FROM	(
*/
SELECT	REPLACE(DocNumbr, 'I', '') AS Inv_No
FROM	RM20101
WHERE	LEFT(DocNumbr, 1) = 'I'
		AND CustNmbr IN ('DALHAN','SATHAN','DALHAP','HOUFFF','SLCMOW','19050','DALINA','ALLMAE','ACHMAE','ALLMSW','DALMAE','DENMSK','ELPMAE','ELPMSK','FTWMAE','HOUMAE','HOUMBT','HOUMKN','HOUMSK','SATMSK')
/*		
		) RECS
GROUP BY CustNmbr
*/
--SELECT DocNumbr FROM RM20101 WHERE LEFT(DocNumbr, 1) = 'I' AND CustNmbr = 'HOUGCP'
/*
select top 150 *  from invoices where acct_no = 'dalhan'	
SELECT TOP 150 Inv_No, Inv_Date, Acct_No, Inv_Total, Inv_Mech, Container, Chassis, Genset_No FROM INVOICES WHERE ACCT_NO = 'DALHAN' ORDER BY INV_DATE DESC

SELECT CustNmbr, CustName FROM FI.dbo.RM00101 WHERE CustNmbr IN (SELECT CustomerId FROM GPCustom.dbo.SummaryCustomers WHERE Company = 'FI')

SELECT CustName FROM FI.dbo.RM00101 WHERE CustNmbr = 'SLCMOW'

*/