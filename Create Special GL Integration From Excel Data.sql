DECLARE	@Integration	varchar(6) = 'SPCGL', 
		@JustDisplay	bit = 0,
        @Company		varchar(5) = DB_NAME(),
        @BatchId		varchar(15),
		@DatePortion	Varchar(15) = GPCustom.dbo.PADL(MONTH(GETDATE()), 2, '0') + GPCustom.dbo.PADL(DAY(GETDATE()), 2, '0') + RIGHT(GPCustom.dbo.PADL(YEAR(GETDATE()), 4, '0'), 2) + GPCustom.dbo.PADL(DATEPART(HOUR, GETDATE()), 2, '0') + GPCustom.dbo.PADL(DATEPART(MINUTE, GETDATE()), 2, '0'),
		@PstgDate		date,
		@Refrence		varchar(30),
		@TrxDate		date = '01/02/2021',
		@Series			smallint,
		@UserId			varchar(15),
		@ActNumSt		varchar(75),
		@CrdtAmnt		numeric(18,2),
		@DebitAmt		numeric(18,2),
		@Dscriptn		varchar(30),
		@SqncLine		int

DECLARE @tblData		Table (Description Varchar(30), AcctCredit Varchar(15), AcctDebit Varchar(15), Amount Numeric(10,2))

-- ="INSERT INTO @tblData (Description, Account, Debit, Credit) VALUES ('"&D2&"','"&E2&"',"&G2&","&H2&")"
-- ="INSERT INTO @tblData (Description, AccTDebit, AcctCredit, Amount) VALUES ('"&A2&"','"&D2&"','"&E2&"',"&F2&")"

INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C95-114746','1-00-5199','0-99-1866',1950)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C95-144267D','0-00-5010','0-88-1866',700)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C95-146464A','0-00-5010','0-88-1866',440)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C95-153787C','0-00-5010','0-88-1866',351.3)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C95-158491B','1-00-5199','0-99-1866',661)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C95-159168A','1-00-5199','0-99-1866',1440)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C95-172690','0-00-5010','0-88-1866',40)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C95-172691','0-00-5010','0-88-1866',40)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C95-172896B','0-00-5010','0-00-2105',1840)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C95-174266','1-00-5199','0-99-1866',1346.5)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C95-177733B','0-00-5010','0-00-2105',20)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C95-183692','1-00-5199','0-99-1866',346.8)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C95-183698','1-00-5199','0-99-1866',451.8)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C95-183866','1-00-5199','0-99-1866',125)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-112203C','0-00-5010','0-00-2105',50)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-116296A','1-00-5199','0-99-1866',1338)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-116353','1-00-5199','0-99-1866',725)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-116381A','1-00-5199','0-99-1866',1450)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-116961A','1-00-5199','0-99-1866',1510)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-117071A','1-00-5199','0-99-1866',1350)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-118278B','0-00-5010','0-00-2105',200)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-124229','0-00-5010','0-88-1866',150)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-126218','1-00-5199','0-99-1866',382.02)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-126611','0-00-5010','0-88-1866',480)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-126693','0-00-5010','0-88-1866',150)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-126937','0-00-5010','0-88-1866',150)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-127093','0-00-5010','0-88-1866',300)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-127634','1-00-5199','0-99-1866',382.2)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-127717','1-00-5199','0-99-1866',382.02)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-128033','1-00-5199','0-99-1866',382.2)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-128681','1-00-5199','0-99-1866',150)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-128726','1-00-5199','0-99-1866',150)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-128893','0-00-5010','0-88-1866',150)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-129035','1-00-5199','0-99-1866',3377.4)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-129072','1-00-5199','0-99-1866',401.2)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-129176','1-00-5199','0-99-1866',1050)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-129350','1-00-5199','0-99-1866',382.02)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-129414','0-00-5010','0-88-1866',2887.4)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-130362','0-00-5010','0-88-1866',200)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-130593','1-00-5199','0-99-1866',401.2)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-130675','0-00-5010','0-88-1866',4650)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-132192','0-00-5010','0-88-1866',150)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-132876','0-00-5010','0-88-1866',150)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-138891','0-00-5010','0-88-1866',650)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-139702','0-00-5010','0-88-1866',325)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-141343','0-00-5010','0-00-2105',825)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-142745','0-00-5010','0-88-1866',875)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C96-145941','0-00-5010','0-88-1866',750)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('C97-111586B','1-00-5199','0-99-1866',3075)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('D95-151605','0-88-1866','0-00-5010',100)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('D95-168501','0-99-1866','1-00-5199',330.5)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('D95-169442','0-99-1866','1-00-5199',346.8)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('D95-170157','0-99-1866','1-00-5199',471.8)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('D95-170227','0-99-1866','1-00-5199',346.8)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('D95-170312','0-99-1866','1-00-5199',330.5)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('D95-170623A','0-99-1866','1-00-5199',295)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('D95-171810','0-99-1866','1-00-5199',974.68)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('D95-175259','0-99-1866','1-00-5199',1074.68)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('D95-175271','0-99-1866','1-00-5199',974.68)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('D95-175686','0-99-1866','1-00-5199',1174.68)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('D95-175753','0-99-1866','1-00-5199',1074.68)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('D95-175767','0-99-1866','1-00-5199',1074.68)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('D95-175778','0-99-1866','1-00-5199',1074.68)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('D95-175888','0-99-1866','1-00-5199',974.68)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('D95-175889','0-99-1866','1-00-5199',974.68)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('D95-176225','0-99-1866','1-00-5199',974.68)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('D95-176301','0-99-1866','1-00-5199',974.68)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('D95-183693','0-99-1866','1-00-5199',346.8)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('D95-183699','0-99-1866','1-00-5199',451.8)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('D95-183870','0-99-1866','1-00-5199',125)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('D95-186648','0-99-1866','0-00-5010',1461.23)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('D96-101992A','0-88-1866','0-00-5010',50)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('D96-110159','0-88-1866','0-00-5010',25)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('D96-112206C','0-88-1866','0-00-2105',585)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('D96-126611','0-88-1866','0-00-5010',1090)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('D96-129035','0-88-1866','1-00-5199',2976.2)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('D96-129414','0-88-1866','1-00-5199',2486.2)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('D96-138979A','0-88-1866','0-00-5010',1179.2)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('D96-142526','0-88-1866','0-00-5010',350)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('D97-107527B','0-99-1866','1-00-5199',3077.16)
INSERT INTO @tblData (Description, AcctCredit, AccTDebit, Amount) VALUES ('D97-115075','0-88-1866','0-00-5010',536.49)


SET @BatchId = 'KIP_01022021' --@Integration + @DatePortion
			 -- XXXXXXXXXXXXXXX

SELECT	*
INTO	#tmpData
FROM	(
SELECT	@TrxDate AS TRXDATE,
		Description AS REFRENCE,
		2 AS SERIES,
		AcctDebit AS ACTNUMST,
		0 AS CRDTAMNT,
		Amount AS DEBITAMT
FROM	@tblData
UNION
SELECT	@TrxDate AS TRXDATE,
		Description AS REFRENCE,
		2 AS SERIES,
		AcctCredit AS ACTNUMST,
		Amount AS CRDTAMNT,
		0 AS DEBITAMT
FROM	@tblData
		) DATA
ORDER BY REFRENCE

SELECT	@Integration AS Integration,
		@Company AS Company,
		@BatchId AS BatchId,
		TRXDATE,
		REFRENCE,
		TRXDATE,
		2 AS SERIES,
		'CFLORES' AS UserId,
		ACTNUMST,
		CRDTAMNT,
		DEBITAMT,
		REFRENCE AS TRXDESCRIP,
		0 as RowNumber --ROW_NUMBER() OVER(PARTITION BY Invoice ORDER BY Invoice) * 500 AS RowNumber
FROM	#tmpData
ORDER BY REFRENCE, ACTNUMST

DECLARE curData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	@Integration AS Integration,
		@Company AS Company,
		@BatchId AS BatchId,
		TRXDATE,
		REFRENCE,
		TRXDATE,
		2 AS SERIES,
		'CFLORES' AS UserId,
		ACTNUMST,
		CRDTAMNT,
		DEBITAMT,
		REFRENCE AS TRXDESCRIP,
		0 as RowNumber --ROW_NUMBER() OVER(PARTITION BY Invoice ORDER BY Invoice) * 500 AS RowNumber
FROM	#tmpData
ORDER BY REFRENCE, ACTNUMST

IF @JustDisplay = 0
BEGIN
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
END
ELSE
	SELECT * FROM #tmpData ORDER BY REFRENCE, ACTNUMST

DROP TABLE #tmpData

GO