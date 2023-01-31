DECLARE	@WeekEndIni	Date, --= GPCustom.dbo.DayFwdBack(GETDATE(), 'P', 'Saturday'),
		@WeekEndEnd	Date, --= GPCustom.dbo.DayFwdBack(GETDATE(), 'N', 'Saturday'),
		@BatchId	Varchar(25),
		@Company	Varchar(5),
		@ForProcess	Bit = 0

SET NOCOUNT ON

SET @WeekEndEnd = '05/30/2020'
SET @WeekEndIni = DATEADD(dd, -6, @WeekEndEnd)

PRINT @WeekEndIni
PRINT @WeekEndEnd

DECLARE @tblData	Table (
		Company		Varchar(5), 
		BatchId		Varchar(25),
		VendorId	Varchar(15),
		Amount		Numeric(10,2),
		Equipment	Varchar(15),
		VoucherId	Varchar(20),
		TrxDscrn	Varchar(50),
		VndDocument	Varchar(50),
		InvoiceNum	Varchar(20),
		RecordId	Int,
		GPVendorId	Varchar(15))

INSERT INTO @tblData
SELECT	FSI.Company, 
		FSI.BatchId,
		FSI.RecordCode,
		FSI.ChargeAmount1,
		FSI.Equipment,
		FSI.VoucherId,
		FSI.TrxDscrn,
		FSI.VendorDocument,
		FSI.InvoiceNumber,
		FSI.FSI_ReceivedSubDetailId,
		GPV.VendorId
FROM	IntegrationsDb.Integrations.dbo.View_Integration_FSI_Vendors FSI
		LEFT JOIN GPCustom.dbo.GPVendorMaster GPV ON FSI.RecordCode = ISNULL(GPV.SWSVendorId, GPV.VendorId) AND FSI.Company = GPV.Company
WHERE	FSI.Company = DB_NAME()
		AND FSI.VndIntercompany = 0
		AND FSI.WeekEndDate IN (@WeekEndIni, @WeekEndEnd)

SELECT	DAT.*
INTO	#tmpImvoices
FROM	@tblData DAT
		LEFT JOIN PM00400 APM ON DAT.GPVendorId = APM.VendorId AND (DAT.VoucherId = APM.CNTRLNUM OR DAT.VndDocument = APM.DOCNUMBR)
WHERE	APM.CNTRLNUM IS Null

-- select * from @tblData ORDER BY InvoiceNum

IF @ForProcess = 1
BEGIN
	UPDATE	IntegrationsDb.Integrations.dbo.FSI_ReceivedSubDetails
	SET		Processed = 0
	WHERE	RecordType = 'VND'
			AND FSI_ReceivedSubDetailId IN (SELECT RecordId FROM #tmpImvoices)

	PRINT	'DELETE PAYABLES RECORDS PREVIOUSLY PROCESSED'
	DELETE	IntegrationsDb.Integrations.dbo.FSI_PayablesRecords
	WHERE	RecordId IN (SELECT RecordId FROM #tmpImvoices)

	DECLARE curFSIBatches CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT	DISTINCT Company, BatchId
	FROM	#tmpImvoices

	OPEN curFSIBatches 
	FETCH FROM curFSIBatches INTO @Company, @BatchId

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		IF EXISTS(SELECT BatchId FROM IntegrationsDb.Integrations.dbo.ReceivedIntegrations WHERE Integration = 'FSIP' AND BatchId = @BatchId AND Company = @Company)
		BEGIN
			UPDATE	IntegrationsDb.Integrations.dbo.ReceivedIntegrations 
			SET		Status = 0,
					GPServer = 'PRISQL01P'
			WHERE	Integration = 'FSIP' 
					AND BatchId = @BatchId 
					AND Company = @Company
		END
		ELSE
		BEGIN
			INSERT INTO IntegrationsDb.Integrations.dbo.ReceivedIntegrations 
					(Integration, Company, BatchId, GPServer) 
			VALUES 
					('FSIP', @Company, @BatchId, 'PRISQL01P')
		END

		PRINT 'RECEIVED INTEGRATIONS: Company: ' + @Company + ' / Batch: ' + @BatchId

		FETCH FROM curFSIBatches INTO @Company, @BatchId
	END

	CLOSE curFSIBatches
	DEALLOCATE curFSIBatches
END
ELSE
	SELECT * FROM #tmpImvoices

DROP TABLE #tmpImvoices

/*
SELECT	*
FROM	PM00400
WHERE	CNTRLNUM IN (SELECT VoucherId FROM @tblData)

SELECT	* 
FROM	IntegrationsDb.Integrations.dbo.View_Integration_FSI_Vendors 
WHERE	Company = 'IMC'
		AND WeekEndDate = '01/26/2019'
*/