SET NOCOUNT ON

DECLARE	@Integration	varchar(6) = 'SPCGL', 
        @Company		varchar(5) = DB_NAME(),
        @BatchId		varchar(15),
		@DatePortion	Varchar(15) = GPCustom.dbo.PADL(MONTH(GETDATE()), 2, '0') + GPCustom.dbo.PADL(DAY(GETDATE()), 2, '0') + RIGHT(GPCustom.dbo.PADL(YEAR(GETDATE()), 4, '0'), 2) + GPCustom.dbo.PADL(DATEPART(HOUR, GETDATE()), 2, '0') + GPCustom.dbo.PADL(DATEPART(MINUTE, GETDATE()), 2, '0'),
		@PstgDate		date,
		@Refrence		varchar(30),
		@TrxDate		date = '11/10/2022',
		@Series			smallint,
		@UserId			varchar(15),
		@ActNumSt		varchar(75),
		@CrdtAmnt		numeric(18,2),
		@DebitAmt		numeric(18,2),
		@Dscriptn		varchar(30),
		@Document		varchar(30) = 'FSI_CORRECTION_1',
		@VendorId		varchar(15) = '',
		@SqncLine		int

SET @BatchId = @Integration + @DatePortion
			  --8FSI20200604_16

SELECT	TRXDATE,
		REFRENCE,
		ACTNUMST,
		CRDTAMNT,
		DEBITAMT
INTO	#tmpData
FROM	(
		SELECT	RefDocument AS REFRENCE,
				InvoiceDate AS TRXDATE,
				DebitAccount AS ACTNUMST,
				ABS(Amount) * 2 AS DEBITAMT,
				0 AS CRDTAMNT,
				'GL' AS RECTYPE,
				'' AS VENDORID,
				InvoiceNumber AS DOCUMENTID,
				InvoiceDate AS POSTINGDATE
		FROM	IntegrationsDB.Integrations.dbo.FSI_TransactionDetails
		WHERE	BatchId = '6FSI20221110_1618'
				AND IntegrationType = 'TIP'
				AND RecordId IN (3080607,3080608,3080609,3080610,3080611,3080612,3080613,3080614,3080615,3080618)
		UNION
		SELECT	RefDocument AS REFRENCE,
				InvoiceDate AS TRXDATE,
				CreditAccount AS ACTNUMST,
				0 AS DEBITAMT,
				ABS(Amount) * 2 AS CRDTAMNT,
				'GL' AS RECTYPE,
				'' AS VENDORID,
				InvoiceNumber AS DOCUMENTID,
				InvoiceDate AS POSTINGDATE
		FROM	IntegrationsDB.Integrations.dbo.FSI_TransactionDetails
		WHERE	BatchId = '6FSI20221110_1618'
				AND IntegrationType = 'TIP'
				AND RecordId IN (3080607,3080608,3080609,3080610,3080611,3080612,3080613,3080614,3080615,3080618)
		) G1

DECLARE curData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	@Integration AS Integration,
		@Company AS Company,
		@BatchId AS BatchId,
		GETDATE() AS TRXDATE,
		REFRENCE,
		GETDATE() AS TRXDATE,
		2 AS SERIES,
		'CFLORES' AS UserId,
		ACTNUMST,
		DEBITAMT,
		CRDTAMNT,
		REFRENCE AS TRXDESCRIP,
		0 AS RowNumber
FROM	#tmpData
ORDER BY REFRENCE, ACTNUMST

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
	DELETE	IntegrationsDB.Integrations.dbo.Integrations_GL
	WHERE	Company = @Company
			AND BatchId = @BatchId
			AND Integration = @Integration

	DELETE	IntegrationsDB.Integrations.dbo.ReceivedIntegrations
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
											  @UserId, @ActNumSt, @CrdtAmnt, @DebitAmt, @Dscriptn, @VendorId, Null, @Document, Null, Null, Null, Null, @SqncLine
	ELSE
		EXECUTE PRISQL10P.Integrations.dbo.USP_Integrations_GL @Integration, @Company, @BatchId, @PstgDate, @Refrence, @TrxDate, @Series,
											  @UserId, @ActNumSt, @CrdtAmnt, @DebitAmt, @Dscriptn, @VendorId, Null, @Document, Null, Null, Null, Null, @SqncLine

	FETCH FROM curData INTO @Integration, @Company, @BatchId, @PstgDate, @Refrence, @TrxDate, @Series,
										  @UserId, @ActNumSt, @CrdtAmnt, @DebitAmt, @Dscriptn, @SqncLine
END

CLOSE curData
DEALLOCATE curData

IF @@ERROR = 0
BEGIN
	IF (SELECT [Name] FROM sys.servers WHERE Server_Id = 0) = 'PRISQL01P'
	BEGIN
		EXECUTE IntegrationsDB.Integrations.dbo.USP_ReceivedIntegrations @Integration, @Company, @BatchId
		EXECUTE IntegrationsDB.Integrations.dbo.USP_Integrations_GL_Select @Company, @BatchId, @Integration
	END
	ELSE
	BEGIN
		EXECUTE PRISQL10P.Integrations.dbo.USP_ReceivedIntegrations @Integration, @Company, @BatchId
		EXECUTE PRISQL10P.Integrations.dbo.USP_Integrations_GL_Select @Company, @BatchId, @Integration
	END
END

DROP TABLE #tmpData

GO