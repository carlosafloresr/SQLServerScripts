USE AIS
GO

DECLARE	@DateIni	Date = '05/01/2018',
		@DateEnd	Date = '05/01/2019'

SELECT	HDR.VendorId,
		VND.VENDNAME,
		VMA.Division,
		CAST(VMA.HireDate AS Date) AS HireDate,
		HDR.DocType,
		CAST(HDR.DocDate AS Date) AS DocDate,
		CAST(HDR.PstgDate AS Date) AS PstgDate,
		HDR.DocNumbr,
		CAST(HDR.DocAmnt AS Numeric(10,2)) AS Amount,
		CAST(HDR.TEN99AMNT AS Numeric(10,2)) AS Ten99,
		HDR.TrxDscrn,
		HDR.BachNumb
FROM	PM20000 HDR
		INNER JOIN PM00200 VND ON HDR.VENDORID = VND.VENDORID AND VND.VNDCLSID = 'DRV'
		LEFT JOIN GPCustom.dbo.VendorMaster VMA ON HDR.VENDORID = VMA.VendorId AND VMA.Company = DB_NAME()
WHERE	PSTGDATE BETWEEN @DateIni AND @DateEnd
		AND HDR.VOIDED = 0
		AND HDR.DocAmnt > 0
UNION
SELECT	HDR.VendorId,
		VND.VENDNAME,
		VMA.Division,
		CAST(VMA.HireDate AS Date) AS HireDate,
		HDR.DocType,
		CAST(HDR.DocDate AS Date) AS DocDate,
		CAST(HDR.PstgDate AS Date) AS PstgDate,
		HDR.DocNumbr,
		CAST(HDR.DocAmnt AS Numeric(10,2)) AS Amount,
		CAST(HDR.TEN99AMNT AS Numeric(10,2)) AS Ten99,
		HDR.TrxDscrn,
		HDR.BachNumb
FROM	PM30200 HDR
		INNER JOIN PM00200 VND ON HDR.VENDORID = VND.VENDORID AND VND.VNDCLSID = 'DRV'
		LEFT JOIN GPCustom.dbo.VendorMaster VMA ON HDR.VENDORID = VMA.VendorId AND VMA.Company = DB_NAME()
WHERE	PSTGDATE BETWEEN @DateIni AND @DateEnd
		AND HDR.VOIDED = 0
		AND HDR.DocAmnt > 0