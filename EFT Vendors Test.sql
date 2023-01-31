SELECT	*
FROM	GPCustom.dbo.GP_EFT_Vendors
WHERE	Company = 'AIS'

UPDATE	GPCustom.dbo.GP_EFT_Vendors
SET		EFTPrenoteDate = '12/05/2020', 
		Changed = 1 
WHERE	FileId in (2261246,2261502,2261503,2261504)
--GP_EFT_VendorId = 7
--Company = 'AIS'