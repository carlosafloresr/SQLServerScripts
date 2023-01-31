DECLARE	@Company			Varchar(5) = DB_NAME(),
		@BatchId			Varchar(25) = 'SPCL_08032021',
		@Integration		Varchar(10) = 'SPCL'

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

INSERT INTO @tblData
SELECT	@Integration AS Integration,
		@Company AS Company,
		@BatchId AS BATCHID,
		REPLACE(APH.VCHRNMBR, 'FSI', 'SPC') AS VoucherNumber,
		APH.VendorId,
		REPLACE(APH.VCHRNMBR, 'FSI', 'SPC') AS DOCUMENTID,
		5 AS DOCTYPE,
		DOCAMNT,
		DOCDATE,
		APH.PSTGDATE,
		DOCAMNT,
		TEN99AMNT,
		DOCAMNT,
		TRXDSCRN,
		'USD2' AS Currency,
		1001 AS Rate,
		'01/01/2007' AS ExchangeDate,
		0 AS RateExpress,
		0 AS CreateDist,
		IIF(DEBITAMT > 0, 6, 2) AS DisType,
		ACTNUMST = (SELECT GL5.ACTNUMST FROM GL00105 GL5 WHERE GL5.ACTINDX = APD.DSTINDX),
		APD.CRDTAMNT AS DEBITAMNT,
		APD.DEBITAMT AS CRDTAMNT,
		APD.DistRef,
		0 AS RecordId,
		'SPECIAL_UPLOAD' AS UserId
FROM	PM20000 APH
		INNER JOIN PM10100 APD ON APH.VCHRNMBR = APD.VCHRNMBR AND APH.VENDORID = APD.VENDORID
WHERE	APH.TRXSORCE = 'PMTRX00012376'
UNION
SELECT	@Integration AS Integration,
		@Company AS Company,
		@BatchId AS BATCHID,
		REPLACE(APH.VCHRNMBR, 'FSI', 'SPC') AS VoucherNumber,
		APH.VendorId,
		REPLACE(APH.VCHRNMBR, 'FSI', 'SPC') AS DOCUMENTID,
		5 AS DOCTYPE,
		DOCAMNT,
		DOCDATE,
		APH.PSTGDATE,
		DOCAMNT,
		TEN99AMNT,
		DOCAMNT,
		TRXDSCRN,
		'USD2' AS Currency,
		1001 AS Rate,
		'01/01/2007' AS ExchangeDate,
		0 AS RateExpress,
		0 AS CreateDist,
		IIF(DEBITAMT > 0, 6, 2) AS DisType,
		ACTNUMST = (SELECT GL5.ACTNUMST FROM GL00105 GL5 WHERE GL5.ACTINDX = APD.DSTINDX),
		APD.CRDTAMNT AS DEBITAMNT,
		APD.DEBITAMT AS CRDTAMNT,
		APD.DistRef,
		0 AS RecordId,
		'SPECIAL_UPLOAD' AS UserId
FROM	PM30200 APH
		INNER JOIN PM30600 APD ON APH.VCHRNMBR = APD.VCHRNMBR AND APH.VENDORID = APD.VENDORID
WHERE	APH.TRXSORCE = 'PMTRX00012376'
		--APH.VCHRNMBR IN (
		--SELECT	ORCTRNUM
		--FROM	(
		--SELECT	RTRIM(GL2.REFRENCE) AS REFERENCE,
		--		GL2.TRXDATE,
		--		RTRIM(GL5.ACTNUMST) AS ACTNUMST,
		--		GL2.DEBITAMT,
		--		GL2.CRDTAMNT,
		--		CASE WHEN GL2.SOURCDOC = 'PMTRX' THEN 'AP' ELSE 'GL' END AS RECTYPE,
		--		GL2.ORMSTRID AS VENDORID,
		--		GL2.ORDOCNUM AS DOCUMENTID,
		--		GL2.ORPSTDDT AS POSTINGDATE,
		--		GL2.SERIES, 
		--		GL2.ORCTRNUM
		--FROM	GL20000 GL2
		--		INNER JOIN GL00105 GL5 ON GL2.ACTINDX = GL5.ACTINDX
		--WHERE	JRNENTRY IN (1068767)
		--) DATA
--WHERE RECTYPE = 'AP')
ORDER BY 4

SELECT	*
FROM	@tblData

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

DELETE	IntegrationsDB.Integrations.dbo.ReceivedIntegrations
WHERE	Company = @Company
		AND BatchId = @BatchId

DELETE	IntegrationsDB.Integrations.dbo.Integrations_AP
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
	EXECUTE IntegrationsDB.Integrations.dbo.USP_Integrations_AP_Full @Integration, @Company, @BatchId, @VCHNUMWK, @VENDORID, @DOCNUMBR, @DOCTYPE,
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
	INSERT INTO IntegrationsDB.Integrations.dbo.ReceivedIntegrations (Integration, Company, BatchId)
	SELECT	DISTINCT Integration, Company, BatchId
	FROM	@tblData
END