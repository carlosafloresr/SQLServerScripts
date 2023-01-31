SELECT	DISTINCT RM.CustNmbr,
		CM.CustName,
		CM.BillType
FROM	RM20101 RM
		INNER JOIN GPCustom.dbo.CustomerMaster CM ON RM.CustNmbr = CM.CustNmbr AND CM.CompanyId = 'IMC'
WHERE	YEAR(RM.DocDate) = 2012
		AND CM.BillType = 0

--select * from GPCustom.dbo.CustomerMaster