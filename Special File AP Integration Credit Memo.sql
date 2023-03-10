SET NOCOUNT ON

DECLARE	@ActionType			char(1) = 'I',
		@Integration		varchar(5) = 'SPCL',
		@CreditAcct			varchar(15),
		@DebitAcct			varchar(15),
		@Company			varchar(5) = 'GLSO',
		@DocumentType		smallint = 1,
		@Is1099				bit = 1

DECLARE	@BatchId			varchar(25) = @Integration + dbo.PADL(MONTH(GETDATE()), 2, '0') + dbo.PADL(DAY(GETDATE()), 2, '0') + RIGHT(YEAR(GETDATE()), 4),
		@DocNumber			varchar(20) = 'Bonus Sign On 3', --dbo.PADL(MONTH(GETDATE()), 2, '0') + dbo.PADL(DAY(GETDATE()), 2, '0') + RIGHT(YEAR(GETDATE()), 2),
		@Voucher			varchar(15) = '3BONUS_',
		@Description		varchar(25) = ' Bonus Sign On 3'
		
PRINT @BatchId

DECLARE	@tblSource			Table (
		VendorId			varchar(10),
		Amount				numeric(10,2),
		CreditAcct			varchar(15),
		DebitAcct			varchar(15),
		DocNumber			Varchar(20),
		Description			Varchar(30))

DECLARE	@tblData			Table (
		Integration			varchar(6), 
		Company				varchar(5), 
		BatchId				varchar(15), 
		VCHNUMWK			varchar(17), 
		VENDORID			varchar(15), 
		DOCNUMBR			varchar(20), 
		DOCTYPE				smallint, 
		DOCAMNT				numeric(18, 2), 
		DOCDATE				datetime, 
		PSTGDATE			datetime, 
		CHRGAMNT			numeric(18, 2), 
		TEN99AMNT			numeric(18, 2), 
		PRCHAMNT			numeric(18, 2), 
		TRXDSCRN			varchar(30), 
		CURNCYID			varchar(15), 
		RATETPID			varchar(15), 
		EXCHDATE			datetime, 
		RATEEXPR			smallint, 
		CREATEDIST			smallint, 
		DISTTYPE			smallint, 
		ACTNUMST			varchar(75), 
		DEBITAMT			numeric(18, 2), 
		CRDTAMNT			numeric(18, 2), 
		DISTREF				varchar(30), 
		RecordId			bigint, 
		UserId				varchar(25))

/*
="INSERT INTO @tblSource VALUES ('"&B2&"',"&I2&")"
="INSERT INTO @tblSource VALUES ('"&B2&"',"&I2&",'"&M2&"','"&J2&"')"
*/

INSERT INTO @tblSource VALUES ('V50184',500,'0-00-1860','0-00-2050')

INSERT INTO @tblData
SELECT	@Integration AS Integration,
		@Company,
		@BatchId AS BatchId,
		@Voucher + RTRIM(VendorId) AS VoucherNumber,
		VendorId,
		@DocNumber AS DocumentNumber,
		@DocumentType AS DocType,
		ABS(Amount) AS DocAmount,
		CAST(GETDATE() AS Date) AS DocDate,
		CAST(GETDATE() AS Date) AS PstgDate,
		ABS(Amount) AS ChargeAmount,
		IIF(@Is1099 = 1, Amount, 0) AS Ten99,
		ABS(Amount) AS PurchAmount,
		RTRIM(VendorId) + @Description AS Description,
		'USD2' AS Currency,
		1001 AS Rate,
		'01/01/2007' AS ExchangeDate,
		0 AS RateExpress,
		0 AS CreateDist,
		IIF(@DocumentType = 5, 2, 6) AS DisType,
		IIF(@DocumentType = 5, DebitAcct, CreditAcct) AS AccountNumber,
		Amount AS Debit,
		0 AS Credit,
		@Description AS Description,
		0 AS RecordId,
		'SPECIAL_UPLOAD' AS UserId
FROM	@tblSource
UNION
SELECT	@Integration AS Integration,
		@Company,
		@BatchId AS BatchId,
		@Voucher + RTRIM(VendorId) AS VoucherNumber,
		VendorId,
		@DocNumber AS DocumentNumber,
		@DocumentType AS DocType,
		ABS(Amount) AS DocAmount,
		CAST(GETDATE() AS Date) AS DocDate,
		CAST(GETDATE() AS Date) AS PstgDate,
		ABS(Amount) AS ChargeAmount,
		IIF(@Is1099 = 1, Amount, 0) AS Ten99,
		ABS(Amount) AS PurchAmount,
		RTRIM(VendorId) + @Description AS Description,
		'USD2' AS Currency,
		1001 AS Rate,
		'01/01/2007' AS ExchangeDate,
		0 AS RateExpress,
		0 AS CreateDist,
		IIF(@DocumentType = 5, 6, 2) AS DisType,
		IIF(@DocumentType = 5, CreditAcct, DebitAcct) AS AccountNumber,
		0 AS Debit,
		Amount AS Credit,
		@Description AS Description,
		0 AS RecordId,
		'SPECIAL_UPLOAD' AS UserId
FROM	@tblSource
ORDER BY VendorId

DECLARE	@VCHNUMWK			varchar(17), 
		@VENDORID			varchar(15), 
		@DOCNUMBR			varchar(20), 
		@DOCTYPE			smallint, 
		@DOCAMNT			numeric(18, 2), 
		@DOCDATE			datetime, 
		@PSTGDATE			datetime, 
		@CHRGAMNT			numeric(18, 2) = 0, 
		@TEN99AMNT			numeric(18, 2) = 0, 
		@PRCHAMNT			numeric(18, 2) = 0, 
		@TRXDSCRN			varchar(30), 
		@CURNCYID			varchar(15) = 'USD2', 
		@RATETPID			varchar(15) = 'AVERAGE', 
		@EXCHDATE			datetime = '01/01/2007', 
		@RATEEXPR			smallint = 0, 
		@CREATEDIST			smallint = 0, 
		@DISTTYPE			smallint = 6, 
		@ACTNUMST			varchar(75), 
		@DEBITAMT			numeric(18, 2), 
		@CRDTAMNT			numeric(18, 2), 
		@DISTREF			varchar(30), 
		@RecordId			bigint = 0, 
		@UserId				varchar(25)

IF @ActionType = 'I'
BEGIN
	DELETE	ReceivedIntegrations
	WHERE	Company = @Company
			AND BatchId = @BatchId

	DELETE	Integrations_AP
	WHERE	Company = @Company
			AND BatchId = @BatchId

	DECLARE curData CURSOR LOCAL KEYSET OPTIMISTIC FOR
	SELECT	*
	FROM	@tblData

	OPEN curData 
	FETCH FROM curData INTO @Integration, @Company, @BatchId, @VCHNUMWK, @VENDORID, @DOCNUMBR, @DOCTYPE,
							@DOCAMNT, @DOCDATE, @PSTGDATE, @CHRGAMNT, @TEN99AMNT, @PRCHAMNT, @TRXDSCRN,
							@CURNCYID, @RATETPID, @EXCHDATE, @RATEEXPR, @CREATEDIST, @DISTTYPE, @ACTNUMST,
							@DEBITAMT, @CRDTAMNT, @DISTREF, @RecordId, @UserId

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		EXECUTE USP_Integrations_AP_Full @Integration, @Company, @BatchId, @VCHNUMWK, @VENDORID, @DOCNUMBR, @DOCTYPE,
							@DOCAMNT, @DOCDATE, @PSTGDATE, @CHRGAMNT, @TEN99AMNT, @PRCHAMNT, @TRXDSCRN,
							@CURNCYID, @RATETPID, @EXCHDATE, @RATEEXPR, @CREATEDIST, @DISTTYPE, @ACTNUMST,
							@DEBITAMT, @CRDTAMNT, @DISTREF, @RecordId, @UserId

		FETCH FROM curData INTO @Integration, @Company, @BatchId, @VCHNUMWK, @VENDORID, @DOCNUMBR, @DOCTYPE,
							@DOCAMNT, @DOCDATE, @PSTGDATE, @CHRGAMNT, @TEN99AMNT, @PRCHAMNT, @TRXDSCRN,
							@CURNCYID, @RATETPID, @EXCHDATE, @RATEEXPR, @CREATEDIST, @DISTTYPE, @ACTNUMST,
							@DEBITAMT, @CRDTAMNT, @DISTREF, @RecordId, @UserId
	END

	CLOSE curData
	DEALLOCATE curData

	IF @@ERROR = 0
	BEGIN
		INSERT INTO ReceivedIntegrations (Integration, Company, BatchId)
		SELECT	DISTINCT Integration, Company, BatchId
		FROM	@tblData
	END
END
ELSE
	SELECT	*
	FROM	@tblData