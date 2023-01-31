/*
SELECT	*
FROM	VendorCheckDocument
WHERE	Company = 'AIS'
*/

DECLARE	@Company Varchar(5)
SET	@Company = 'RCCL'

INSERT INTO VendorCheckDocument
SELECT	@Company AS Company,
		VENDORID,
		3 AS CheckDocOption,
		999.99 AS InvoiceAmount
FROM	RCCL.dbo.PM00200
WHERE	VNDCLSID <> 'DRV'
		AND VENDSTTS = 1
		AND VENDORID NOT IN (
							SELECT	VendorID
							FROM	VendorCheckDocument
							WHERE	Company = @Company
							)