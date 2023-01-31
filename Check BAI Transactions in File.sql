DECLARE	@CompanyID		Int, 
		@ChekBkId		Varchar(25),
		@BAIFileName	Varchar(50) = 'BAI_20160826_0220.txt',
		@RowsInQuery	Int

DECLARE @tblBankAccount TABLE
	(Company		Varchar(5),
	ChekBkId		Varchar(30),
	BnkActNm		Varchar(30),
	CmpanyId		Int,
	LastRecvd		Date,
	ActNumSt		Varchar(20),
	Inactive		Bit)

SET NOCOUNT ON

INSERT INTO @tblBankAccount
	EXECUTE USP_Bank_Accounts

SELECT	DISTINCT CPY.*
INTO	#tmpDate
FROM	@tblBankAccount CPY
		INNER JOIN View_BAI_BankTransactions HDR ON CPY.BNKACTNM = HDR.AcctNum AND CPY.CMPANYID = HDR.CMPANYID
WHERE	HDR.BaiFileName = @BAIFileName
		AND HDR.Amount <> 0
		AND HDR.IsTransfer = 1

DECLARE curData CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	CmpanyId,
		CHEKBKID
FROM	#tmpDate

OPEN curData 
FETCH FROM curData INTO @CompanyID, @ChekBkId

SET NOCOUNT OFF

WHILE @@FETCH_STATUS = 0 
BEGIN
	SELECT	DISTINCT BAI.BAI_DetailId, 
			BAI.TrxDate, 
			BAI.AbaNum, 
			BAI.Currency, 
			BAI.AcctNum, 
			BAI.AcctName,
			BAI_HeaderId AS FK_Bank_HeaderId,
			BAI.[Description], 
			BAI.BAI_Code, 
			BAI.Amount, 
			BAI.Serial_Num,
			BAI.Ref_Num, 
			BAI.Detail, 
			BAI.UploadDate, 
			BAI.IsRecon, 
			BAI.ReconDate, 
			BAI.Cmpanyid,
			BAI.Company,
			BAI.XferFromAcct,
			BAI.ACTNUMST,
			CHEKBKIDFROM = (SELECT SEC.CHEKBKID FROM #tmpDate SEC WHERE SEC.CmpanyId = BAI.CmpanyId AND SEC.BNKACTNM = BAI.XferFromAcct),
			ACTNUMSTFROM = (SELECT SEC.ACTNUMST FROM #tmpDate SEC WHERE SEC.CmpanyId = BAI.CmpanyId AND SEC.BNKACTNM = BAI.XferFromAcct)
	INTO	#tmpQueryData
	FROM	View_BAI_BankTransactions BAI
	WHERE	BAI.IsTransfer = 1
			AND BAI.Detail <> 'REGN LOAN TRANS'
			AND BAI.IsRecon = 0
			AND BAI.BAIFileName = @BAIFileName
			AND BAI.CmpanyId = @CompanyID
			AND BAI.AcctName = @ChekBkId
	ORDER BY 
			BAI.TrxDate, 
			BAI.Serial_Num, 
			BAI.Amount

	SET @RowsInQuery = @@ROWCOUNT

	PRINT 'Company Id: ' + CAST(@CompanyID AS Varchar) + ' Check Id: ' + @ChekBkId + ' Transactions: ' + CAST(@RowsInQuery AS Varchar)

	IF @RowsInQuery > 0
		SELECT * FROM #tmpQueryData

	DROP TABLE #tmpQueryData

	FETCH FROM curData INTO @CompanyID, @ChekBkId
END

CLOSE curData
DEALLOCATE curData

DROP TABLE #tmpDate