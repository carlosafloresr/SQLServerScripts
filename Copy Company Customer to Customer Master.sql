-- SELECT * FROM IMCT.dbo.RM00101 ORDER BY CUSTNMBR
INSERT INTO GPCustom.dbo.CustomerMaster
	   (CompanyId,
	    CUSTNMBR,
		INACTIVE,
		CUSTNAME,
		CUSTCLAS,
		CNTCPRSN,
		ADDRESS1,
		ADDRESS2,
		Hold,
		CITY,
		STATE,
		ZIP,
		PHONE1)
SELECT	DB_NAME() AS CompanyId,
		CUSTNMBR,
		INACTIVE,
		CUSTNAME,
		CUSTCLAS,
		CNTCPRSN,
		ADDRESS1,
		ADDRESS2,
		Hold,
		CITY,
		STATE,
		ZIP,
		PHONE1
FROM	RM00101
WHERE	CUSTNMBR NOT IN (SELECT CustNmbr FROM GPCustom.dbo.CustomerMaster WHERE CompanyId = DB_NAME())
ORDER BY CUSTNMBR

/*
UPDATE	IMC.dbo.RM00101 
SET		StmtName = CustName,
		AdrsCode = 'MAIN',
		Kpdsthst = 1,
		Kpcalhst = 1,
		Kperhist = 1,
		Kptrxhst = 1,
		Crlmttyp = 1,
		Revalue_Customer = 1,
		OrderFulFillDefault = 1

INSERT INTO IMC.dbo.RM00102
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
FROM	IMC.dbo.RM00101
WHERE	CustNmbr NOT IN (SELECT CustNmbr FROM IMC.dbo.RM00102)
*/

/*
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