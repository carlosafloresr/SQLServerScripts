DECLARE @Query		Varchar(MAX),
		@Company	Varchar(5)

DECLARE @tblGPPeriod Table (GPPeriod Varchar(2))

DECLARE @tblAccountScrubBCatt Table (
	[DB]				NVARCHAR(MAX),
	[RowKey]			NVARCHAR(MAX),
	[Year]				INT,
	[Period]			INT,
	[ACTINDX]			INT,
	[Account]			NVARCHAR(MAX),
	[JournalEntry]		NVARCHAR(MAX),
	[SourceId]			NVARCHAR(MAX),
	[SourceTransaction] NVARCHAR(MAX),
	[OrigMasterId]		NVARCHAR(MAX),
	[OrigMasterName]	NVARCHAR(MAX),
	[Reference]			NVARCHAR(MAX),
	[Description]		NVARCHAR(MAX),
	[TransactionSource] NVARCHAR(MAX),
	[TransactionDate]	NVARCHAR(MAX),
	[LastModified]		NVARCHAR(MAX),
	[Amount]			NUMERIC(19,5),
	[Sorter]			NUMERIC(19,5))

DECLARE @PeriodStart	NVARCHAR(2)
DECLARE @Account3		NVARCHAR(4) = '1865'

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	DISTINCT CompanyId
FROM	GPCustom.dbo.Companies 
WHERE	CompanyId IN ('AIS','DNJ','GIS','HMIS','IMC','OIS','PDS','GLSO')

OPEN curCompanies 
FETCH FROM curCompanies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = N'(SELECT (MAX(PERIODID)-1) FROM ' + @Company + '.dbo.SY40100 WHERE YEAR1 = YEAR(GETDATE()) AND ODESCTN = ''General Entry'' AND PERIODDT <= GETDATE())'

	DELETE @tblGPPeriod

	INSERT INTO @tblGPPeriod
	EXECUTE(@Query)

	SET @PeriodStart = (SELECT GPPeriod - 3 FROM @tblGPPeriod)

	SET @Query = N'SELECT ''' + @Company + ''' AS "DB"
			,gl.DEX_ROW_ID	AS "RowKey"
			,gl.OPENYEAR	AS "Year"
			,gl.PERIODID	AS "Period"
			,gl.ACTINDX		AS "ACTINDX"
			,CONCAT(RTRIM(LTRIM(ind.ACTNUMBR_1)),''-'',RTRIM(LTRIM(ind.ACTNUMBR_2)),''-'',RTRIM(LTRIM(ind.ACTNUMBR_3))) AS "Account"
			,gl.JRNENTRY	AS "JournalEntry"
			,gl.SOURCDOC	AS "SourceId"
			,gl.ORGNTSRC	AS "SourceTransaction"
			,gl.ORMSTRID	AS "OrigMasterId"
			,gl.ORMSTRNM	AS "OrigMasterName"
			,gl.REFRENCE	AS "Reference"
			,gl.DSCRIPTN	AS "Description"
			,gl.TRXSORCE	AS "TransactionSource"
			,CONVERT(CHAR(10), gl.TRXDATE, 120)	AS "TransactionDate"
			,CASE 
				WHEN CONVERT(DATE, gl.LSTDTEDT) = ''1900-01-01''
				THEN ''''
				ELSE CONVERT(CHAR(10), gl.LSTDTEDT, 120)
				END			AS "LastModified"
			,CASE
				WHEN gl.DEBITAMT > 0 
				THEN gl.DEBITAMT
				ELSE -(gl.CRDTAMNT)
				END	AS "Amount"
			,CASE
				WHEN gl.DEBITAMT > 0 
				THEN gl.DEBITAMT
				ELSE gl.CRDTAMNT
				END	AS "Sorter"
		FROM ' + @Company + '.dbo.GL20000 gl WITH (NOLOCK)
			LEFT OUTER JOIN ' + @Company + '.dbo.GL00105 ind WITH (NOLOCK) ON gl.ACTINDX = ind.ACTINDX
		WHERE ind.ACTNUMBR_3 = ''' + @Account3 + '''
			AND gl.PERIODID >= ''' + @PeriodStart + ''''
		
	INSERT INTO @tblAccountScrubBCatt
	EXECUTE(@Query)

	FETCH FROM curCompanies INTO @Company
END

CLOSE curCompanies
DEALLOCATE curCompanies

SELECT	*
FROM	@tblAccountScrubBCatt