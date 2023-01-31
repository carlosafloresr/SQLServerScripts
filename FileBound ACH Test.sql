SELECT	*
FROM	[GPCustom].[dbo].[GP_EFT_Vendors]
WHERE	Company in ('GLSO','OIS','PDS')
		and VENDORID IN ('2972','100','1001')
ORDER BY DataDate DESC

SELECT	*
FROM	SY06000
WHERE	VENDORID IN ('2972','100','1001')

/*
INSERT INTO [GPCustom].dbo.GP_EFT_Vendors (FileId, Company, VendorId)
VALUES (2272375, 'AIS', 100)

UPDATE	GPCustom.dbo.GP_EFT_Vendors
SET		EFTPrenoteDate = '05/28/2025',
		Changed	 = 1
WHERE	Company = 'ais'
		AND VendorId = '100'

UPDATE	GLSO.dbo.SY06000
SET		EFTPrenoteDate = '05/29/2021'
WHERE	VENDORID = '2972'

INSERT INTO [GPCustom].dbo.GP_EFT_Vendors (FileId, Company, VendorId)
VALUES (2272376, 'AIS', '100')

UPDATE	AIS.dbo.SY06000
SET		EFTAccountType = 1,
		EFTBankAcct = '77788888',
		EFTBankType = 31,
		EFTTransitRoutingNo = '084000010',
		EFTTransferMethod = 1,
		INACTIVE = 0,
		EFTPrenoteDate = '01/01/1900'
WHERE	VENDORID = '100'

INSERT INTO AIS.dbo.SY06000 (CustomerVendor_ID,ADRSCODE,EFTAccountType,EFTBankAcct,EFTBankType,EFTTransitRoutingNo,EFTTransferMethod,INACTIVE,EFTPrenoteDate,VENDORID)
VALUES ('1000','MAIN',1,'77788889',31,'084000011',1,0,'01/01/1900','1000')

SELECT * FROM PM00200 WHERE VENDORID NOT IN (SELECT VENDORID FROM SY06000) AND VENDSTTS = 1
*/