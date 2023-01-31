-- SELECT * FROM RM20101 WHERE CustNmbr IN (SELECT RCCLAccount FROM GPCustom.dbo.VendorMaster)

SELECT	CustNmbr
		,DocNumbr
		,DocDate
		,GLPostDt
		,OrTrxAmt
FROM	RM20101 
WHERE	CustNmbr IN (SELECT RCCLAccount FROM GPCustom.dbo.VendorMaster)
UNION
SELECT	CustNmbr
		,DocNumbr
		,DocDate
		,GLPostDt
		,OrTrxAmt
FROM	RM30101 
WHERE	CustNmbr IN (SELECT RCCLAccount FROM GPCustom.dbo.VendorMaster)
ORDER BY
		CustNmbr
		,DocDate