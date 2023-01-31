DECLARE	@Integration	varchar(6) = 'SPCGL', 
        @Company		varchar(5) = DB_NAME(),
        @BatchId		varchar(15),
		@DatePortion	Varchar(15) = GPCustom.dbo.PADL(MONTH(GETDATE()), 2, '0') + GPCustom.dbo.PADL(DAY(GETDATE()), 2, '0') + RIGHT(GPCustom.dbo.PADL(YEAR(GETDATE()), 4, '0'), 2) + GPCustom.dbo.PADL(DATEPART(HOUR, GETDATE()), 2, '0') + GPCustom.dbo.PADL(DATEPART(MINUTE, GETDATE()), 2, '0'),
		@PstgDate		date,
		@Refrence		varchar(30),
		@TrxDate		date = '11/28/2020',
		@Series			smallint,
		@UserId			varchar(15),
		@ActNumSt		varchar(75),
		@CrdtAmnt		numeric(18,2),
		@DebitAmt		numeric(18,2),
		@Dscriptn		varchar(30),
		@SqncLine		int

SET @BatchId = 'FSI_TRANSACT' --@Integration + @DatePortion
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
						GL2.TRXDATE,
						RTRIM(GL5.ACTNUMST) AS ACTNUMST,
						GL2.DEBITAMT * 1 AS DEBITAMT,
						GL2.CRDTAMNT * 1 AS CRDTAMNT,
						CASE WHEN GL2.SOURCDOC = 'PMTRX' THEN 'AP' ELSE 'GL' END AS RECTYPE,
						GL2.ORMSTRID AS VENDORID,
						GL2.ORDOCNUM AS DOCUMENTID,
						GL2.ORPSTDDT AS POSTINGDATE,
						GL2.SERIES
				FROM	GL20000 GL2
						INNER JOIN GL00105 GL5 ON GL2.ACTINDX = GL5.ACTINDX
				WHERE	JRNENTRY IN (
									SELECT	* --DISTINCT JOURNAL
									FROM	(
									SELECT	GL2.JRNENTRY AS JOURNAL,
											GL5.ACTNUMST AS ACCOUNT,
											GL2.REFRENCE AS DESCRIPTION,
											CAST(GL2.TRXDATE AS Date) AS DATE,
											CAST(GL2.CRDTAMNT AS Numeric(10,2)) AS CREDIT,
											CAST(GL2.DEBITAMT AS Numeric(10,2)) AS DEBIT,
											GL2.ORGNTSRC AS BATCHID,
											IIF((GL5.ACTNUMST = '1-00-5199' AND GL2.CRDTAMNT > 0) OR (GL5.ACTNUMST = '0-99-1866' AND GL2.DEBITAMT > 0), 'I', 'C') AS TRXSTATUS
									FROM	GL20000 GL2
											INNER JOIN GL00105 GL5 ON GL2.ACTINDX = GL5.ACTINDX
									WHERE	GL5.ACTNUMST IN ('0-99-1866','1-00-5199')
											AND ORGNTSRC <> ''
											AND (GL2.ORGNTSRC LIKE '%FSI%' 
											OR GL2.ORGNTSRC LIKE '%SPC%')
											) DATA
									WHERE	TRXSTATUS = 'I'
									ORDER BY JOURNAL
									)
				) DATA
WHERE	RECTYPE = 'GL'
		) G1

DECLARE curData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	@Integration AS Integration,
		@Company AS Company,
		@BatchId AS BatchId,
		ISNULL(@TrxDate,TRXDATE),
		REFRENCE,
		ISNULL(@TrxDate,TRXDATE),
		2 AS SERIES,
		'CFLORES' AS UserId,
		ACTNUMST,
		DEBITAMT,
		CRDTAMNT,
		REFRENCE AS TRXDESCRIP,
		0 as RowNumber --ROW_NUMBER() OVER(PARTITION BY Invoice ORDER BY Invoice) * 500 AS RowNumber
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
											  @UserId, @ActNumSt, @CrdtAmnt, @DebitAmt, @Dscriptn, Null, Null, Null, Null, Null, Null, Null, @SqncLine
	ELSE
		EXECUTE PRISQL004P.Integrations.dbo.USP_Integrations_GL @Integration, @Company, @BatchId, @PstgDate, @Refrence, @TrxDate, @Series,
											  @UserId, @ActNumSt, @CrdtAmnt, @DebitAmt, @Dscriptn, Null, Null, Null, Null, Null, Null, Null, @SqncLine

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

-- SELECT * FROM #tmpData

DROP TABLE #tmpData

GO