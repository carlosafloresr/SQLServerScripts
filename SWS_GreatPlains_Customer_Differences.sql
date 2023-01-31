/*
SELECT	*
FROM	GP_IMC_Customers
*/

SELECT	RM.CustNmbr,
		RM.CustName,
		GP.CustomerName
FROM	IMC.dbo.RM00101 RM
		INNER JOIN SWS_CustomerMaster GP ON RM.CustNmbr = GP.CustomerNumber
WHERE	LEFT(RTRIM(RM.CustName), 10) <> LEFT(RTRIM(GP.CustomerName), 10)
ORDER BY
		RM.CustNmbr

--UPDATE SWS_CustomerMaster SET CustomerName = REPLACE(CustomerName, '"', '')