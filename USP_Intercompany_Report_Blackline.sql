/*
EXECUTE GPCustom.dbo.USP_Intercompany_Report_Blackline 1, 12
*/
ALTER PROCEDURE USP_Intercompany_Report_Blackline
		@JustTest		Bit = 0,
		@RunPeriod		Int = Null
AS
SET NOCOUNT ON

DECLARE	@Company		Varchar(5),
		@CpyNumber		Varchar(2) = '',
		@Intercompany	Varchar(5),
		@Account		Varchar(15), 
		@Description	Varchar(50),
		@Period			Int = 11,
		@DOSCommand		Varchar(4000),
		@DatePortion	Varchar(12) = dbo.PADL(MONTH(GETDATE()), 2, '0') + dbo.PADL(DAY(GETDATE()), 2, '0') + RIGHT(dbo.PADL(YEAR(GETDATE()), 4, '0'), 2) + '_' + dbo.PADL(DATEPART(HOUR, GETDATE()), 2, '0') + dbo.PADL(DATEPART(MINUTE, GETDATE()), 2, '0'),
		@AcctDesc		Varchar(50),
		@Query			Varchar(MAX)

DECLARE @tblPeriod		Table (PeriodId Char(2))

IF @RunPeriod IS Null
BEGIN
	SET @Query = N'SELECT TOP 1 PERIODID
	FROM	AIS.dbo.View_FiscalPeriods
	WHERE	CLOSED = 0
			AND YEAR1 >= YEAR(GETDATE())
	ORDER BY YEAR1, PERIODID'

	INSERT INTO @tblPeriod
	EXECUTE(@Query)

	SET @Period = (SELECT PeriodId FROM @tblPeriod)
END
ELSE
	SET @Period = @RunPeriod

DECLARE	@tblGLData		Table (
		Company			Varchar(5),
		Entity			Char(2),
		Intercompany	Varchar(5),
		GLAccount		Varchar(12),
		AcctDescript	Varchar(100),
		AcctType		Varchar(12),
		GP_Period		Int,
		JournalNum		Int,
		TrxSource		Varchar(20),
		TrxDate			Date,
		Description		Varchar(75),
		Debit			Numeric(10,2),
		Credit			Numeric(10,2),
		Trx_Amount		Numeric(10,2))

DECLARE @tblAcctAlias	Table (
		Company			Varchar(5),
		Alias			Varchar(5),
		CpyNumber		Int)

INSERT INTO @tblAcctAlias VALUES ('AIS','AIS', 4)
INSERT INTO @tblAcctAlias VALUES ('DNJ','DNJ', 7)
INSERT INTO @tblAcctAlias VALUES ('GIS','GIS', 2)
INSERT INTO @tblAcctAlias VALUES ('GLSO','IMCNA', 9)
INSERT INTO @tblAcctAlias VALUES ('HMIS','H&M', 6)
INSERT INTO @tblAcctAlias VALUES ('IILS','IMCC', 20)
INSERT INTO @tblAcctAlias VALUES ('IMC','IMCG', 1)
INSERT INTO @tblAcctAlias VALUES ('IMCC','IMCH', 26)
INSERT INTO @tblAcctAlias VALUES ('IMCMR','IMCMR', 11)
INSERT INTO @tblAcctAlias VALUES ('MCCP','MCCP', 23)
INSERT INTO @tblAcctAlias VALUES ('NDS','NDS', 10)
INSERT INTO @tblAcctAlias VALUES ('OIS','OIS', 5)
INSERT INTO @tblAcctAlias VALUES ('PDS','PDS', 8)
--INSERT INTO @tblAcctAlias VALUES ('PTS','PTS', 3)
INSERT INTO @tblAcctAlias VALUES ('RCCL','RCCL', 22)

DECLARE @tblGLAccounts Table (Account Varchar(15), AccType Varchar(15), AcctDescription Varchar(50))

INSERT INTO @tblGLAccounts
SELECT	Account, IIF(Description LIKE '%PAYABLE%', 'Payable', 'Receivable') AS AccType, Description AS AcctDescription
FROM	IntercompanyReport_Accounts
WHERE	Company = 'NONE'

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT IA.Company, IA.Intercompany, IA.Account, IA.Description, AA.CpyNumber, IIF(IA.Description LIKE '%PAY%', 'Payable', 'Receivable') AS AccType
FROM	IntercompanyReport_Accounts IA
		INNER JOIN @tblAcctAlias AA ON IA.Company = AA.Company
WHERE	IA.Inactive = 0

OPEN curCompanies 
FETCH FROM curCompanies INTO @Company, @Intercompany, @Account, @Description, @CpyNumber, @AcctDesc

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = N'SELECT ''' + @Company + ''',''' + dbo.PADL(@CpyNumber, 2, '0') + ''', ''' + @Intercompany + ''', GL5.ACTNUMST, ''' + @Description + ''',
			''' + @AcctDesc + ''',
			GL2.PERIODID,
			GL2.JRNENTRY,
			GL2.TRXSORCE,
			GL2.TRXDATE,
			GL2.DSCRIPTN,
			GL2.DEBITAMT,
			GL2.CRDTAMNT,
			GL2.DEBITAMT - GL2.CRDTAMNT
	FROM	' + @Company + '.dbo.GL20000 GL2
			INNER JOIN ' + @Company + '.dbo.GL00105 GL5 ON GL2.ACTINDX = GL5.ACTINDX
	WHERE	GL2.PERIODID = ' + CAST(@Period AS Varchar) + '
			AND GL2.VOIDED = 0 
			AND GL5.ACTNUMST = ''' + @Account + ''' 
	ORDER BY
			GL2.TRXDATE,
			GL2.JRNENTRY'
			
	INSERT INTO @tblGLData
	EXECUTE(@Query)

	FETCH FROM curCompanies INTO @Company, @Intercompany, @Account, @Description, @CpyNumber, @AcctDesc
END

CLOSE curCompanies
DEALLOCATE curCompanies

SELECT	DISTINCT ACC1.Alias
		+ ',' + RTRIM(Entity)
		+ ',' + RTRIM(ACC2.Alias)
		+ ',' + RTRIM(GLAccount)
		+ ',' + RTRIM(REPLACE(AcctDescript, ',', ' '))
		+ ',' + RTRIM(AcctType)
		+ ',' + RTRIM(GP_Period)
		+ ',' + CAST(JournalNum AS Varchar)
		+ ',' + RTRIM(TrxSource)
		+ ',' + CONVERT(Char(10), TrxDate, 101)
		+ ',' + RTRIM(REPLACE(Description, ',', ' '))
		+ ',' + CAST(Debit AS Varchar)
		+ ',' + CAST(Credit AS Varchar)
		+ ',' + CAST(Trx_Amount AS Varchar) AS TextValue
INTO	##tmpGPIntercompanyData
FROM	@tblGLData DATA
		INNER JOIN @tblAcctAlias ACC1 ON DATA.Company = ACC1.Company
		INNER JOIN @tblAcctAlias ACC2 ON DATA.Intercompany = ACC2.Company
ORDER BY 1 

SET @Query = '"SELECT ''Company,Entity,Intercompany,GLAccount,AcctDescript,AcctType,GP_Period,JournalNum,TrxSource,TrxDate,Description,Debit,Credit,Trx_Amount'' '
SET	@DOSCommand = 'BCP ' + @Query + 'UNION ALL SELECT TextValue FROM ##tmpGPIntercompanyData" QUERYOUT \\priapint01p\FTP\Blackline' + IIF(@JustTest = 1, '\Test\', '') + '\IMCC_Intercompany_' + @DatePortion + '.txt -c -t, -T'

EXECUTE Master.dbo.xp_cmdshell @DOSCommand, No_output 

DROP TABLE IF EXISTS ##tmpGPIntercompanyData