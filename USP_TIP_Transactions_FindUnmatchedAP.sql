/*
EXECUTE USP_TIP_Transactions_FindUnmatchedAP 'GSA','243','GLSO','1565','97-103082'
EXECUTE USP_TIP_Transactions_FindUnmatchedAP 'NONE'
*/
ALTER PROCEDURE USP_TIP_Transactions_FindUnmatchedAP
		@MainCompany	Varchar(5),
		@VendorId		Varchar(20) = Null,
		@SubCompany		Varchar(5) = Null,
		@CustomerId		Varchar(20) = Null,
		@AR_Document	Varchar(30) = Null
AS
SET NOCOUNT ON

DECLARE	@Query			Varchar(MAX),
		@AR_DocumentTmp	Varchar(30),	
		@AR_DocAmount	Numeric(10,2)

DECLARE	@tblAPTransactions Table (
		AP_Document		Varchar(30),
		AP_DocAmount	Numeric(10,2),
		AP_BatchNumber	Varchar(30),
		AR_Document		Varchar(30))

DECLARE	@tblAPUnmatched Table (
		AP_Document		Varchar(30),
		AP_DocType		Varchar(12),
		AP_DocDate		Date,
		AP_DocAmount	Numeric(10,2),
		AP_DocBalance	Numeric(10,2),
		AP_BatchNumber	Varchar(30),
		AP_Description	Varchar(30),
		PossibleMatch	Bit,
		Linked			Bit)

IF @SubCompany IS NOT Null
BEGIN
	SELECT	@AR_DocAmount = AR_DocAmount
	FROM	TIP_Transactions
	WHERE	AP_Company = @MainCompany 
			AND AR_Company = @SubCompany 
			AND VendorId = @VendorId 
			AND CustomerId = @CustomerId
			AND AR_Document = @AR_Document

	DECLARE curAPData CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT	LEFT(RTRIM(LTRIM(AR_Document)), 9) 
	FROM	TIP_Transactions
	WHERE	AP_Company = @MainCompany 
			AND AR_Company = @SubCompany 
			AND VendorId = @VendorId 
			AND CustomerId = @CustomerId

	OPEN curAPData 
	FETCH FROM curAPData INTO @AR_DocumentTmp

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET	@Query = N'SELECT DOCNUMBR,
				CASE WHEN DOCTYPE < 5 THEN 1 ELSE -1 END * DocAmnt AS DocAmnt,
				BACHNUMB,
				''' + @AR_DocumentTmp + '''
		FROM	' + RTRIM(@MainCompany) + '.dbo.PM20000 
		WHERE	VendorId = ''' + @VendorId + ''' 
				AND LEFT(DOCNUMBR, 9) = ''' + @AR_DocumentTmp + ''''

		INSERT INTO @tblAPTransactions
		EXECUTE(@Query)

		FETCH FROM curAPData INTO @AR_DocumentTmp
	END

	CLOSE curAPData
	DEALLOCATE curAPData

	SELECT	*
	INTO	##tmpTIPARData
	FROM	@tblAPTransactions

	SET	@Query = N'SELECT	DOCNUMBR,
			CASE WHEN DOCTYPE = 1 THEN ''Invoice''
				 WHEN DOCTYPE = 5 THEN ''Credit Memo'' 
				 ELSE ''Other''
			END AS DOCTYPE,
			DOCDATE,
			CASE WHEN DOCTYPE < 5 THEN 1 ELSE -1 END * DOCAMNT AS DOCAMNT,
			CASE WHEN DOCTYPE < 5 THEN 1 ELSE -1 END * CURTRXAM AS CURTRXAM,
			BACHNUMB,
			RTRIM(TRXDSCRN) AS AP_Description,
			CASE WHEN (CASE WHEN DOCTYPE < 5 THEN 1 ELSE -1 END * DOCAMNT) = ' + CAST(@AR_DocAmount AS Varchar) + ' THEN 1 ELSE 0 END AS PossibleMatch,
			0 AS Linked
	FROM	' + RTRIM(@MainCompany) + '.dbo.PM20000
	WHERE	VendorId = ''' + @VendorId +  '''
			AND DocNumbr NOT IN (SELECT AP_Document FROM ##tmpTIPARData)
			AND DocType < 9
			AND CURTRXAM > 0
			AND VOIDED = 0
	UNION
	SELECT	DOCNUMBR,
			CASE WHEN DOCTYPE = 1 THEN ''Invoice'' 
				 WHEN DOCTYPE = 5 THEN ''Credit Memo'' 
				 ELSE ''Other''
			END AS DOCTYPE,
			DOCDATE,
			CASE WHEN DOCTYPE < 5 THEN 1 ELSE -1 END * DOCAMNT AS DOCAMNT,
			CASE WHEN DOCTYPE < 5 THEN 1 ELSE -1 END * CURTRXAM AS CURTRXAM,
			BACHNUMB,
			RTRIM(TRXDSCRN) AS AP_Description,
			0 AS PossibleMatch,
			1 AS Linked
	FROM	' + RTRIM(@MainCompany) + '.dbo.PM20000
	WHERE	VendorId = ''' + @VendorId +  '''
			AND DocNumbr IN (SELECT AP_Document FROM ##tmpTIPARData WHERE AR_Document = ''' + @AR_Document + ''')
			AND DocType < 9
			AND CURTRXAM > 0
			AND VOIDED = 0'

	INSERT INTO @tblAPUnmatched
	EXECUTE(@Query)

	DROP TABLE ##tmpTIPARData
END

SELECT	*
FROM	@tblAPUnmatched
ORDER BY
		Linked DESC,
		PossibleMatch DESC, 
		AP_DocBalance