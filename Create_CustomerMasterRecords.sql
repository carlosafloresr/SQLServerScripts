-- SELECT * FROM DNJ.dbo.RM00101
-- SELECT * FROM CustomerMaster WHERE CompanyiD = 'DNJ'
-- UPDATE CustomerMaster SET CustName='', Changed = 1, Trasmitted = 0 WHERE CompanyiD = 'DNJ'
-- EXECUTE USP_CustomerMaster_VerifyChanges 'DNJ'

INSERT INTO CustomerMaster (
		CompanyiD,
		CustNmbr,
		CustName,
		CustClas,
		Address1,
		Address2,
		City,
		State,
		Zip,
		Phone1,
		Inactive,
		Hold,
		CntCprsn,
		Changed,
		Trasmitted,
		ChangedBy)
SELECT	'GLSO' AS CompanyiD,
		CustNmbr,
		CustName,
		CustClas,
		Address1,
		Address2,
		City,
		State,
		Zip,
		Phone1,
		Inactive,
		Hold,
		CntCprsn,
		CAST(1 AS Bit) AS Changed,
		CAST(0 AS Bit) AS Trasmitted,
		CAST('CFLORES' AS Varchar(25)) AS ChangedBy
FROM 	GLSO.dbo.RM00101
WHERE	CUSTNMBR IN ('26324','25104P')
ORDER BY CustNmbr

--UPDATE RM00101 SET Address1 = REPLACE(Address1, '  ', ' ')