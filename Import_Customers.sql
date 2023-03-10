/*
SELECT * FROM IMC.dbo.RM00101 WHERE LEFT(CUSTNMBR,2) = 'PD' ORDER BY CUSTNMBR

DELETE	GPCustom.dbo.IMCCustomers
WHERE	CUSTNMBR IN (SELECT * FROM IMC.dbo.RM00101)

SELECT * FROM GPCustom.dbo.NDS_Customers WHERE CUSTNMBR IN (SELECT CustNmbr FROM RM00101)
SELECT * FROM RM00101
*/

BEGIN TRANSACTION

INSERT INTO RM00101
	   (CUSTNMBR,
		CUSTNAME, 
		CUSTCLAS,
		AdrsCode,
		ADDRESS1,
		ADDRESS2,
		CITY,
		STATE,
		ZIP,
		CNTCPRSN,
		PHONE1,
		PHONE2,
		FAX,
		--SALSTERR,
		PYMTRMID,
		INACTIVE)
SELECT	LEFT(CUSTNMBR, 10),
		LEFT(CUSTNAME, 64),
		CUSTCLAS,
		'MAIN',
		ADDRESS1,
		ADDRESS2,
		CITY,
		STATE,
		ISNULL(ZIP, ''),
		ISNULL(CNTCPRSN, ''),
		REPLACE(PHONE1, '-', ''),
		REPLACE(PHONE2, '-', ''),
		ISNULL(REPLACE(FAX, '-', ''),''),
		--SALSTERR,
		PYMTRMID,
		0
FROM	[GPCustom].[dbo].[DD Jones AIS]
WHERE	CUSTNMBR NOT IN (SELECT CustNmbr FROM RM00101)
		AND CUSTNMBR <> ''
ORDER BY 1

IF @@ERROR = 0
BEGIN
	UPDATE	RM00101
	SET		StmtName = CustName,
			Kpdsthst = 1,
			Kpcalhst = 1,
			Kperhist = 1,
			Kptrxhst = 1,
			Crlmttyp = 1,
			Revalue_Customer = 1,
			OrderFulFillDefault = 1
	WHERE	CUSTNMBR IN (SELECT RTRIM([customer id]) FROM GPCustom.dbo.ExpressAmerica_Customer_List)
END

IF @@ERROR = 0
BEGIN
	INSERT INTO dbo.RM00102
		   (CustNmbr,
			AdrsCode,
			CntcPrsn,
			Address1,
			Address2,
			Address3,
			Country,
			City,
			State,
			Zip,
			Phone1,
			Phone2,
			Phone3,
			Fax)
	SELECT	CustNmbr,
			AdrsCode,
			CntcPrsn,
			Address1,
			Address2,
			Address3,
			Country,
			City,
			State,
			Zip,
			Phone1,
			Phone2,
			Phone3,
			Fax
	FROM	dbo.RM00101
	WHERE	CUSTNMBR IN (SELECT CustNmbr FROM [GPCustom].[dbo].[DD Jones AIS])
END

IF @@ERROR = 0
	COMMIT TRANSACTION
ELSE
	ROLLBACK TRANSACTION

/*
SELECT	CUSTNMBR
FROM	dbo.RM00101

SELECT	IMCCustomers.CUSTNMBR
FROM	IMCCustomers
		INNER JOIN (
SELECT	CUSTNMBR,
		COUNT(CUSTNMBR) AS Counter
FROM	GPCustom.dbo.IMCCustomers
WHERE	CUSTNMBR NOT IN (SELECT CustNmbr FROM IMCT.dbo.RM00102)
GROUP BY CUSTNMBR
HAVING COUNT(CUSTNMBR) > 1) CNT ON IMCCustomers.CUSTNMBR = CNT.CUSTNMBR

TRUNCATE TABLE GPCustom.dbo.IMCCustomers
*/

-- DELETE GPCustom.dbo.IMCCustomers WHERE NOT CUSTNMBR IN (SELECT CustNmbr FROM IMCT.dbo.RM00102)