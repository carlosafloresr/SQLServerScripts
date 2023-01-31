SET NOCOUNT ON

DECLARE	@Integration	varchar(6) = 'SPCGL', 
        @Company		varchar(5) = 'GLSO',
        @BatchId		varchar(15) = 'RVSL20220908_0955',
		@DatePortion	Varchar(15),
		@PstgDate		date,
		@Refrence		varchar(30),
		@TrxDate		date,
		@Series			smallint,
		@UserId			varchar(15),
		@ActNumSt		varchar(75),
		@CrdtAmnt		numeric(18,2),
		@DebitAmt		numeric(18,2),
		@Dscriptn		varchar(30),
		@Document		varchar(30),
		@VendorId		varchar(15),
		@SqncLine		int

DECLARE curData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	'SPCGL' AS Integration,
		'GLSO' AS Company,
		'RVSL20220815_1238' AS BatchId,
		InvoiceDate AS TRXDATE, 
		RefDocument AS REFRENCE, 
		InvoiceDate AS TRXDATE, 
		2 AS SERIES, 
		'CFLORES' AS UserId,
		CreditAccount AS ACTNUMST, 
		0 AS CrdAmount, 
		ROUND(Amount * 2, 2) AS DebAmount, 
		RefDocument AS TRXDESCRIP,
		RecordId
FROM	FSI_TransactionDetails
WHERE	BatchId LIKE '9FSI20220815_12%'
		AND IntegrationType = 'FSIG'
UNION
SELECT	'SPCGL' AS Integration,
		'GLSO' AS Company,
		'RVSL20220815_1238' AS BatchId,
		InvoiceDate AS TRXDATE, 
		RefDocument AS REFRENCE, 
		InvoiceDate AS TRXDATE, 
		2 AS SERIES, 
		'CFLORES' AS UserId,
		DebitAccount AS ACTNUMST, 
		ROUND(Amount * 2, 2) AS CrdAmount, 
		0 AS DebAmount, 
		RefDocument AS TRXDESCRIP,
		RecordId
FROM	FSI_TransactionDetails
WHERE	BatchId LIKE '9FSI20220815_12%'
		AND IntegrationType = 'FSIG'
ORDER BY RefDocument, RecordId

IF (SELECT [Name] FROM sys.servers WHERE Server_Id = 0) = 'PRISQL01P'
BEGIN
	DELETE	IntegrationsDB.Integrations.dbo.Integrations_GL
	WHERE	Company = @Company
			AND BatchId = @BatchId
			AND Integration = @Integration

	DELETE	IntegrationsDB.Integrations.dbo.ReceivedIntegrations
	WHERE	Company = @Company
			AND BatchId = @BatchId
			AND Integration = @Integration
END
ELSE
BEGIN
	DELETE	PRISQL004P.Integrations.dbo.Integrations_GL
	WHERE	Company = @Company
			AND BatchId = @BatchId
			AND Integration = @Integration

	DELETE	PRISQL004P.Integrations.dbo.ReceivedIntegrations
	WHERE	Company = @Company
			AND BatchId = @BatchId
			AND Integration = @Integration
END

OPEN curData 
FETCH FROM curData INTO @Integration, @Company, @BatchId, @PstgDate, @Refrence, @TrxDate, @Series,
									  @UserId, @ActNumSt, @CrdtAmnt, @DebitAmt, @Dscriptn, @SqncLine

WHILE @@FETCH_STATUS = 0 
BEGIN
	IF (SELECT [Name] FROM sys.servers WHERE Server_Id = 0) = 'PRISQL01P'
		EXECUTE IntegrationsDB.Integrations.dbo.USP_Integrations_GL @Integration, @Company, @BatchId, @PstgDate, @Refrence, @TrxDate, @Series,
											  @UserId, @ActNumSt, @CrdtAmnt, @DebitAmt, @Dscriptn, @VendorId, Null, @SqncLine, Null, Null, Null, Null, 0
	ELSE
		EXECUTE PRISQL004P.Integrations.dbo.USP_Integrations_GL @Integration, @Company, @BatchId, @PstgDate, @Refrence, @TrxDate, @Series,
											  @UserId, @ActNumSt, @CrdtAmnt, @DebitAmt, @Dscriptn, @VendorId, Null, @SqncLine, Null, Null, Null, Null, 0

	FETCH FROM curData INTO @Integration, @Company, @BatchId, @PstgDate, @Refrence, @TrxDate, @Series,
										  @UserId, @ActNumSt, @CrdtAmnt, @DebitAmt, @Dscriptn, @SqncLine
END

CLOSE curData
DEALLOCATE curData

IF @@ERROR = 0
BEGIN
	EXECUTE Integrations.dbo.USP_ReceivedIntegrations @Integration, @Company, @BatchId
	EXECUTE Integrations.dbo.USP_Integrations_GL_Select @Company, @BatchId, @Integration
END