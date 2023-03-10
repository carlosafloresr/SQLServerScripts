USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[USP_FRS_Integrations_Process]    Script Date: 6/24/2015 2:45:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_FRS_Integrations_Process 'AR','FRSAR-20150617135622'
EXECUTE USP_FRS_Integrations_Process 'AP','FRSAP-20150617145148'
*/
ALTER PROCEDURE [dbo].[USP_FRS_Integrations_Process]
	@IntegrationType		Char(2),
	@FileName				Varchar(30) = Null
AS
DECLARE	@GPBatchId			Varchar(25) = REPLACE(dbo.FormatDateYMD(GETDATE(), 1, 1, 1), '_', ''),
		@Company			Varchar(5),
		@APDebTransType		Int = 6,
		@APCrdTransType		Int = 2,
		@ARDebTransType		Int = 2,
		@ARCrdTransType		Int = 9,
		@APDebitAccount		Varchar(15),
		@APCreditAccount	Varchar(15),
		@APCreditAccountEFS	Varchar(15),
		@ARDebitAccount		Varchar(15),
		@ARCreditAccount	Varchar(15),
		@ARTaxAccount		Varchar(15),
		@EFSRequestType		Char(1),
		@ReferenceNumber	Varchar(12),
		@EFSVendor			Varchar(12),
		@CCVendor			Varchar(12)

SELECT	@EFSVendor = RTRIM(VarC)
FROM	LENSASQL001.GPCustom.dbo.Parameters
WHERE	Company = 'FI'
		AND ParameterCode = 'FRS_EFSVENDOR'

SELECT	@CCVendor = RTRIM(VarC)
FROM	LENSASQL001.GPCustom.dbo.Parameters
WHERE	Company = 'FI'
		AND ParameterCode = 'FRS_CCVENDOR'

SELECT	@Company = RTRIM(VarC)
FROM	LENSASQL001.GPCustom.dbo.Parameters
WHERE	Company = 'FI'
		AND ParameterCode = 'NEWPORT_FRS_COMPANY'

SELECT	@APDebitAccount = RTRIM(VarC)
FROM	LENSASQL001.GPCustom.dbo.Parameters
WHERE	Company = 'FI'
		AND ParameterCode = 'FRS_AP_DEBITACCOUNT'

SELECT	@APCreditAccount = RTRIM(VarC)
FROM	LENSASQL001.GPCustom.dbo.Parameters
WHERE	Company = 'FI'
		AND ParameterCode = 'FRS_AP_CREDITACCOUNT'

SELECT	@APCreditAccountEFS = RTRIM(VarC)
FROM	LENSASQL001.GPCustom.dbo.Parameters
WHERE	Company = 'FI'
		AND ParameterCode = 'FRS_AP_CREDITACCOUNT_EFS'

SELECT	@ARDebitAccount = RTRIM(VarC)
FROM	LENSASQL001.GPCustom.dbo.Parameters
WHERE	Company = 'FI'
		AND ParameterCode = 'FRS_AR_DEBITACCOUNT'

SELECT	@ARCreditAccount = RTRIM(VarC)
FROM	LENSASQL001.GPCustom.dbo.Parameters
WHERE	Company = 'FI'
		AND ParameterCode = 'FRS_AR_CREDITACCOUNT'

SELECT	@ARTaxAccount = RTRIM(VarC)
FROM	LENSASQL001.GPCustom.dbo.Parameters
WHERE	Company = 'FI'
		AND ParameterCode = 'FRS_AR_TAXACCOUNT'

SELECT	DISTINCT *
INTO	#tmpData
FROM	(
		SELECT	F1.FRS_IntegrationId
				,F1.IntegrationType
				,F1.BatchId
				,F1.FileName
				,F1.RecordType
				,F1.FileVersion
				,F1.AccountNumber
				,F1.ReferenceNumber AS InvoiceNumber
				,F1.InvoiceDate
				,F1.Chassis
				,F1.Container
				,F1.Currency
				,F1.Labor
				,F1.Parts
				,F1.Tax
				,F1.InvoiceTotal
				,F1.PrepaidAmount
				,F1.PaymentType
				,F1.ReferenceNumber
				,F1.EFSRequestType
				,F1.Workorder
				,F1.Documents
				,F1.Address
				,F1.City
				,F1.State
				,F1.ZipCode
				,F1.ReceivedOn
				,F1.Processed
				,'FRSAP' + @GPBatchId AS GPBatchId
				,F2.InvoiceNumber AS MatchDocument
				,F2.FRS_IntegrationId AS MatchId
		FROM	FRS_Integrations F1
				LEFT JOIN FRS_Integrations F2 ON F1.Workorder = F2.Workorder AND F2.IntegrationType = CASE WHEN @IntegrationType = 'AR' THEN 'AP' ELSE 'AR' END AND F2.RecordType = CASE WHEN @IntegrationType = 'AR' THEN 'C' ELSE 'I' END
		WHERE	F1.Integrationtype = @IntegrationType
				AND @IntegrationType = 'AP'
				AND F1.FileName = @FileName
				AND F1.Processed = 0
				AND F1.RecordType = CASE WHEN @IntegrationType = 'AR' THEN 'I' ELSE 'C' END
				AND F1.AccountNumber IN (@EFSVendor, @CCVendor)
				AND F2.Workorder IS Null
				AND LEN(F1.ReferenceNumber) >= 9
				AND F1.ReferenceNumber NOT LIKE '%0000%'
				AND F1.ReferenceNumber NOT LIKE '%XXXX%'
		UNION
		SELECT	F1.FRS_IntegrationId
				,F1.IntegrationType
				,F1.BatchId
				,F1.FileName
				,F1.RecordType
				,F1.FileVersion
				,F1.AccountNumber
				,CASE WHEN CASE WHEN @IntegrationType = 'AR' THEN 'AR' ELSE 'AP' END = 'AP' AND F1.AccountNumber IN (@EFSVendor, @CCVendor) AND F1.EFSRequestType <> 'A' AND LEN(RTRIM(F1.ReferenceNumber)) = 9 THEN F1.ReferenceNumber 
					ELSE F1.InvoiceNumber 
				 END AS InvoiceNumber
				,F1.InvoiceDate
				,F1.Chassis
				,F1.Container
				,F1.Currency
				,F1.Labor
				,F1.Parts
				,F1.Tax
				,F1.InvoiceTotal
				,F1.PrepaidAmount
				,F1.PaymentType
				,F1.ReferenceNumber
				,F1.EFSRequestType
				,F1.Workorder
				,F1.Documents
				,F1.Address
				,F1.City
				,F1.State
				,F1.ZipCode
				,F1.ReceivedOn
				,F1.Processed
				,'FRS' + @IntegrationType + @GPBatchId AS GPBatchId
				,F2.InvoiceNumber AS MatchDocument
				,F2.FRS_IntegrationId AS MatchId
		FROM	FRS_Integrations F1
				INNER JOIN FRS_Integrations F2 ON F1.Workorder = F2.Workorder AND F2.IntegrationType = CASE WHEN @IntegrationType = 'AR' THEN 'AP' ELSE 'AR' END AND F2.RecordType = CASE WHEN @IntegrationType = 'AR' THEN 'C' ELSE 'I' END
		WHERE	F1.Integrationtype = @IntegrationType
				AND ((@IntegrationType = 'AP' AND F1.Processed IN (0,1)) OR (@IntegrationType = 'AR' AND F1.Processed = 0))
				AND F1.RecordType = CASE WHEN @IntegrationType = 'AR' THEN 'I' ELSE 'C' END
				AND F1.FileName = @FileName
		) DATA
ORDER BY 
		IntegrationType
		,Workorder
		
INSERT INTO #tmpData
	SELECT	F1.FRS_IntegrationId
			,F1.IntegrationType
			,F1.BatchId
			,F1.FileName
			,F1.RecordType
			,F1.FileVersion
			,F1.AccountNumber
			,CASE WHEN CASE WHEN @IntegrationType = 'AR' THEN 'AP' ELSE 'AR' END = 'AP' AND F1.AccountNumber IN (@EFSVendor, @CCVendor) AND F1.EFSRequestType <> 'A' AND LEN(RTRIM(F1.ReferenceNumber)) = 9 THEN F1.ReferenceNumber 
				ELSE F1.InvoiceNumber 
				END AS InvoiceNumber
			,F1.InvoiceDate
			,F1.Chassis
			,F1.Container
			,F1.Currency
			,F1.Labor
			,F1.Parts
			,F1.Tax
			,F1.InvoiceTotal
			,F1.PrepaidAmount
			,F1.PaymentType
			,F1.ReferenceNumber
			,F1.EFSRequestType
			,F1.Workorder
			,F1.Documents
			,F1.Address
			,F1.City
			,F1.State
			,F1.ZipCode
			,F1.ReceivedOn
			,F1.Processed
			,'FRS' + CASE WHEN @IntegrationType = 'AR' THEN 'AP' ELSE 'AR' END + @GPBatchId AS GPBatchId
			,F2.InvoiceNumber AS MatchDocument
			,F2.FRS_IntegrationId AS MatchId
	FROM	FRS_Integrations F1
			INNER JOIN #tmpData F2 ON F1.FRS_IntegrationId = F2.MatchId AND F2.MatchDocument IS NOT Null
	WHERE	F1.Integrationtype = CASE WHEN @IntegrationType = 'AR' THEN 'AP' ELSE 'AR' END
			AND ((@IntegrationType = 'AR' AND F1.Processed IN (0,1)) OR (@IntegrationType = 'AP' AND F1.Processed = 0))
			AND F1.RecordType = CASE WHEN @IntegrationType = 'AR' THEN 'C' ELSE 'I' END

-------------------------------------------------------------------------------------
-- AP Transactions Creation
-------------------------------------------------------------------------------------
DECLARE	@Integration	Varchar(5),
		@VoucherNumber	Varchar(17),
		@VendorId		Varchar(15),
		@DocumentNumber	Varchar(20),
		@DocumentType	Int,
		@DocumentAmount	Numeric(10,2),
		@DocumentDate	Date,
		@PostingDate	Date,
		@Description	Varchar(25),
		@Chassis		Varchar(12),
		@Container		Varchar(12),
		@RecordId		Int,
		@ReturnValue	Int,
		@GLAccount		Varchar(15),
		@MatchDocument	Varchar(20),
		@GLBatchId		Varchar(15),
		@WorkOrder		Varchar(10),
		@BatchId		Varchar(30)

DECLARE curAPData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	LEFT(GPBatchId, 5) AS Integration,
		GPBatchId,
		'FRS' + @GPBatchId + dbo.PADL(ROW_NUMBER() OVER (ORDER BY GPBatchId), 4, '0') AS VoucherNumber,
		AccountNumber,
		InvoiceNumber,
		1 AS DocType,
		InvoiceTotal,
		InvoiceDate,
		GETDATE() AS PostingDate,
		'CH:' + Chassis + '/IN:' + Workorder AS Description,
		Container,
		Chassis,
		FRS_IntegrationId,
		EFSRequestType,
		ReferenceNumber,
		MatchDocument,
		Workorder
FROM	#tmpData
WHERE	IntegrationType = 'AP'

OPEN curAPData
FETCH FROM curAPData INTO @Integration, @BatchId, @VoucherNumber, @VendorId, @DocumentNumber, @DocumentType, @DocumentAmount,
							@DocumentDate, @PostingDate, @Description, @Chassis, @Container, @RecordId, @EFSRequestType, @ReferenceNumber, @MatchDocument, @WorkOrder

WHILE @@FETCH_STATUS = 0 
BEGIN
	-- AP/GL Transaction Debit Side
	SET @GLBatchId = Null
	SET @GLAccount = CASE WHEN @VendorId IN (@EFSVendor, @CCVendor) AND @MatchDocument IS Null THEN @APCreditAccountEFS ELSE @APDebitAccount END

	IF @VendorId IN (@EFSVendor, @CCVendor) AND @MatchDocument IS NOT Null
	BEGIN
		SET @GLBatchId = REPLACE(@BatchId, 'FRSAP', 'FRSGL')
		SET @GLAccount = @APCreditAccountEFS

		EXECUTE @ReturnValue = USP_Integrations_GL	'FRSGL',
													@Company,
													@GLBatchId,
													@PostingDate,
													@Description,
													@DocumentDate,
													2,
													'Auto-Importer',
													@GLAccount,
													@DocumentAmount,
													0,
													@Description,
													@VendorId,
													@WorkOrder,
													@DocumentNumber,
													Null
	END
	ELSE
	BEGIN
		EXECUTE @ReturnValue = USP_Integrations_AP_Full @Integration,
														@Company,
														@BatchId,
														@VoucherNumber,
														@VendorId,
														@DocumentNumber,
														@DocumentType,
														@DocumentAmount,
														@DocumentAmount,
														@PostingDate,
														@DocumentAmount,
														@DocumentAmount,
														@DocumentAmount,
														@Description,
														'USD2',
														'AVERAGE',
														'01/01/2007',
														0,
														0,
														@APDebTransType,
														@GLAccount,
														@DocumentAmount,
														0,
														@Description,
														@RecordId,
														'Auto-Importer',
														Null,
														@Container,
														@Chassis,
														Null,
														Null,
														Null,
														Null,
														Null,
														@DocumentNumber,
														0,
														@MatchDocument
	END

	IF @ReturnValue > 0
	BEGIN
		-- AP/GL Transaction Credit Side
		SET @GLAccount =	CASE WHEN @VendorId IN (@EFSVendor, @CCVendor) AND @MatchDocument IS NOT Null THEN @APCreditAccountEFS
							ELSE @APCreditAccount END

		IF @VendorId IN (@EFSVendor, @CCVendor) AND @MatchDocument IS NOT Null
		BEGIN
			SET @GLBatchId = REPLACE(@BatchId, 'FRSAP', 'FRSGL')
			SET @GLAccount = @APDebitAccount

			EXECUTE @ReturnValue = USP_Integrations_GL	'FRSGL',
														@Company,
														@GLBatchId,
														@PostingDate,
														@Description,
														@DocumentDate,
														2,
														'Auto-Importer',
														@GLAccount,
														0,
														@DocumentAmount,
														@Description,
														@VendorId,
														@WorkOrder,
														@DocumentNumber,
														Null
		END
		ELSE
		BEGIN
			SET @GLBatchId = Null

			EXECUTE @ReturnValue = USP_Integrations_AP_Full @Integration,
															@Company,
															@BatchId,
															@VoucherNumber,
															@VendorId,
															@DocumentNumber,
															@DocumentType,
															@DocumentAmount,
															@DocumentAmount,
															@PostingDate,
															@DocumentAmount,
															@DocumentAmount,
															@DocumentAmount,
															@Description,
															'USD2',
															'AVERAGE',
															'01/01/2007',
															0,
															0,
															@APCrdTransType,
															@GLAccount,
															0,
															@DocumentAmount,
															@Description,
															@RecordId,
															'Auto-Importer',
															Null,
															@Container,
															@Chassis,
															Null,
															Null,
															Null,
															Null,
															Null,
															@DocumentNumber,
															0,
															@MatchDocument
		END
		
		-- After Debit and Credit have been created we changed the status of the record
		IF @ReturnValue > 0
		BEGIN
			UPDATE	FRS_Integrations 
			SET		Processed = CASE WHEN @GLBatchId IS NOT Null THEN 2 ELSE 1 END,
					GPBatchId = CASE WHEN @GLBatchId IS Null THEN @BatchId ELSE @GLBatchId END
			WHERE	FRS_IntegrationId = @RecordId

			IF @GLBatchId IS NOT Null
			BEGIN
				UPDATE	#tmpData
				SET		GPBatchId = @GLBatchId,
						Processed = CASE WHEN @GLBatchId IS NOT Null THEN 2 ELSE 1 END
				WHERE	FRS_IntegrationId = @RecordId
			END
		END
	END

	FETCH FROM curAPData INTO @Integration, @BatchId, @VoucherNumber, @VendorId, @DocumentNumber, @DocumentType, @DocumentAmount,
								@DocumentDate, @PostingDate, @Description, @Chassis, @Container, @RecordId, @EFSRequestType, @ReferenceNumber, @MatchDocument, @WorkOrder
END	

CLOSE curAPData
DEALLOCATE curAPData

-------------------------------------------------------------------------------------
-- AR Transactions Creation
-------------------------------------------------------------------------------------
DECLARE	@CustomerId		Varchar(15),
		@DueDate		Date,
		@TaxAmount		Numeric(10,2),
		@InvoiceTotal	Numeric(10,2)

DECLARE curARData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	LEFT(GPBatchId, 5) AS Integration,
		GPBatchId,
		AccountNumber,
		InvoiceNumber,
		1 AS DocType,
		Labor + Parts AS InvoiceAmount,
		InvoiceDate,
		DATEADD(dd, 30, InvoiceDate) AS DueDate,
		'CH:' + Chassis + '/IN:' + Workorder AS Description,
		FRS_IntegrationId,
		Tax,
		InvoiceTotal
FROM	#tmpData
WHERE	IntegrationType = 'AR'

OPEN curARData
FETCH FROM curARData INTO @Integration, @BatchId, @CustomerId, @DocumentNumber, @DocumentType, @DocumentAmount,
							@DocumentDate, @DueDate, @Description, @RecordId, @TaxAmount, @InvoiceTotal

WHILE @@FETCH_STATUS = 0 
BEGIN
	-- AR Transaction Debit Side 
	EXECUTE @ReturnValue = USP_Integrations_AR	@Integration,
												@Company,
												@BatchId,
												@DocumentNumber,
												@Description,
												@CustomerId,
												@DocumentDate,
												@DueDate,
												@InvoiceTotal,
												@InvoiceTotal,
												@DocumentType,
												@ARDebTransType,
												@ARDebitAccount,
												@InvoiceTotal,
												0,
												@Description,
												Null,
												Null,
												'Auto-Importer'
	IF @ReturnValue > 0
	BEGIN
		-- AR Transaction Credit Side - Sales
		EXECUTE @ReturnValue = USP_Integrations_AR	@Integration,
													@Company,
													@BatchId,
													@DocumentNumber,
													@Description,
													@CustomerId,
													@DocumentDate,
													@DueDate,
													@DocumentAmount,
													@DocumentAmount,
													@DocumentType,
													@ARCrdTransType,
													@ARCreditAccount,
													0,
													@DocumentAmount,
													@Description,
													Null,
													Null,
													'Auto-Importer'

		-- AR Transaction Credit Side - Tax
		IF @TaxAmount <> 0
		BEGIN
			EXECUTE @ReturnValue = USP_Integrations_AR	@Integration,
														@Company,
														@BatchId,
														@DocumentNumber,
														@Description,
														@CustomerId,
														@DocumentDate,
														@DueDate,
														@TaxAmount,
														@TaxAmount,
														@DocumentType,
														@ARCrdTransType,
														@ARTaxAccount,
														0,
														@TaxAmount,
														@Description,
														Null,
														Null,
														'Auto-Importer'
		END

		-- After Debit and Credit have been created we changed the status of the record
		IF @ReturnValue > 0
		BEGIN
			UPDATE	FRS_Integrations 
			SET		Processed = 2,
					GPBatchId = @BatchId
			WHERE	FRS_IntegrationId = @RecordId
		END
	END

	FETCH FROM curARData INTO @Integration, @BatchId, @CustomerId, @DocumentNumber, @DocumentType, @DocumentAmount,
								@DocumentDate, @DueDate, @Description, @RecordId, @TaxAmount, @InvoiceTotal
END	

CLOSE curARData
DEALLOCATE curARData

IF @@ERROR = 0
BEGIN
	INSERT INTO ReceivedIntegrations (Integration, Company, BatchId)
	SELECT	DISTINCT LEFT(GPBatchId, 5) AS Integration, @Company AS Company, GPBatchId
	FROM	#tmpData
END

DROP TABLE #tmpData