DECLARE	@Company	Varchar(5) = 'NDS',
		@BatchId	Varchar(20) = 'AGST-20181110',
		@Voucher	Varchar(25),
		@Account	Varchar(15),
		@VendorId	Varchar(15),
		@Document	Varchar(30),
		@Amount		Numeric(10,2),
		@PopUp		Int

SET NOCOUNT ON

SELECT	IAP.VCHNUMWK,
		IAP.ACTNUMST,
		IAP.VENDORID,
		IAP.DOCNUMBR,
		IAP.DOCAMNT,
		IAP.POPUPID
INTO	#tmpIntegration
FROM	IntegrationsDB.Integrations.dbo.Integrations_AP IAP
		INNER JOIN DEX_ET_PopUps POP ON IAP.POPUPID = POP.DEX_ET_PopUpsId
WHERE	IAP.Company = @Company
		AND IAP.BatchId = @BatchId
		AND IAP.PopUpId > 0
		AND IAP.DOCAMNT <> 0

DECLARE EscrowRecords CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	*
FROM	#tmpIntegration
WHERE	DOCNUMBR NOT IN (SELECT	InvoiceNumber
						FROM	EscrowTransactions
						WHERE	CompanyId = @Company
								AND BatchId = @BatchId
								AND Amount <> 0)

OPEN EscrowRecords 
FETCH FROM EscrowRecords INTO @Voucher, @Account, @VendorId, @Document, @Amount, @PopUp

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT @Voucher
	EXECUTE dbo.USP_PopUp_DataInsert @PopUp, 1, @Voucher, 16384, @BatchId

	FETCH FROM EscrowRecords INTO @Voucher, @Account, @VendorId, @Document, @Amount, @PopUp
END

CLOSE EscrowRecords
DEALLOCATE EscrowRecords

DROP TABLE #tmpIntegration