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
		PHONE1,
		INACTIVE)
SELECT	LEFT(RTRIM(Code), 10),
		LEFT(RTRIM(Name), 64),
		Class,
		'MAIN',
		ADDRESS1,
		ADDRESS2,
		CITY,
		STATE,
		ISNULL(ZipCode, ''),
		REPLACE(PHONE, '-', ''),
		0
FROM	[GPCustom].[dbo].[pst_customers]
WHERE	Code NOT IN (SELECT CustNmbr FROM RM00101)
		AND [Name] <> ''
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
	WHERE	CUSTNMBR IN (SELECT RTRIM(Code) FROM GPCustom.dbo.pst_customers)
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
	WHERE	CUSTNMBR IN (SELECT RTRIM(Code) FROM GPCustom.dbo.pst_customers)
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