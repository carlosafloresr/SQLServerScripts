DECLARE	@PayrollWeek	Date = '12/30/2017',
		@Company		Varchar(5) = 'AIS',
		@Integration	Varchar(10) = 'PAYSP',
		@DocNumber		Varchar(25) = 'OAI INS DED 12/30',
		@Description	Varchar(30) = 'OAI Insurance',
		@GLAccount		Varchar(15) = '0-00-2050',
		@BatchId		Varchar(25),
		@DatePortion	Varchar(15)

DECLARE	@tblSpecial Table (
		VendorId		Varchar(12),
		Amount			Numeric(10,2),
		GLAccount		Varchar(20))

SET @DatePortion	= dbo.PADL(MONTH(@PayrollWeek), 2, '0') + dbo.PADL(DAY(@PayrollWeek), 2, '0') + RIGHT(dbo.PADL(YEAR(@PayrollWeek), 4, '0'), 2) + dbo.PADL(DATEPART(HOUR, GETDATE()), 2, '0') + dbo.PADL(DATEPART(MINUTE, GETDATE()), 2, '0')
SET @BatchId		= @Integration + @DatePortion

PRINT 'Batch ID: ' + @BatchId

DELETE	Integrations_AP
WHERE	Integration = @Integration
		AND Company = @Company
		AND BatchId = @BatchId

DELETE	ReceivedIntegrations
WHERE	Integration = @Integration
		AND Company = @Company
		AND BatchId = @BatchId

/*
="INSERT INTO @tblSpecial (VendorId, Amount, GLAccount) VALUES ('"&A2&"',"&B2&",'"&C2&"')"
*/

INSERT INTO @tblSpecial (VendorId, Amount, GLAccount) VALUES ('61894',65,'0-00-2795')
INSERT INTO @tblSpecial (VendorId, Amount, GLAccount) VALUES ('61991',32.5,'0-00-2795')
INSERT INTO @tblSpecial (VendorId, Amount, GLAccount) VALUES ('62014',32.5,'0-00-2795')
INSERT INTO @tblSpecial (VendorId, Amount, GLAccount) VALUES ('62100',32.5,'0-00-2795')
INSERT INTO @tblSpecial (VendorId, Amount, GLAccount) VALUES ('62101',32.5,'0-00-2795')
INSERT INTO @tblSpecial (VendorId, Amount, GLAccount) VALUES ('62007',32.5,'0-00-2795')
INSERT INTO @tblSpecial (VendorId, Amount, GLAccount) VALUES ('62107',32.5,'0-00-2795')
INSERT INTO @tblSpecial (VendorId, Amount, GLAccount) VALUES ('62085',32.5,'0-00-2795')
INSERT INTO @tblSpecial (VendorId, Amount, GLAccount) VALUES ('62071',32.5,'0-00-2795')
INSERT INTO @tblSpecial (VendorId, Amount, GLAccount) VALUES ('62138',32.5,'0-00-2795')
INSERT INTO @tblSpecial (VendorId, Amount, GLAccount) VALUES ('62145',32.5,'0-00-2795')
INSERT INTO @tblSpecial (VendorId, Amount, GLAccount) VALUES ('62002',32.5,'0-00-2795')
INSERT INTO @tblSpecial (VendorId, Amount, GLAccount) VALUES ('61986',32.5,'0-00-2795')
INSERT INTO @tblSpecial (VendorId, Amount, GLAccount) VALUES ('61295',32.5,'0-00-2795')
INSERT INTO @tblSpecial (VendorId, Amount, GLAccount) VALUES ('61357',32.5,'0-00-2795')
INSERT INTO @tblSpecial (VendorId, Amount, GLAccount) VALUES ('61815',32.5,'0-00-2795')
INSERT INTO @tblSpecial (VendorId, Amount, GLAccount) VALUES ('62001',32.5,'0-00-2795')
INSERT INTO @tblSpecial (VendorId, Amount, GLAccount) VALUES ('62012',32.5,'0-00-2795')
INSERT INTO @tblSpecial (VendorId, Amount, GLAccount) VALUES ('62043',65,'0-00-2795')
INSERT INTO @tblSpecial (VendorId, Amount, GLAccount) VALUES ('62135',32.5,'0-00-2795')
INSERT INTO @tblSpecial (VendorId, Amount, GLAccount) VALUES ('62153',32.5,'0-00-2795')
INSERT INTO @tblSpecial (VendorId, Amount, GLAccount) VALUES ('62157',32.5,'0-00-2795')

INSERT INTO @tblSpecial
SELECT	VendorId, 
		Amount * -1, 
		@GLAccount AS GLAccount
FROM	@tblSpecial

DECLARE	@tblData Table (
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

INSERT INTO @tblData
SELECT	@Integration AS Integration,
		@Company AS Company,
		@BatchId AS BatchId,
		RTRIM(VendorId) + @DatePortion AS VoucherNumber,
		VendorId,
		@DocNumber AS DocumentNumber,
		5 AS DocType,
		ABS(Amount) AS DocAmount,
		@PayrollWeek AS DocDate,
		CAST(GETDATE() AS Date) AS PstgDate,
		ABS(Amount) AS ChargeAmount,
		0 AS Ten99,
		ABS(Amount) AS PurchAmount,
		@Description AS Description,
		'USD2' AS Currency,
		1001 AS Rate,
		'01/01/2007' AS ExchangeDate,
		0 AS RateExpress,
		0 AS CreateDist,
		CASE WHEN Amount < 0 THEN 2 ELSE 6 END AS DisType,
		GLAccount AS AccountNumber,
		CASE WHEN Amount < 0 THEN ABS(Amount) ELSE 0 END AS Debit,
		CASE WHEN Amount > 0 THEN ABS(Amount) ELSE 0 END AS Credit,
		@Description AS Description,
		0 AS RecordId,
		'SPECIAL_UPLOAD' AS UserId
FROM	@tblSpecial BON
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
	INSERT INTO ReceivedIntegrations (Integration, Company, BatchId) VALUES (@Integration, @Company, @BatchId)