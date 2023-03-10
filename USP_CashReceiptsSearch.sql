ALTER PROCEDURE [dbo].[USP_CashReceiptsSearch]
		@CompanyId		Varchar(5),
		@Container		Varchar(20) = Null,
		@ProNumber		Varchar(20) = Null,
		@Reference		Varchar(20) = Null,
		@AllCompanyes	Bit = 1,
		@UserId			Varchar(25) = 'SQLSERVER'
AS
DECLARE	@Query			Varchar(Max),
		@OpenBalance	Varchar(20)

DELETE CashReceiptSearch WHERE UserId = @UserId

IF @ProNumber IS NOT Null
	SET @ProNumber = '%' + RTRIM(@ProNumber) + '%'

IF @Reference IS NOT Null
	SET @Reference = '%' + RTRIM(@Reference) + '%'

IF @Container IS NOT Null
	SET @Container = '%' + RTRIM(@Container) + '%'

INSERT INTO CashReceiptSearch
		(UserId
		,Company
		,ProNumber
		,InvoiceTotal
		,Reference
		,Container
		,CustomerNumber
		,Customer
		,OpenBalance)
SELECT	@UserId
		,HED.Company
		,dbo.PADR(LTRIM(InvoiceNumber), 12, ' ') AS ProNumber
		,dbo.PADL('$ ' + LTRIM(RTRIM(CONVERT(Char(12), InvoiceTotal, 1))), 12, ' ') AS InvoiceTotal
		,dbo.PADR(BillToRef, 25, ' ') AS Reference
		,dbo.PADR(Equipment, 14, ' ') AS Container
		,CustomerNumber
		,Null AS Customer
		,dbo.PADL('$ 0.00', 15, ' ') AS OpenBalance
FROM	FSI_ReceivedDetails FSI
		INNER JOIN FSI_ReceivedHeader HED ON FSI.BatchID = HED.BatchId
		LEFT JOIN (	SELECT	BatchId, DetailId, MAX(RecordCode) AS Equipment 
					FROM	FSI_ReceivedSubDetails 
					WHERE	RecordType = 'EQP'
							AND (@Container IS Null OR (@Container IS NOT Null AND PATINDEX(@Container, RecordCode) > 0))
					GROUP BY BatchId, DetailId) EQU ON FSI.BatchID = EQU.BatchId AND FSI.DetailId = EQU.DetailId
WHERE	(@AllCompanyes = 1 OR (@AllCompanyes = 0 AND HED.Company = @CompanyId))
		AND (@ProNumber IS Null OR (@ProNumber IS NOT Null AND InvoiceNumber LIKE @ProNumber))
		AND (@Reference IS Null OR (@Reference IS NOT Null AND BillToRef LIKE @Reference))
		AND (@Container IS Null OR (@Container IS NOT Null AND Equipment LIKE @Container))

DECLARE SearchRows CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT Company FROM CashReceiptSearch WHERE UserId = @UserId

OPEN SearchRows 
FETCH FROM SearchRows INTO @CompanyId

WHILE @@FETCH_STATUS = 0 
BEGIN
	-- Customer Names
	SET @Query = 'UPDATE CashReceiptSearch
	SET		Customer = dbo.PADL(CustName, 40, '' '')
	FROM	(
	SELECT	CustNmbr, CustName 
	FROM	ILSGP01.' + @CompanyId + '.dbo.RM00101 GP
			INNER JOIN CashReceiptSearch CR ON GP.CustNmbr = CR.CustomerNumber AND CR.Company = ''' + @CompanyId + ''' AND CR.UserId = ''' + @UserId + ''') REC
	WHERE	CashReceiptSearch.CustomerNumber = REC.CustNmbr
			AND CashReceiptSearch.Company = ''' + @CompanyId + ''' 
			AND CashReceiptSearch.UserId = ''' + @UserId + ''''

	EXECUTE(@Query)

	-- Open Balances
	SET @Query = 'UPDATE CashReceiptSearch
	SET		OpenBalance = dbo.PADL(''$ '' + LTRIM(RTRIM(CONVERT(Char(12), CurTrxAm, 1))), 12, '' '')
	FROM	(
	SELECT	DocNumbr, CurTrxAm 
	FROM	ILSGP01.' + @CompanyId + '.dbo.RM20101 GP
			INNER JOIN CashReceiptSearch CR ON GP.DocNumbr = CR.ProNumber AND CR.Company = ''' + @CompanyId + ''' AND CR.UserId = ''' + @UserId + ''') REC
	WHERE	CashReceiptSearch.ProNumber = REC.DocNumbr
			AND CashReceiptSearch.Company = ''' + @CompanyId + ''' 
			AND CashReceiptSearch.UserId = ''' + @UserId + ''''

	EXECUTE(@Query)

	FETCH FROM SearchRows INTO @CompanyId
END

CLOSE SearchRows
DEALLOCATE SearchRows

/*
SELECT * FROM CashReceiptSearch WHERE UserId = 'cflores'

EXECUTE USP_CashReceiptsSearch 'IMC', 'TTNU332421', Null, Null, 1, 'cflores'
*/