declare	@IntegrationType		Char(2) = 'AR',
		@FileName				Varchar(30) = Null

DECLARE	@GPBatchId			Varchar(25) = 'FRSAR_MANUAL',
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
		@CCVendor			Varchar(12),
		@PostingDate		Date,
		@EffectiveDate		Date = '08/21/2015'

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
		SELECT	DISTINCT F1.FRS_IntegrationId
				,F1.IntegrationType
				,F1.BatchId
				,F1.FileName
				,F1.RecordType
				,F1.FileVersion
				,F1.AccountNumber
				,F1.InvoiceNumber
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
				,@GPBatchId AS GPBatchId
				,F2.InvoiceNumber AS MatchDocument
		FROM	FRS_Integrations F1
				LEFT JOIN FRS_Integrations F2 ON F1.Workorder = F2.Workorder AND F2.IntegrationType = 'AR' 
		WHERE	F1.Integrationtype = 'AR'
				AND F1.RecordType = 'I'
				AND F1.InvoiceTotal > 0
				AND F1.Workorder IN (18529,
18582,
18586,
18604,
18698,
18726,
18943,
19024,
19081,
19090,
19139,
19178,
19181,
19272,
19314,
19325,
19370,
19389,
19393,
19395,
19401,
19454,
19471,
19487,
19502,
19517,
19525,
19534,
19573,
19574,
19607,
19716,
19857,
19885,
19919,
19927,
19944,
19952,
19975,
20013,
20021,
20027,
20117,
20125,
20135,
20136,
20150,
20178,
20407,
20449,
20455,
20481,
20496,
20505,
20560,
20567,
20572,
20616,
20617,
20620,
20661,
20676,
20694,
20695,
20713,
20735,
20810,
20850,
20852,
20963,
20988,
21062,
21125,
21145,
21166,
21245,
21325,
21326,
21343,
21369,
21391,
21394,
21395,
21397,
21400,
21442,
21530,
21594,
21602,
21603,
21615,
21627,
21634,
21636,
21642,
21675,
21680,
21697,
21698,
21704,
21710,
21712,
21743,
21747,
21748,
21750,
21757,
21774,
21780,
21783,
21787,
21789,
21790,
21791,
21794,
21799,
21808,
21811,
21822,
21827,
21835,
21837,
21839,
21842,
21854,
21858,
21861,
21871,
21873,
21875,
21903,
22024,
22052,
22058,
22134,
22142,
22203,
22225,
22237,
22238,
22287,
22288,
22301,
22303,
22319,
22320,
22332,
22449,
22493,
22544,
22575,
22578,
22583,
22588,
22603,
22625,
22627,
22656,
22684,
22687,
22688,
22725,
22730,
22732,
22736,
22779,
22798,
22799,
22800,
22827,
22927,
22989,
22990,
22993,
22995,
22996,
22997,
23001,
23003
)
		) DATA
ORDER BY 
		IntegrationType
		,Workorder

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
		InvoiceTotal,
		@EffectiveDate
FROM	#tmpData
WHERE	IntegrationType = 'AR'

OPEN curARData
FETCH FROM curARData INTO @Integration, @BatchId, @CustomerId, @DocumentNumber, @DocumentType, @DocumentAmount,
							@DocumentDate, @DueDate, @Description, @RecordId, @TaxAmount, @InvoiceTotal, @PostingDate

BEGIN TRANSACTION

WHILE @@FETCH_STATUS = 0 
BEGIN
	-- AR Transaction Debit Side 
	EXECUTE @ReturnValue = USP_Integrations_AR	@Integration,
												@Company,
												@BatchId,
												@DocumentNumber,
												@Description,
												@CustomerId,
												@EffectiveDate,
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
												'Auto-Importer',
												@EffectiveDate
	IF @ReturnValue > 0
	BEGIN
		-- AR Transaction Credit Side - Sales
		EXECUTE @ReturnValue = USP_Integrations_AR	@Integration,
													@Company,
													@BatchId,
													@DocumentNumber,
													@Description,
													@CustomerId,
													@EffectiveDate,
													@DueDate,
													@InvoiceTotal,
													@InvoiceTotal,
													@DocumentType,
													@ARCrdTransType,
													@ARCreditAccount,
													0,
													@DocumentAmount,
													@Description,
													Null,
													Null,
													'Auto-Importer',
													@EffectiveDate

		-- AR Transaction Credit Side - Tax
		IF @TaxAmount <> 0
		BEGIN
			EXECUTE @ReturnValue = USP_Integrations_AR	@Integration,
														@Company,
														@BatchId,
														@DocumentNumber,
														@Description,
														@CustomerId,
														@EffectiveDate,
														@DueDate,
														@InvoiceTotal,
														@InvoiceTotal,
														@DocumentType,
														@ARCrdTransType,
														@ARTaxAccount,
														0,
														@TaxAmount,
														@Description,
														Null,
														Null,
														'Auto-Importer',
														@EffectiveDate
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
								@DocumentDate, @DueDate, @Description, @RecordId, @TaxAmount, @InvoiceTotal, @PostingDate
END	

CLOSE curARData
DEALLOCATE curARData

IF @@ERROR = 0
BEGIN
	INSERT INTO ReceivedIntegrations (Integration, Company, BatchId)
	SELECT	DISTINCT LEFT(GPBatchId, 5) AS Integration, @Company AS Company, GPBatchId
	FROM	#tmpData

	COMMIT TRANSACTION
END
ELSE
	ROLLBACK TRANSACTION

DROP TABLE #tmpData