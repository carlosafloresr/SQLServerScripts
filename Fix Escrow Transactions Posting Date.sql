-- select TOP 10 * from PM20000 where VCHRNMBR = 'MC_04082019_006'
/*
UPDATE	GPCustom.DBO.EscrowTransactions
SET		PostingDate = '04/08/2019'
WHERE	VoucherNumber LIKE 'MC_04082019_%'
*/
DECLARE	@tblData Table (
		VCHRNMBR		Varchar(25),
		PSTGDATE		Date,
		VendorNumber	Varchar(15),
		DriverId		Varchar(15),
		BACHNUMB		Varchar(85),
		DOCNUMBR		Varchar(30))

INSERT INTO @tblData
SELECT	AP.VCHRNMBR,
		AP.PSTGDATE,
		AP.VENDORID AS VendorNumber,
		DI.DriverId,
		AP.BACHNUMB,
		RTRIM(AP.DOCNUMBR) AS DOCNUMBR
FROM	PM20000 AP
		INNER JOIN GPCustom.dbo.EscrowTransactions DI ON AP.BACHNUMB = DI.BatchId AND AP.VCHRNMBR = DI.VoucherNumber AND DI.CompanyId = DB_NAME()
WHERE	AP.PSTGDATE <> DI.PostingDate

--SELECT	AP.VCHRNMBR,
--		AP.PSTGDATE,
--		AP.VENDORID AS VendorNumber,
--		DI.DriverId,
--		AP.BACHNUMB,
--		RTRIM(AP.DOCNUMBR) AS DOCNUMBR
--FROM	PM20000 AP
--		INNER JOIN IntegrationsDb.Integrations.dbo.Integrations_AP DI ON AP.BACHNUMB = DI.BatchId AND AP.VCHRNMBR = DI.VCHNUMWK AND DI.Company = DB_NAME() AND DI.PopUpId > 0
--WHERE	AP.VCHRNMBR LIKE 'MC_04152019%'
--		AND DI.DriverId IS NOT Null

UPDATE	GPCustom.dbo.EscrowTransactions
SET		PostingDate = DATA.PSTGDATE
		--,VendorId	= DATA.DriverId
FROM	@tblData DATA
WHERE	EscrowTransactions.VoucherNumber = DATA.VCHRNMBR
		AND EscrowTransactions.BatchId = DATA.BACHNUMB
		--AND EscrowTransactions.PostingDate IS Null
		AND EscrowTransactions.CompanyId = DB_NAME()