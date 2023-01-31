UPDATE	IMC.dbo.RM00101
SET		RM00101.Zip = LEFT(CM.ZipCode, 10)
FROM	IMCCustomers CM
WHERE	RM00101.CustNmbr = CM.CustNmbr


SELECT * FROM IMC.dbo.RM00101 ORDER BY CustNmbr
SELECT * FROM IMCCustomers ORDER BY CustNmbr

UPDATE	IMC.dbo.RM00101
SET		CustName	= CM.CustName,
		StmtName	= CM.CustName,
		Address1	= CM.Address1,
		Address2	= CM.Address2,
		City		= CM.City,
		State		= CM.State,
		Phone1		= ISNULL(CM.PhNumbr1, RM00101.Phone1),
		CntCprsn	= CM.CntCprsn
FROM	IMCCustomers CM
WHERE	RM00101.CustNmbr = CM.CustNmbr