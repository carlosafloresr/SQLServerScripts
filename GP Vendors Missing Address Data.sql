SELECT	APV.VENDORID,
		APV.VENDNAME,
		APV.PYMNTPRI,
		ISNULL(GPV.Override, 0) AS Override,
		APV.CITY,
		APV.STATE,
		APV.ZIPCODE
FROM	AIS.dbo.PM00200 APV
		LEFT JOIN GPCustom.dbo.GPVendorMaster GPV ON APV.VENDORID = GPV.VENDORID AND GPV.Company = 'AIS'
--WHERE	APV.PYMNTPRI NOT IN ('CHK','EFT')
WHERE	APV.CITY = '' OR APV.STATE = ''
ORDER BY 1