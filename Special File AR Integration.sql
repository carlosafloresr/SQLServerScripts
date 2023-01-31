SET NOCOUNT ON

DECLARE	@Integration	varchar(6) = 'BALAR',
		@BatchId		Varchar(25),
		@Company		Varchar(5) = 'EMP0',
		@RunDate		Date = GETDATE(),
		@DatePortion	Varchar(15)

SET @DatePortion	= dbo.PADL(MONTH(@RunDate), 2, '0') + dbo.PADL(DAY(@RunDate), 2, '0') + RIGHT(dbo.PADL(YEAR(@RunDate), 4, '0'), 2) + dbo.PADL(DATEPART(HOUR, GETDATE()), 2, '0') + dbo.PADL(DATEPART(MINUTE, GETDATE()), 2, '0')
SET @BatchId		= @Integration + @DatePortion

DECLARE	@tblBalances Table (
		CustomerId		Varchar(12),
		InvoiceNum		Varchar(25),
		InvDate			Date,
		PostingDate		Date,
		Amount			Numeric(10,2),
		DEBAccount		Varchar(20),
		CRDAccount		Varchar(20),
		Description		Varchar(30))

INSERT INTO @tblBalances
SELECT	[GP_Account]
		,[Invoice]
		,[InvDate]
		,CAST('10/18/2019' AS Date) AS PostingDate
		,Total_Invoiced
		,'0-00-1050' AS DEBAccount
		,'0-05-1101' AS CRDAccount
		,LEFT(CASE WHEN [Order] IS Null OR [Order] = 'NA' OR [Order] = '' THEN RTRIM([Invoice]) + '/' + RTRIM(ProLd) ELSE RTRIM([Order]) + '/' + RTRIM(ProLd) END, 30) AS Description
FROM	[Integrations].[dbo].TISCNI2

DECLARE	@DOCNUMBR		varchar(20)
		,@DOCDESCR		varchar(30)
		,@CUSTNMBR		varchar(15)
		,@DOCDATE		date
		,@DUEDATE		date
		,@DOCAMNT		money
		,@SLSAMNT		money
		,@RMDTYPAL		int
		,@DISTTYPE		int
		,@ACTNUMST		varchar(15)
		,@DEBITAMT		money
		,@CRDTAMNT		money
		,@DistRef		varchar(30)
		,@UserId		varchar(25) = 'AR Integrator'
		,@PostingDate	date

DELETE	ReceivedIntegrations
WHERE	Company = @Company
		AND BatchId = @BatchId

DELETE	Integrations_AR
WHERE	Company = @Company
		AND BatchId = @BatchId

DECLARE curData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	InvoiceNum,
		'INV ' + InvoiceNum,
		CustomerId,
		InvDate,
		DATEADD(dd, 30, InvDate),
		ABS(Amount),
		ABS(Amount),
		CASE WHEN Amount > 0 THEN 1 ELSE 7 END,
		CASE WHEN Amount > 0 THEN 2 ELSE 19 END,
		CASE WHEN Amount > 0 THEN DEBAccount ELSE CRDAccount END,
		ABS(Amount),
		0,
		Description,
		PostingDate
FROM	@tblBalances
UNION
SELECT	InvoiceNum,
		'INV ' + InvoiceNum,
		CustomerId,
		InvDate,
		DATEADD(dd, 30, InvDate),
		ABS(Amount),
		ABS(Amount),
		CASE WHEN Amount > 0 THEN 1 ELSE 7 END,
		CASE WHEN Amount > 0 THEN 9 ELSE 3 END,
		CASE WHEN Amount > 0 THEN CRDAccount ELSE DEBAccount END,
		0,
		ABS(Amount),
		Description,
		PostingDate
FROM	@tblBalances
ORDER BY 1

OPEN curData 
FETCH FROM curData INTO @DOCNUMBR, @DOCDESCR, @CUSTNMBR, @DOCDATE, @DUEDATE, @DOCAMNT, @SLSAMNT, @RMDTYPAL,
						@DISTTYPE, @ACTNUMST, @DEBITAMT, @CRDTAMNT, @DistRef, @PostingDate

WHILE @@FETCH_STATUS = 0 
BEGIN
	EXECUTE USP_Integrations_AR @Integration, @Company, @BatchId, @DOCNUMBR, @DOCDESCR, @CUSTNMBR, @DOCDATE, @DUEDATE,
								@DOCAMNT, @SLSAMNT, @RMDTYPAL, @DISTTYPE, @ACTNUMST, @DEBITAMT, @CRDTAMNT, @DistRef, 
								Null, Null, Null, Null, 0, 0, 0, @UserId, @PostingDate

	FETCH FROM curData INTO @DOCNUMBR, @DOCDESCR, @CUSTNMBR, @DOCDATE, @DUEDATE, @DOCAMNT, @SLSAMNT, @RMDTYPAL,
							@DISTTYPE, @ACTNUMST, @DEBITAMT, @CRDTAMNT, @DistRef, @PostingDate
END

CLOSE curData
DEALLOCATE curData

SELECT	*
FROM	Integrations_AR
WHERE	Company = @Company
		AND BatchId = @BatchId

PRINT @BatchId

IF @@ERROR = 0
	INSERT INTO ReceivedIntegrations(Integration, Company, BatchId) VALUES (@Integration, @Company, @BatchId)