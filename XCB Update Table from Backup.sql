SELECT	TOP 100 *
FROM	GP_XCB_Prepaid
where	ProNumber  = ''

SELECT	top 100 *
FROM	glso..GP_XCB_Prepaid_Backup
where	journalno = 2510255

UPDATE	GP_XCB_Prepaid
SET		GP_XCB_Prepaid.SWSVendor		= bkp.SWSVendor,
		GP_XCB_Prepaid.SWSVndName		= bkp.SWSVndName,
		GP_XCB_Prepaid.SWSVndInvoice	= bkp.SWSVndInvoice,
		GP_XCB_Prepaid.SWSVndCost		= bkp.SWSVndCost,
		GP_XCB_Prepaid.SWSPayType		= bkp.SWSPayType,
		GP_XCB_Prepaid.SWSManifestDate	= bkp.SWSManifestDate,
		GP_XCB_Prepaid.SWSStatus		= bkp.SWSStatus,
		GP_XCB_Prepaid.Matched			= bkp.Matched,
		GP_XCB_Prepaid.ProNumber		= bkp.ProNumber
FROM	GP_XCB_Prepaid_Backup BKP
WHERE	GP_XCB_Prepaid.journalno = BKP.journalno
		AND BKP.SWSManifestDate IS NOT Null

UPDATE	GP_XCB_Prepaid
SET		GP_XCB_Prepaid.ProNumber = BKP.ProNumber
FROM	GP_XCB_Prepaid_Backup BKP
WHERE	GP_XCB_Prepaid.journalno = BKP.journalno
		AND GP_XCB_Prepaid.Reference = BKP.Reference
		AND GP_XCB_Prepaid.ProNumber = ''
		AND BKP.ProNumber <> ''
