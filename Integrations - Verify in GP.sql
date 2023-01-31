SET NOCOUNT ON

DECLARE	@Company		Varchar(5),
		@BatchId		Varchar(30),
		@Integration	Varchar(12),
		@Query			Varchar(MAX)

DECLARE	@tblBatches		Table (
		Company			Varchar(5),
		BatchId			Varchar(30),
		Integration		Varchar(12))

DECLARE	@tblMissing		Table (
		Company			Varchar(5),
		BatchId			Varchar(30),
		Integration		Varchar(12),
		CustVnd			Varchar(15),
		Inv_Ref			Varchar(30),
		Total			Numeric(10,2))

DECLARE	@tblSales		Table (
		Company			Varchar(5),
		BatchId			Varchar(30),
		Customer		Varchar(15),
		Invoice			Varchar(30),
		InvoiceType		Char(1),
		Total			Numeric(10,2),
		Missing			Bit)

DECLARE	@tblPayables	Table (
		Company			Varchar(5),
		BatchId			Varchar(30),
		RecordId		Int,
		Invoice			Varchar(30),
		Vendor			Varchar(12),
		Amount			Numeric(10,2),
		Document		Varchar(30),
		Missing			Bit)

DECLARE	@tblTIP			Table (
		Company			Varchar(5),
		BatchId			Varchar(30),
		Customer		Varchar(15),
		Reference		Varchar(30),
		RecordType		Char(1),
		Total			Numeric(10,2),
		Missing			Bit)

DECLARE	@tblFSIG		Table (
		Company			Varchar(5),
		BatchId			Varchar(30),
		Customer		Varchar(15),
		Reference		Varchar(30),
		RecordType		Char(1),
		Total			Numeric(10,2),
		Missing			Bit)

DECLARE curBatches CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	Company,
		BatchId
FROM	IntegrationsDB.Integrations.dbo.FSI_ReceivedHeader
WHERE	Verified = 0
		AND ReceivedOn BETWEEN DATEADD(dd, -30, CAST(GETDATE() AS Date)) AND CAST(GETDATE() AS Date)
		AND BatchId NOT LIKE '%_SUM'
		AND Company = 'PTS'
		--AND BatchId = '3FSI20191220_1620'
ORDER BY Company

OPEN curBatches 
FETCH FROM curBatches INTO @Company, @BatchId

WHILE @@FETCH_STATUS = 0 
BEGIN
	INSERT INTO @tblBatches
	SELECT	Company, BatchId, Integration
	FROM	IntegrationsDB.Integrations.dbo.ReceivedIntegrations
	WHERE	Company = @Company
			AND BatchId = @BatchId
			AND Integration = 'FSIP'

	FETCH FROM curBatches INTO @Company, @BatchId
END

CLOSE curBatches
DEALLOCATE curBatches

DECLARE curBatches CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	*
FROM	@tblBatches

OPEN curBatches 
FETCH FROM curBatches INTO @Company, @BatchId, @Integration

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT 'Verifiying ' + @Company + ' ' + @BatchId + ' ' + @Integration

	IF @Integration = 'FSI'
	BEGIN
		INSERT INTO @tblSales
		SELECT	@Company,
				@BatchId,
				CustomerNumber, 
				InvoiceNumber,
				InvoiceType, 
				InvoiceTotal,
				0 AS Missing
		FROM	IntegrationsDB.Integrations.dbo.View_Integration_FSI
		WHERE	Company = @Company
				AND BatchId = @BatchId
				AND InvoiceTotal <> 0

		SELECT	*
		INTO	#tmpData
		FROM	@tblSales

		SET @Query = N'SELECT SAL.Customer AS CustomerNumber,
						SAL.Invoice AS InvoiceNumber,
						MST.DOCNUMBR
				INTO	##tmpResults
				FROM	#tmpData SAL
						LEFT JOIN ' + @Company + '.dbo.RM00401 MST ON SAL.Customer = MST.CUSTNMBR AND SAL.Invoice = MST.DOCNUMBR
				WHERE	SAL.Company = ''' + @Company + ''' 
						AND SAL.BatchId = ''' + @BatchId + ''''

		EXECUTE(@Query)

		UPDATE	@tblSales
		SET		Missing = 1
		FROM	(
				SELECT * FROM ##tmpResults
				) DAT
		WHERE	Customer = DAT.CustomerNumber
				AND Invoice = DAT.InvoiceNumber
				AND DOCNUMBR IS Null

		DROP TABLE #tmpData
		DROP TABLE ##tmpResults
	END

	IF @Integration = 'FSIP'
	BEGIN
		INSERT INTO @tblPayables
		SELECT	@Company,
				@BatchId,
				FSI_ReceivedSubDetailId,
				InvoiceNumber,
				RecordCode,
				ChargeAmount1,
				VendorDocument,
				0 AS Missing
		FROM	IntegrationsDB.Integrations.dbo.View_Integration_FSI_Vendors 
		WHERE	Company = @Company 
				AND BatchId = @BatchId 
				AND VndIntercompany = 0

		SELECT	*
		INTO	#tmpData2
		FROM	@tblPayables

		IF @@ROWCOUNT > 0
		BEGIN
			SET @Query = N'SELECT PAY.Vendor AS VendorId,
							PAY.Document AS DocumentNumber,
							MST.DOCNUMBR
					INTO	##tmpResults
					FROM	#tmpData2 PAY
							LEFT JOIN ' + @Company + '.dbo.PM00400 MST ON PAY.Vendor = MST.VENDORID AND (PAY.Document = MST.DOCNUMBR OR PAY.Invoice = MST.DOCNUMBR)
					WHERE	PAY.Company = ''' + @Company + ''' 
							AND PAY.BatchId = ''' + @BatchId + ''''

			EXECUTE(@Query)

			UPDATE	@tblPayables
			SET		Missing = 1
			FROM	(
					SELECT * FROM ##tmpResults
					) DAT
			WHERE	Vendor = DAT.VendorId
					AND Document = DAT.DocumentNumber
					AND DOCNUMBR IS Null
		END

		DROP TABLE #tmpData2
		DROP TABLE ##tmpResults
	END

	IF @Integration = 'TIP'
	BEGIN
		INSERT INTO @tblTIP
		SELECT	FSI.Company,
				FSI.FSIBatchId,
				FSI.BooksAccount,
				FSI.Description,
				FSI.LinkType,
				FSI.Amount,
				0 AS Missing
		FROM	IntegrationsDB.Integrations.dbo.View_FSI_Intercompany FSI
				LEFT JOIN IntegrationsDB.Integrations.dbo.TIP_IntegrationRecords TIP ON FSI.RecordId = TIP.TIPIntegrationId
				LEFT JOIN IntegrationsDB.Integrations.dbo.ReceivedIntegrations RCV ON FSI.OriginalBatchId = RCV.BatchId AND RCV.Integration = 'TIP'
		WHERE	FSI.FSIBatchId = @BatchId
		ORDER BY FSI.LinkType, FSI.Description

		SELECT	*
		INTO	#tmpData3
		FROM	@tblTIP

		SET @Query = N'SELECT *
					INTO	##tmpResults
					FROM (
					SELECT TIP.Customer AS CustomerId,
							TIP.Reference AS ReferenceNumber,
							GLO.REFRENCE
					FROM	#tmpData3 TIP
							INNER JOIN ' + @Company + '.dbo.GL20000 GLO ON TIP.Reference = GLO.REFRENCE
					WHERE	TIP.Company = ''' + @Company + ''' 
							AND TIP.BatchId = ''' + @BatchId + '''
					UNION
					SELECT TIP.Customer AS CustomerId,
							TIP.Reference AS ReferenceNumber,
							GLO.REFRENCE
					FROM	#tmpData3 TIP
							INNER JOIN ' + @Company + '.dbo.GL10000 GLO ON TIP.Reference = GLO.REFRENCE
					WHERE	TIP.Company = ''' + @Company + ''' 
							AND TIP.BatchId = ''' + @BatchId + ''') DATA'

		EXECUTE(@Query)
		
		UPDATE	@tblTIP
		SET		Missing = 1
		FROM	(
				SELECT * FROM ##tmpResults
				) DAT
		WHERE	Customer = DAT.CustomerId
				AND Reference = DAT.ReferenceNumber
				AND REFRENCE IS Null

		DROP TABLE #tmpData3
		DROP TABLE ##tmpResults
	END

	IF @Integration = 'FSIG'
	BEGIN
		INSERT INTO @tblFSIG
		SELECT	FSI.Company,
				FSI.BatchId,
				FSI.CustomerNumber,
				FSI.PrepayReference,
				'' AS LinkType,
				FSI.ChargeAmount1,
				0 AS Missing
		FROM	IntegrationsDB.Integrations.dbo.View_Integration_FSI_Full FSI
		WHERE	FSI.BatchId = @BatchId
				AND ((PrePay = 1 AND ISNULL(PrePayType, '') IN ('','P')) OR PrePayType = 'A' OR AR_PrePayType = 'A') 
				AND VndIntercompany = 0
		ORDER BY FSI.PrepayReference

		SELECT	*
		INTO	#tmpData4
		FROM	@tblFSIG

		SET @Query = N'SELECT *
					INTO	##tmpResults
					FROM (
					SELECT FSIG.Customer AS CustomerId,
							FSIG.Reference AS ReferenceNumber,
							GLO.REFRENCE
					FROM	#tmpData4 FSIG
							INNER JOIN ' + @Company + '.dbo.GL20000 GLO ON FSIG.Reference = GLO.REFRENCE
					WHERE	FSIG.Company = ''' + @Company + ''' 
							AND FSIG.BatchId = ''' + @BatchId + '''
					UNION
					SELECT FSIG.Customer AS CustomerId,
							FSIG.Reference AS ReferenceNumber,
							GLO.REFRENCE
					FROM	#tmpData4 FSIG
							INNER JOIN ' + @Company + '.dbo.GL10000 GLO ON FSIG.Reference = GLO.REFRENCE
					WHERE	FSIG.Company = ''' + @Company + ''' 
							AND FSIG.BatchId = ''' + @BatchId + ''') DATA'

		EXECUTE(@Query)
		
		UPDATE	@tblFSIG
		SET		Missing = 1
		FROM	(
				SELECT * FROM ##tmpResults
				) DAT
		WHERE	Customer = DAT.CustomerId
				AND Reference = DAT.ReferenceNumber
				AND REFRENCE IS Null

		DROP TABLE #tmpData4
		DROP TABLE ##tmpResults
	END

	FETCH FROM curBatches INTO @Company, @BatchId, @Integration
END

CLOSE curBatches
DEALLOCATE curBatches

INSERT INTO @tblMissing
SELECT	Company,
		BatchId,
		'FSI' AS Integration,
		Customer,
		Invoice,
		Total
FROM	@tblSales
WHERE	Missing = 1

INSERT INTO @tblMissing
SELECT	Company,
		BatchId,
		'FSIP' AS Integration,
		Vendor,
		Invoice,
		Amount
FROM	@tblPayables
WHERE	Missing = 1

INSERT INTO @tblMissing
SELECT	Company,
		BatchId,
		'TIP' AS Integration,
		Customer,
		Reference,
		Total
FROM	@tblTIP
WHERE	Missing = 1

INSERT INTO @tblMissing
SELECT	Company,
		BatchId,
		'FSIG' AS Integration,
		Customer,
		Reference,
		Total
FROM	@tblTIP
WHERE	Missing = 1

UPDATE	IntegrationsDB.Integrations.dbo.FSI_ReceivedHeader
SET		Verified = 1
WHERE	BatchId IN (SELECT batchId FROM @tblBatches)
		AND BatchId NOT IN (SELECT batchId FROM @tblMissing)

SELECT	*
FROM	@tblMissing
ORDER BY Company, BatchId, Integration, CustVnd, Inv_Ref

GO