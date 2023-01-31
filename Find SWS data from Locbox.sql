/*
EXECUTE USP_CashReceipt_ValidateInSWS 'AIS', 'LCKBX051319120000'
*/
CREATE PROCEDURE USP_CashReceipt_ValidateInSWS
		@Company	Varchar(5),
		@BatchId	Varchar(25),
		@RecordId	Int = Null
AS
SET NOCOUNT ON

DECLARE	@Amount		Numeric(10,2),
		@Payment	Numeric(10,2),
		@Reference	Varchar(50),
		@Reference1	Varchar(25),
		@Reference2	Varchar(25) = Null,
		@CmpyNum	Varchar(2),
		@Customer	Varchar(12),
		@NatAcct	Varchar(12),
		@Invoice	Varchar(25),
		@Query		Varchar(max),
		@SWSAmount	Numeric(10,2),
		@Balance	Numeric(10,2),
		@WriteOff	Numeric(10,2),
		@DocDate	Date,
		@Rows		Smallint = 0

DECLARE	@tblSWS		Table (
		Code		Varchar(12), 
		Eq_Code		Varchar(15), 
		Total		Numeric(10,2), 
		Bol			Varchar(50), 
		BTRef		Varchar(50), 
		Bt_Code		Varchar(25))

DECLARE	@tblAllData	Table (
		Code		Varchar(12), 
		Eq_Code		Varchar(15), 
		Total		Numeric(10,2), 
		Bol			Varchar(25), 
		BTRef		Varchar(20), 
		Bt_Code		Varchar(15),
		NatAcct		Varchar(25) Null,
		Balance		Numeric(10,2) Null,
		Payment		Numeric(10,2) Null,
		DocDate		Date,
		RecordId	Int Null)

DECLARE @tblGP		Table (
		NatAccount	Varchar(25),
		Balance		Numeric(10,2),
		DocDate		Date)

SET	@CmpyNum	= (SELECT CompanyNumber FROM Companies WHERE CompanyId = @Company)
SET @WriteOff	= ISNULL((SELECT TOP 1 VarN FROM Parameters WHERE ParameterCode = 'AR_WRITEOFF' AND Company = @Company OR Company = 'ALL'), 1)

DECLARE curCashRecords CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	Reference,
		Payment,
		CashReceiptId
FROM	View_CashReceipt
where	Company = @Company
		AND BatchId = @BatchId
		AND ((Status < 3
		AND Orig_InvoiceNumber <> 'DATAERROR'
		AND Reference NOT IN ('0,0', '0,00', '00,00'))
		OR CashReceiptId = @RecordId)

OPEN curCashRecords 
FETCH FROM curCashRecords INTO @Reference, @Payment, @RecordId

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Reference1 = LEFT(@Reference, dbo.AT(',', @Reference, 1) - 1)
	SET @Reference2 = REPLACE(@Reference, @Reference1 + ',', '')

	SET @Query = N'SELECT Code, Eq_Code, Total, Bol, BTRef, Bt_Code FROM trk.invoice WHERE cmpy_no = ' + @CmpyNum + ' AND bol = ''' + @Reference1 + ''' OR Eq_Code = ''' + @Reference1 + ''' OR btref LIKE ''%' + @Reference1 + '%'''
	
	INSERT INTO @tblSWS (Code, Eq_Code, Total, Bol, BTRef, Bt_Code)
	EXECUTE USP_QuerySWS @Query

	SET @Rows = @@ROWCOUNT

	IF @Rows = 0 AND @Reference2 IS NOT Null
	BEGIN
		SET @Query = N'SELECT Code, Eq_Code, Total, Bol, BTRef, Bt_Code FROM trk.invoice WHERE cmpy_no = ' + @CmpyNum + ' AND bol = ''' + @Reference2 + ''' OR Eq_Code = ''' + @Reference2 + ''' OR btref LIKE ''%' + @Reference2 + '%'''
		
		INSERT INTO @tblSWS (Code, Eq_Code, Total, Bol, BTRef, Bt_Code)
		EXECUTE USP_QuerySWS @Query

		SET @Rows = @@ROWCOUNT
	END

	IF @Rows = 1
	BEGIN
		SELECT	@Customer	= Bt_Code, 
				@Invoice	= Code,
				@SWSAmount	= Total
		FROM	@tblSWS

		SET @Customer = (SELECT TOP 1 RTRIM(CUSTNMBR) FROM CustomerMaster WHERE CUSTNMBR = @Customer OR SWSCustomerId = @Customer)
		
		SET @Query = 'SELECT CPRCSTNM, CURTRXAM, DOCDATE FROM ' + @Company + '.dbo.RM20101 WHERE CUSTNMBR = ''' + @Customer + ''' AND DOCNUMBR = ''' + @Invoice + ''''
		SET @Query = @Query + 'UNION SELECT CPRCSTNM, CURTRXAM, DOCDATE FROM ' + @Company + '.dbo.RM30101 WHERE CUSTNMBR = ''' + @Customer + ''' AND DOCNUMBR = ''' + @Invoice + ''''

		INSERT INTO @tblGP
		EXECUTE(@query)

		IF @@ROWCOUNT > 0
		BEGIN
			UPDATE	@tblSWS
			SET		@NatAcct	= DATA.NatAccount,
					@Balance	= DATA.Balance,
					@DocDate	= DATA.DocDate
			FROM	@tblGP DATA
			
			INSERT INTO @tblAllData
			SELECT	Code 
					,Eq_Code
					,Total
					,Bol
					,BTRef
					,@Customer
					,@NatAcct
					,@Balance
					,@Payment
					,@DocDate
					,@RecordId
			FROM	@tblSWS
		END
		ELSE
			SET @Rows = 0
	END

	IF @Rows <> 1
	BEGIN
		SELECT	*,
				@Payment AS Payment, 
				@RecordId AS RecordId
		FROM	@tblSWS
		WHERE	Code = '**NONE**'
	END

	DELETE @tblSWS
		
	FETCH FROM curCashRecords INTO @Reference, @Payment, @RecordId
END

CLOSE curCashRecords
DEALLOCATE curCashRecords

SELECT	*
FROM	@tblAllData

DECLARE curForGPRecords CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	RecordId		
FROM	@tblAllData

OPEN curForGPRecords
FETCH FROM curForGPRecords INTO @RecordId

WHILE @@FETCH_STATUS = 0 
BEGIN
	UPDATE	CashReceipt
	SET		CashReceipt.CustomerNumber		= RECS.CustomerNumber
			,CashReceipt.NationalAccount	= RECS.NatAcct
			,CashReceipt.InvoiceNumber		= RECS.InvoiceNumber
			,CashReceipt.InvoiceDate		= RECS.InvoiceDate
			,CashReceipt.InvBalance			= RECS.Balance
			,CashReceipt.InvAmount			= RECS.InvAmount
			,CashReceipt.Equipment			= RECS.Eq_Code
			,CashReceipt.Status				= RECS.Status
	FROM	(SELECT	RecordId
					,RTRIM(DAT.Code) AS InvoiceNumber
					,CAST(DAT.DocDate AS Date) AS InvoiceDate
					,DAT.BT_Code AS CustomerNumber
					,DAT.NatAcct
					,DAT.Balance
					,DAT.Total AS InvAmount
					,DAT.Payment
					,DAT.Eq_Code
					,CASE	WHEN CSH.CustomerNumber <> DAT.BT_Code AND CSH.NationalAccount <> DAT.NatAcct THEN 8 --Invoice not for this customer
							WHEN DAT.Balance = 0 THEN 3 -- The invoice is fully paid already
							WHEN DAT.Payment = DAT.Balance THEN 4 -- Perfect match
							WHEN DAT.Payment > DAT.Balance THEN 5 -- Payment grather than current balance
							WHEN DAT.Payment < DAT.Balance - 1 THEN 6 -- Underpaid
							WHEN DAT.Payment < DAT.Balance AND DAT.Payment >= DAT.Balance - @WriteOff THEN 7 -- Writeoff
							ELSE 1 END AS Status -- Undefined
			FROM	@tblAllData DAT
					INNER JOIN CashReceipt CSH ON RecordId = CSH.CashReceiptId
			) RECS
	WHERE	CashReceipt.CashReceiptId = RECS.RecordId

	FETCH FROM curForGPRecords INTO @RecordId
END

CLOSE curForGPRecords
DEALLOCATE curForGPRecords