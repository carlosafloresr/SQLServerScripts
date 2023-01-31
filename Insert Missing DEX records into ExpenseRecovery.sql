SET NOCOUNT OFF

DECLARE	@tblTransactions Table
		(Company		varchar(5),
		VoucherNo		varchar(20),
		Vendor			varchar(30),
		ProNumber		varchar(15),
		Reference		varchar(50),
		Expense			decimal(9,2),
		Recovery		decimal(9,2),
		DocNumber		varchar(25),
		EffDate			datetime,
		InvDate			datetime,
		Trailer			varchar(20),
		Chassis			varchar(20),
		FailureReason	varchar(50),
		Recoverable		char(1),
		DriverId		varchar(12),
		DriverType		int,
		RepairType		varchar(20),
		GLAccount		varchar(12),
		RecoveryAction  varchar(25),
		Status			varchar(12),
		Notes			varchar(250),
		ItemNumber		int,
		Closed			bit,
		Source			char(2),
		RepairTypeText  varchar(15),
		DriverTypeText  char(10),
		DriverName		varchar(50),
		RecoverableText char(10),
		Division		char(2),
		StatusText		varchar(10),
		BatchId			varchar(20),
		VendorId		varchar(15),
		RecordId		int)

DECLARE	@Query			Varchar(Max),
		@Company		Varchar(5),
		@Voucher		Varchar(25),
		@VendorId		Varchar(25),
		@DocumentNo		Varchar(30),
		@Account		Varchar(25),
		@ActIndx		Int,
		@Amount			Numeric(12,2),
		@DCSTATUS		Int,
		@DSTSQNUM		Int,
		@RecordId		Int

INSERT INTO @tblTransactions
SELECT	DISTINCT IAP.Company,
		IAP.VCHNUMWK,
		LEFT(RTRIM(IAP.VendorId) + ' - ' + CASE WHEN IAP.VendorName IS Null OR IAP.VendorName = '' THEN dbo.GetVendorName(IAP.Company, IAP.VendorId) ELSE IAP.VendorName END, 30) AS Vendor,
		IAP.ProNum,
		IAP.DISTREF,
		IAP.DEBITAMT,
		0,
		IAP.DOCNUMBR,
		IAP.PSTGDATE,
		IAP.DOCDATE,
		IAP.Container,
		IAP.Chassis,
		LTRIM(dbo.PROPER(SUBSTRING(IAP.DISTREF, dbo.RAT('|', IAP.DISTREF, 1) + 1, 20))) AS FailureReason,
		ERA.Recovery,
		Null AS DriverId,
		Null AS DriverType,
		ERA.RepairType,
		IAP.ACTNUMST,
		Null AS RecoveryAction,
		'Open' AS Status,
		Null AS Notes,
		0 AS ItemNumber,
		0 AS Closed,
		'AP' AS Source,
		Null AS RepairTypeText,
		Null AS DriverTypeText,
		Null AS DriverName,
		Null AS RecoverableText,
		Null AS Division,
		'Open' AS StatusText,
		IAP.BatchId,
		IAP.VendorId,
		ROW_NUMBER() OVER (ORDER BY IAP.Company, IAP.VCHNUMWK) AS RecordId
FROM	ILSINT02.Integrations.dbo.Integrations_AP IAP
		INNER JOIN ExpenseRecoveryAccounts ERA ON RIGHT(RTRIM(IAP.ACTNUMST), 4) = ERA.Account
		LEFT JOIN ExpenseRecovery ERT ON IAP.VCHNUMWK = ERT.VOUCHERNO AND IAP.DOCNUMBR = ERT.DocNumber AND IAP.ACTNUMST = ERT.GLAccount
WHERE	Integration = 'DXP'
		AND DocDate >= DATEADD(dd, -120, GETDATE())
		AND IAP.AP_Processed = 2
		AND ERT.VOUCHERNO IS Null

DECLARE	@tblTransStatus Table (DCSTATUS	Int)
DECLARE @tblTransIndexNo Table (DSTSQNUM Int)
DECLARE	@tblTransAccount Table (DSTINDX Int)

DECLARE ER_Transactions CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	Company
		,VoucherNo
		,VendorId
		,DocNumber
		,GLAccount
		,Expense
		,RecordId
FROM	@tblTransactions

OPEN ER_Transactions 
FETCH FROM ER_Transactions INTO @Company, @Voucher, @VendorId, @DocumentNo, @Account, @Amount, @RecordId

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Query = N'SELECT DCSTATUS FROM ' + RTRIM(@Company) + '.dbo.PM00400 WHERE CNTRLNUM = ''' + RTRIM(@Voucher) + ''' AND DOCNUMBR = ''' + RTRIM(@DocumentNo) + ''' AND VENDORID = ''' + RTRIM(@VendorId) + ''''

	DELETE @tblTransStatus
	INSERT INTO @tblTransStatus
	EXECUTE(@Query)
	--PRINT @Query
	
	SET @DCSTATUS = (SELECT DCSTATUS FROM @tblTransStatus)

	--PRINT @DCSTATUS

	IF @DCSTATUS IN (2,3)
	BEGIN
		SET @Query = N'SELECT ACTINDX FROM ' + RTRIM(@Company) + '.dbo.GL00105 WHERE ACTNUMST = ''' + RTRIM(@Account) + ''''

		DELETE @tblTransAccount
		INSERT INTO @tblTransAccount
		EXECUTE(@Query)

		SET @ActIndx = (SELECT DSTINDX FROM @tblTransAccount)

		SET @Query = N'SELECT	TOP 1 PMD.DSTSQNUM
						FROM	' + RTRIM(@Company) + '.dbo.' + CASE WHEN @DCSTATUS = 2 THEN 'PM20000' ELSE 'PM30200' END + ' PMH
								INNER JOIN ' + RTRIM(@Company) + '.dbo.' + CASE WHEN @DCSTATUS = 2 THEN 'PM10100' ELSE 'PM30600' END + ' PMD ON PMH.VCHRNMBR = PMD.VCHRNMBR AND PMH.TRXSORCE = PMD.TRXSORCE
						WHERE	PMH.VCHRNMBR = ''' + RTRIM(@Voucher) + '''
								AND PMH.DOCNUMBR = ''' + RTRIM(@DocumentNo) + '''
								AND PMD.VENDORID = ''' + RTRIM(@VendorId) + '''
								AND PMD.DSTINDX = ' + CAST(@ActIndx AS Varchar) + '
								AND PMD.' + CASE WHEN @Amount > 0 THEN 'DEBITAMT' ELSE 'CRDTAMNT' END + ' = ' + CAST(ABS(@Amount) AS Varchar)

		DELETE @tblTransIndexNo
		INSERT INTO @tblTransIndexNo
		EXECUTE(@Query)

		--PRINT @Query

		SET @DSTSQNUM = (SELECT DSTSQNUM FROM @tblTransIndexNo)
		IF @DSTSQNUM IS NOT Null
		BEGIN
			UPDATE	@tblTransactions
			SET		ItemNumber = @DSTSQNUM
			WHERE	RecordId = @RecordId
		END
	END

	FETCH FROM ER_Transactions INTO @Company, @Voucher, @VendorId, @DocumentNo, @Account, @Amount, @RecordId
END

CLOSE ER_Transactions
DEALLOCATE ER_Transactions

INSERT INTO ExpenseRecovery
		(Company
		,VoucherNo
		,Vendor
		,ProNumber
		,Reference
		,Expense
		,Recovery
		,DocNumber
		,EffDate
		,InvDate
		,Trailer
		,Chassis
		,FailureReason
		,Recoverable
		,DriverId
		,DriverType
		,RepairType
		,GLAccount
		,RecoveryAction
		,Status
		,Notes
		,ItemNumber
		,Closed
		,Source
		,RepairTypeText
		,DriverTypeText
		,DriverName
		,RecoverableText
		,Division
		,StatusText)
SELECT	Company
		,VoucherNo
		,Vendor
		,ProNumber
		,Reference
		,Expense
		,Recovery
		,DocNumber
		,EffDate
		,InvDate
		,Trailer
		,Chassis
		,FailureReason
		,Recoverable
		,DriverId
		,DriverType
		,RepairType
		,GLAccount
		,RecoveryAction
		,Status
		,Notes
		,ItemNumber
		,Closed
		,Source
		,RepairTypeText
		,DriverTypeText
		,DriverName
		,RecoverableText
		,Division
		,StatusText
FROM	@tblTransactions
WHERE	ItemNumber > 0

SELECT	Company
		,VoucherNo
		,Vendor
		,ProNumber
		,Reference
		,Expense
		,Recovery
		,DocNumber
		,EffDate
		,InvDate
		,Trailer
		,Chassis
		,FailureReason
		,Recoverable
		,DriverId
		,DriverType
		,RepairType
		,GLAccount
		,RecoveryAction
		,Status
		,Notes
		,ItemNumber
		,Closed
		,Source
		,RepairTypeText
		,DriverTypeText
		,DriverName
		,RecoverableText
		,Division
		,StatusText
FROM	@tblTransactions
WHERE	ItemNumber > 0
GO
