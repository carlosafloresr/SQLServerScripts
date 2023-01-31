DECLARE @RunDate		Date = '10/01/2022',
		@Company		Varchar(5),
		@Query			Varchar(MAX)

DECLARE	@tblGPBalance		Table (
		[GP_Company]		Varchar(10),
		[Entity ID]			Char(2),
		[Account Number]	Varchar(15),
		LOB					Char(1),
		[Key 4]				Char(1),
		[Key 5]				Char(1),
		[Key 6]				Char(1),
		[Key 7]				Char(1),
		[Key 8]				Char(1),
		[Key 9]				Char(1),
		[Key 10]			Char(1),
		[Period End Date]	Date,
		[Subledger Reporting Balance]	Char(1),
		[Subledger Alternate Balance]	Char(1),
		[Subledger Account Balance]		Numeric(12,2))

DECLARE curGPBalances CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	CompanyId
FROM	GPCustom.dbo.Companies_Parameters
WHERE	ParameterCode = 'BLACKLINE_ENTITYID'

OPEN curGPBalances 
FETCH FROM curGPBalances INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = N'SELECT COMP.CompanyId, COMP.ParString AS [Entity ID],
		RTRIM(GLA5.ACTNUMST) AS [Account Number],
		'''' AS LOB,
		'''' AS [Key 4],
		'''' AS [Key 5],
		'''' AS [Key 6],
		'''' AS [Key 7],
		'''' AS [Key 8],
		'''' AS [Key 9],
		'''' AS [Key 10],
		CAST(FISC.EndDate AS Date) AS [Period End Date],
		'''' AS [Subledger Reporting Balance],
		'''' AS [Subledger Alternate Balance],
		SUM(ASUM.DEBITAMT - ASUM.CRDTAMNT) AS Balance
FROM	' + @Company + '.dbo.GL11110 ASUM
		INNER JOIN ' + @Company + '.dbo.GL00105 GLA5 ON ASUM.ACTINDX = GLA5.ACTINDX
		INNER JOIN ' + @Company + '.dbo.GL00102 TCAT ON ASUM.ACCATNUM = TCAT.ACCATNUM
		INNER JOIN Dynamics.dbo.View_FiscalPeriod FISC ON ''' + CONVERT(Char(10), @RunDate, 101) + ''' BETWEEN FISC.StartDate AND FISC.EndDate AND ASUM.YEAR1 = FISC.Year1 AND ASUM.PERIODID <= FISC.PeriodId
		LEFT JOIN GPCustom.dbo.Companies_Parameters COMP ON COMP.CompanyId = ''' + @Company + ''' AND COMP.ParameterCode = ''BLACKLINE_ENTITYID''
WHERE	TCAT.ACCATDSC IN (''Accounts Payable'',''Accounts Receivable'')
		AND GLA5.ACTNUMST IN (''0-00-1050'',''0-00-2070'',''0-00-2000'',''0-00-2050'')
GROUP BY COMP.CompanyId, COMP.ParString, GLA5.ACTNUMST, TCAT.ACCATDSC, FISC.EndDate, FISC.PeriodId
ORDER BY 2,4,3'

	INSERT INTO @tblGPBalance
	EXECUTE(@Query)

	FETCH FROM curGPBalances INTO @Company
END

CLOSE curGPBalances
DEALLOCATE curGPBalances

SELECT	*
FROM	@tblGPBalance
ORDER BY 2,4,3




/*
,'0-0-4999','0-00-2000','0-00-2050','0-00-2070')

FORMAT(SUM(CASE WHEN ASUM.PERIODID <= FISC.PeriodId THEN ASUM.DEBITAMT - ASUM.CRDTAMNT ELSE 0 END), 'N', 'en-us') AS Balance

SELECT	SUM(CRDTAMNT - DEBITAMT) AS AMOUNT
FROM	GL20000
WHERE	PERIODID <= 3
		AND SOURCDOC LIKE 'PM%'
		AND VOIDED = 0
		AND ACTINDX = 205

SELECT * FROM Dynamics.dbo.View_FiscalPeriod WHERE YEAR1 = 2022
*/