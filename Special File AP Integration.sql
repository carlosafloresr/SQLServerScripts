SET NOCOUNT ON

DECLARE	@ActionType			char(1) = 'I',
		@CreditAcct			varchar(15) = '0-00-2791',
		@DebitAcct			varchar(15) = '0-00-2791',
		@Company			varchar(5) = 'AIS',
		@BatchId			varchar(25) = 'SPCL09272019',
		@DocNumber			varchar(20) = dbo.PADL(MONTH(GETDATE()), 2, '0') + dbo.PADL(DAY(GETDATE()), 2, '0') + RIGHT(YEAR(GETDATE()), 2)	,
		@Description		varchar(25) = 'Missed Payment'

DECLARE	@tblSource			Table (
		VendorId			varchar(10),
		Amount				numeric(10,2))

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

INSERT INTO @tblSource VALUES ('A1193','83.76')
INSERT INTO @tblSource VALUES ('A1264','109.53')
INSERT INTO @tblSource VALUES ('A1375','193.29')
INSERT INTO @tblSource VALUES ('A1717','83.76')
INSERT INTO @tblSource VALUES ('A50211','167.52')
INSERT INTO @tblSource VALUES ('A50524','103.76')
INSERT INTO @tblSource VALUES ('A50780','83.76')
INSERT INTO @tblSource VALUES ('A50795','20')
INSERT INTO @tblSource VALUES ('A50946','83.76')
INSERT INTO @tblSource VALUES ('A51033','167.52')
INSERT INTO @tblSource VALUES ('A0136','377.28')
INSERT INTO @tblSource VALUES ('A0179','97.5')
INSERT INTO @tblSource VALUES ('A50240','630')
INSERT INTO @tblSource VALUES ('A50965','900')
INSERT INTO @tblSource VALUES ('A0838','305.52')
INSERT INTO @tblSource VALUES ('A1679','214.81')
INSERT INTO @tblSource VALUES ('A1736','747.18')
INSERT INTO @tblSource VALUES ('A50013','792.36')
INSERT INTO @tblSource VALUES ('A50525','559.12')
INSERT INTO @tblSource VALUES ('A50538','1759.34')
INSERT INTO @tblSource VALUES ('A50587','45')
INSERT INTO @tblSource VALUES ('A50634','1256.19')
INSERT INTO @tblSource VALUES ('A50647','158.92')
INSERT INTO @tblSource VALUES ('A50680','983.65')
INSERT INTO @tblSource VALUES ('A50733','522.11')
INSERT INTO @tblSource VALUES ('A50789','613.92')
INSERT INTO @tblSource VALUES ('A50928','258.54')
INSERT INTO @tblSource VALUES ('A51029','275.4')
INSERT INTO @tblSource VALUES ('A51060','305.52')
INSERT INTO @tblSource VALUES ('A51087','1364.26')
INSERT INTO @tblSource VALUES ('A51090','269.66')
INSERT INTO @tblSource VALUES ('A1629','322.45')
INSERT INTO @tblSource VALUES ('A1685','684.18')
INSERT INTO @tblSource VALUES ('A50088','322.45')
INSERT INTO @tblSource VALUES ('A50091','644.9')
INSERT INTO @tblSource VALUES ('A50617','367.2')
INSERT INTO @tblSource VALUES ('A50718','328.19')
INSERT INTO @tblSource VALUES ('A50924','1108.01')
INSERT INTO @tblSource VALUES ('A50947','289.17')
INSERT INTO @tblSource VALUES ('A51034','328.19')
INSERT INTO @tblSource VALUES ('A51056','433.94')
INSERT INTO @tblSource VALUES ('A51070','1301.28')
INSERT INTO @tblSource VALUES ('A51123','413.11')
INSERT INTO @tblSource VALUES ('A50626','1990.02')
INSERT INTO @tblSource VALUES ('A50744','1751.39')
INSERT INTO @tblSource VALUES ('A50833','67.65')
INSERT INTO @tblSource VALUES ('A50933','408.15')
INSERT INTO @tblSource VALUES ('A51086','684.78')
INSERT INTO @tblSource VALUES ('A51094','238.63')
INSERT INTO @tblSource VALUES ('A51106','342.82')
INSERT INTO @tblSource VALUES ('A51109','342.82')
INSERT INTO @tblSource VALUES ('A51120','683.92')
INSERT INTO @tblSource VALUES ('A51121','409.51')
INSERT INTO @tblSource VALUES ('A51124','822.16')
INSERT INTO @tblSource VALUES ('A50327','149.18')
INSERT INTO @tblSource VALUES ('A50569','1825')
INSERT INTO @tblSource VALUES ('A50571','2580')
INSERT INTO @tblSource VALUES ('A50573','2214')
INSERT INTO @tblSource VALUES ('A50578','2520')
INSERT INTO @tblSource VALUES ('A50702','1215.75')
INSERT INTO @tblSource VALUES ('A50765','478.51')
INSERT INTO @tblSource VALUES ('A50775','1212.95')
INSERT INTO @tblSource VALUES ('A1289','638')
INSERT INTO @tblSource VALUES ('A1380','853.99')
INSERT INTO @tblSource VALUES ('A1542','638')
INSERT INTO @tblSource VALUES ('A1564','1626.12')
INSERT INTO @tblSource VALUES ('A1785','218.8')
INSERT INTO @tblSource VALUES ('A50137','140')
INSERT INTO @tblSource VALUES ('A50175','159.5')
INSERT INTO @tblSource VALUES ('A50546','173')
INSERT INTO @tblSource VALUES ('A50555','984.12')
INSERT INTO @tblSource VALUES ('A50624','157.6')
INSERT INTO @tblSource VALUES ('A50756','1204.9')
INSERT INTO @tblSource VALUES ('A50809','1156.68')
INSERT INTO @tblSource VALUES ('A50839','306.4')
INSERT INTO @tblSource VALUES ('A50952','78.8')
INSERT INTO @tblSource VALUES ('A50967','331.6')
INSERT INTO @tblSource VALUES ('A50973','227.6')
INSERT INTO @tblSource VALUES ('A51012','478.5')
INSERT INTO @tblSource VALUES ('A51014','159.5')
INSERT INTO @tblSource VALUES ('A51030','1116.5')
INSERT INTO @tblSource VALUES ('A51072','210')
INSERT INTO @tblSource VALUES ('A51073','957')
INSERT INTO @tblSource VALUES ('A51078','975.38')
INSERT INTO @tblSource VALUES ('A51079','140')
INSERT INTO @tblSource VALUES ('A51081','638')
INSERT INTO @tblSource VALUES ('A51114','974.6')
INSERT INTO @tblSource VALUES ('A51116','1596.16')
INSERT INTO @tblSource VALUES ('A51117','538.5')
INSERT INTO @tblSource VALUES ('A51126','319')
INSERT INTO @tblSource VALUES ('A51128','647.99')
INSERT INTO @tblSource VALUES ('A51143','297.6')



INSERT INTO @tblData
SELECT	'SPCL' AS Integration,
		@Company,
		@BatchId AS BatchId,
		'SPCL' + @DocNumber + RTRIM(VendorId) AS VoucherNumber,
		VendorId,
		'SPCL' + @DocNumber + RTRIM(VendorId) AS DocumentNumber,
		5 AS DocType,
		ABS(Amount) AS DocAmount,
		CAST(GETDATE() AS Date) AS DocDate,
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
		6 AS DisType,
		@DebitAcct AS AccountNumber,
		Amount AS Debit,
		0 AS Credit,
		@Description AS Description,
		0 AS RecordId,
		'SPECIAL_UPLOAD' AS UserId
FROM	@tblSource
UNION
SELECT	'SPCL' AS Integration,
		@Company,
		@BatchId AS BatchId,
		'SPCL' + @DocNumber + RTRIM(VendorId) AS VoucherNumber,
		VendorId,
		'SPCL' + @DocNumber + RTRIM(VendorId) AS DocumentNumber,
		5 AS DocType,
		ABS(Amount) AS DocAmount,
		CAST(GETDATE() AS Date) AS DocDate,
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
		2 AS DisType,
		@CreditAcct AS AccountNumber,
		0 AS Debit,
		Amount AS Credit,
		@Description AS Description,
		0 AS RecordId,
		'SPECIAL_UPLOAD' AS UserId
FROM	@tblSource
ORDER BY VendorId

DECLARE	@Integration		varchar(5), 
		@VCHNUMWK			varchar(17), 
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