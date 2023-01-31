DECLARE	@RunDate		Date = GETDATE(),
		@JustSummary	Bit = 0,
		@CustomerId		Varchar(25) = Null

DECLARE	@Company	Varchar(5),
		@Query		Varchar(Max),
		@CharDate	Varchar(10) = CAST(@RunDate AS Varchar)

DECLARE @tblSummary Table (
		[Company]				Varchar(5),
		[CustomerId]			varchar(15) NOT NULL,
		[CustomerName]			varchar(65) NOT NULL,
		[CustomerTerms]			varchar(21) NOT NULL,
		[CustomerClass]			varchar(15) NOT NULL,
		[Total_Due]				numeric(12, 2) NULL,
		[Current]				numeric(12, 2) NULL,
		[31_to_60_Days]			numeric(12, 2) NULL,
		[61_to_90_Days]			numeric(12, 2) NULL,
		[91_to_180_Days]		numeric(12, 2) NULL,
		[Over_180]				numeric(12, 2) NULL,
		[Last_Payment_Date]		date NULL,
		[Last_Payment_Amount]	numeric(12, 2) NULL)

DECLARE @tblDetails Table (
		[Company]				Varchar(5),
		[CustomerId]			varchar(15) NOT NULL,
		[CustomerName]			varchar(65) NOT NULL,
		[CustomerTerms]			varchar(21) NOT NULL,
		[CustomerClass]			varchar(15) NOT NULL,
		[DocumentType]			varchar(14) NOT NULL,
		[DocumentNumber]		varchar(21) NOT NULL,
		[DocumentDate]			date NULL,
		[DueDate]				date NULL,
		[Last_Payment_Date]		date NULL,
		[Document_Amount]		numeric(12, 2) NULL,
		[Unapplied_Amount]		numeric(12, 2) NULL,
		[Current]				numeric(12, 2) NULL,
		[0_to_30_Days]			numeric(12, 2) NULL,
		[31_to_60_Days]			numeric(12, 2) NULL,
		[61_to_90_Days]			numeric(12, 2) NULL,
		[91_to_180_Days]		numeric(12, 2) NULL,
		[Over_180]				numeric(12, 2) NULL)

SET NOCOUNT ON

DECLARE curGP_Companies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	InterId
FROM	DYNAMICS.dbo.View_AllCompanies
WHERE	InterId NOT IN ('ATEST','FIDMO')

OPEN curGP_Companies 
FETCH FROM curGP_Companies INTO @Company

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT @Company

	IF @JustSummary = 1
	BEGIN
		SET @Query = N'SELECT ''' + RTRIM(@Company) + ''' AS Company,
					RTRIM(CM.CUSTNMBR) AS Customer_ID, 
					RTRIM(CM.CUSTNAME) AS Customer_Name,
					RTRIM(CM.PYMTRMID) AS Customer_Terms, 
					RTRIM(CM.CUSTCLAS) AS Customer_Class,
					SUM(CASE WHEN RM.RMDTYPAL < 7 THEN RM.CURTRXAM ELSE RM.CURTRXAM * -1 END) AS Total_Due,
					SUM(CASE WHEN DATEDIFF(d, RM.DUEDATE, ''' + @CharDate + ''') < 31 AND RM.RMDTYPAL < 7 THEN RM.CURTRXAM WHEN DATEDIFF(d, RM.DOCDATE, ''' + @CharDate + ''') < 31 AND RM.RMDTYPAL > 6 THEN RM.CURTRXAM *-1 ELSE 0 END) AS [Current],
					SUM(CASE WHEN DATEDIFF(d, RM.DUEDATE, ''' + @CharDate + ''') BETWEEN 31 AND 60 AND RM.RMDTYPAL < 7 THEN RM.CURTRXAM WHEN DATEDIFF(d, RM.DOCDATE, ''' + @CharDate + ''') BETWEEN 31 AND 60 AND RM.RMDTYPAL > 6 THEN RM.CURTRXAM * -1 ELSE 0 END) AS [31_to_60_Days],
					SUM(CASE WHEN DATEDIFF(d, RM.DUEDATE, ''' + @CharDate + ''') BETWEEN 61 AND 90 AND RM.RMDTYPAL < 7 THEN RM.CURTRXAM WHEN DATEDIFF(d, RM.DOCDATE, ''' + @CharDate + ''') BETWEEN 61 AND 90 AND RM.RMDTYPAL > 6 THEN RM.CURTRXAM * -1 ELSE 0 END) AS [61_to_90_Days],
					SUM(CASE WHEN DATEDIFF(d, RM.DUEDATE, ''' + @CharDate + ''') BETWEEN 91 AND 180 AND RM.RMDTYPAL < 7 THEN RM.CURTRXAM WHEN DATEDIFF(d, RM.DOCDATE, ''' + @CharDate + ''') BETWEEN 61 AND 90 AND RM.RMDTYPAL > 6 THEN RM.CURTRXAM * -1 ELSE 0 END) AS [91_to_180_Days],
					SUM(CASE WHEN DATEDIFF(d, RM.DUEDATE, ''' + @CharDate + ''') > 180 AND RM.RMDTYPAL < 7 THEN RM.CURTRXAM WHEN DATEDIFF(d, RM.DOCDATE, ''' + @CharDate + ''') > 90 AND RM.RMDTYPAL > 6 THEN RM.CURTRXAM *-1 ELSE 0 END) AS [Over_180],
					CAST(CS.LASTPYDT AS Date) AS Last_Payment_Date,
					CAST(CS.LPYMTAMT AS Numeric(12,2)) AS Last_Payment_Amount 
			FROM	' + RTRIM(@Company) + '.dbo.RM20101 RM 
					INNER JOIN ' + RTRIM(@Company) + '.dbo.RM00101 CM ON RM.CUSTNMBR = CM.CUSTNMBR
					INNER JOIN ' + RTRIM(@Company) + '.dbo.RM00103 CS ON RM.CUSTNMBR = CS.CUSTNMBR
			WHERE	RM.VOIDSTTS = 0 
					AND RM.CURTRXAM <> 0
			GROUP BY 
					CM.CUSTNMBR, 
					CM.CUSTNAME, 
					CM.PYMTRMID, 
					CM.CUSTCLAS, 
					CM.PRCLEVEL, 
					CS.LASTPYDT,
					CS.LPYMTAMT'

		INSERT INTO @tblSummary
		EXECUTE(@Query)
	END
	ELSE
	BEGIN
		SET @Query = N'SELECT ''' + RTRIM(@Company) + ''' AS Company,
					CM.CUSTNMBR AS Customer_ID,
					CM.CUSTNAME AS Customer_Name,
					CM.PYMTRMID AS Customer_Terms,
					CM.CUSTCLAS AS Customer_Class,
					CASE RM.RMDTYPAL
						  WHEN 1 THEN ''Sale / Invoice''
						  WHEN 3 THEN ''Debit Memo''
						  WHEN 4 THEN ''Finance Charge''
						  WHEN 5 THEN ''Service Repair''
						  WHEN 6 THEN ''Warranty''
						  WHEN 7 THEN ''Credit Memo''
						  WHEN 8 THEN ''Return''
						  WHEN 9 THEN ''Payment''
						  ELSE ''Other''
					END AS Document_Type,
					RM.DOCNUMBR AS Document_Number,
					CAST(RM.DOCDATE AS Date) AS Document_Date,
					CAST(RM.DUEDATE AS Date) AS Due_Date,
					CAST(S.LASTPYDT AS Date) AS Last_Payment_Date,
					CASE WHEN RM.RMDTYPAL < 7 THEN RM.ORTRXAMT ELSE RM.ORTRXAMT * -1 END AS Document_Amount,
					CASE WHEN RM.RMDTYPAL < 7 THEN RM.CURTRXAM ELSE RM.CURTRXAM * -1 END AS Unapplied_Amount,
					CASE WHEN DATEDIFF(d, RM.DUEDATE, ''' + @CharDate + ''') <= 0 AND RM.RMDTYPAL < 7 THEN RM.CURTRXAM WHEN DATEDIFF(d, RM.DOCDATE, ''' + @CharDate + ''') <= 0 AND RM.RMDTYPAL > 6 THEN RM.CURTRXAM *-1 ELSE 0 END AS [Current],
					CASE WHEN DATEDIFF(d, RM.DUEDATE, ''' + @CharDate + ''') between 1 AND 30 AND RM.RMDTYPAL < 7 THEN RM.CURTRXAM WHEN DATEDIFF(d, RM.DOCDATE, ''' + @CharDate + ''') between 1 AND 30 AND RM.RMDTYPAL > 6 THEN RM.CURTRXAM * -1 ELSE 0 END AS [0_to_30_Days],
					CASE WHEN DATEDIFF(d, RM.DUEDATE, ''' + @CharDate + ''') between 31 AND 60 AND RM.RMDTYPAL < 7 THEN RM.CURTRXAM WHEN DATEDIFF(d, RM.DOCDATE, ''' + @CharDate + ''') between 31 AND 60 AND RM.RMDTYPAL > 6 THEN RM.CURTRXAM * -1 ELSE 0 END AS [31_to_60_Days],
					CASE WHEN DATEDIFF(d, RM.DUEDATE, ''' + @CharDate + ''') between 61 AND 90 AND RM.RMDTYPAL < 7 THEN RM.CURTRXAM WHEN DATEDIFF(d, RM.DOCDATE, ''' + @CharDate + ''') between 61 AND 90 AND RM.RMDTYPAL > 6 THEN RM.CURTRXAM * -1 ELSE 0 END AS [61_to_90_Days],
					CASE WHEN DATEDIFF(d, RM.DUEDATE, ''' + @CharDate + ''') between 61 AND 90 AND RM.RMDTYPAL < 7 THEN RM.CURTRXAM WHEN DATEDIFF(d, RM.DOCDATE, ''' + @CharDate + ''') between 91 AND 180 AND RM.RMDTYPAL > 6 THEN RM.CURTRXAM * -1 ELSE 0 END AS [91_to_180_Days],
					CASE WHEN DATEDIFF(d, RM.DUEDATE, ''' + @CharDate + ''') > 90 AND RM.RMDTYPAL < 7 THEN RM.CURTRXAM WHEN DATEDIFF(d, RM.DOCDATE, ''' + @CharDate + ''') > 180 AND RM.RMDTYPAL > 6 THEN RM.CURTRXAM *-1 ELSE 0 END AS [Over_180] 
			FROM	' + RTRIM(@Company) + '.dbo.RM20101 RM 
					INNER JOIN ' + RTRIM(@Company) + '.dbo.RM00101 CM ON RM.CUSTNMBR = CM.CUSTNMBR
					INNER JOIN ' + RTRIM(@Company) + '.dbo.RM00103 S ON RM.CUSTNMBR = S.CUSTNMBR
			WHERE	RM.VOIDSTTS = 0 
					AND RM.CURTRXAM <> 0'

			INSERT INTO @tblDetails
			EXECUTE(@Query)
	END

	FETCH FROM curGP_Companies INTO @Company
END

CLOSE curGP_Companies
DEALLOCATE curGP_Companies

IF @JustSummary = 1
	SELECT	*
	FROM	@tblSummary
	ORDER BY Company, CustomerId
ELSE
	SELECT	*
	FROM	@tblDetails
	ORDER BY Company, CustomerId, DocumentNumber