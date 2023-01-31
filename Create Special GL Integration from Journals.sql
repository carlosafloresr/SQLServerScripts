SET NOCOUNT ON

DECLARE	@Integration	varchar(6) = 'SPCGL', 
        @Company		varchar(5) = DB_NAME(),
        @BatchId		varchar(15),
		@DatePortion	Varchar(15) = GPCustom.dbo.PADL(MONTH(GETDATE()), 2, '0') + GPCustom.dbo.PADL(DAY(GETDATE()), 2, '0') + RIGHT(GPCustom.dbo.PADL(YEAR(GETDATE()), 4, '0'), 2) + GPCustom.dbo.PADL(DATEPART(HOUR, GETDATE()), 2, '0') + GPCustom.dbo.PADL(DATEPART(MINUTE, GETDATE()), 2, '0'),
		@PstgDate		date,
		@Refrence		varchar(30),
		@TrxDate		date = '12/22/2021',
		@Series			smallint,
		@UserId			varchar(15),
		@ActNumSt		varchar(75),
		@CrdtAmnt		numeric(18,2),
		@DebitAmt		numeric(18,2),
		@Dscriptn		varchar(30),
		@Document		varchar(30) = 'M&R_REVERSAL_211228',
		@VendorId		varchar(15) = '',
		@SqncLine		int

SET @BatchId = @Integration + @DatePortion
			  --8FSI20200604_16

SELECT	TRXDATE,
		REFRENCE,
		SERIES,
		ACTNUMST,
		CRDTAMNT,
		DEBITAMT
INTO	#tmpData
FROM	(
		SELECT	*
		FROM	(
				SELECT	RTRIM(GL2.REFRENCE) AS REFRENCE,
						ISNULL(@TrxDate,GL2.TRXDATE) AS TRXDATE,
						RTRIM(GL5.ACTNUMST) AS ACTNUMST,
						GL2.DEBITAMT,
						GL2.CRDTAMNT,
						CASE WHEN GL2.SOURCDOC = 'PMTRX' THEN 'AP' ELSE 'GL' END AS RECTYPE,
						GL2.ORMSTRID AS VENDORID,
						GL2.ORDOCNUM AS DOCUMENTID,
						GL2.ORPSTDDT AS POSTINGDATE,
						GL2.SERIES
				FROM	GL20000 GL2
						INNER JOIN GL00105 GL5 ON GL2.ACTINDX = GL5.ACTINDX
				WHERE	--ORGNTSRC = @BatchId
						JRNENTRY IN (1801052,
1801053,
1799207,
1799208,
1799209,
1799210,
1799211,
1799212,
1799213,
1799214,
1799215,
1799216,
1799217,
1799218,
1799219,
1799220,
1799221,
1799222,
1799223,
1799224,
1799225,
1799226,
1799227,
1799228,
1799229,
1799230,
1799231,
1799232,
1799233,
1799234,
1799235,
1799236,
1799237,
1799238,
1799239,
1799240,
1799241,
1799242,
1799243,
1799244,
1799245,
1799246,
1799247)
						--			SELECT	DISTINCT JOURNAL
						--			FROM	GPCustom.dbo.JournalNumbers
						--			)
				) DATA
WHERE	RECTYPE = 'GL'
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
											  @UserId, @ActNumSt, @CrdtAmnt, @DebitAmt, @Dscriptn, @VendorId, Null, @Document, Null, Null, Null, Null, @SqncLine
	ELSE
		EXECUTE PRISQL004P.Integrations.dbo.USP_Integrations_GL @Integration, @Company, @BatchId, @PstgDate, @Refrence, @TrxDate, @Series,
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
		EXECUTE PRISQL004P.Integrations.dbo.USP_ReceivedIntegrations @Integration, @Company, @BatchId
		EXECUTE PRISQL004P.Integrations.dbo.USP_Integrations_GL_Select @Company, @BatchId, @Integration
	END
END

DROP TABLE #tmpData

GO