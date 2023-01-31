DECLARE	@Company		Varchar(5) = 'AIS',
		@BatchId		Varchar(20) = 'LCKBX042120120000'

SET NOCOUNT ON

DECLARE	@DebAccount		Varchar(12),
		@CrdAccount		Varchar(12),
		@CHEKBKID		Varchar(25),
		@Integration	Varchar(10) = 'LCKBX',
		@HoldCustomer	Varchar(15),
		@NewBatchId		Varchar(15) = REPLACE(@BatchId, 'LCKBX', 'LB'),
		@DocDate		Date,
		@PostDate		Date,
		@Query			Varchar(1000),
		@BatchStatus	Int = 0

DECLARE	@tblCheckBook	Table (CHEKBKID Varchar(20))

DECLARE	@tblLockbox		Table (
		Company			Varchar(5),
		BatchNumber		Varchar(15),
		CustomerNumber	Varchar(12),
		CheckNumber		Varchar(21),
		UploadedOn		Date,
		ProcessDate		Date,
		Amount			Numeric(10,2))

DECLARE @tblApplyTo		Table (
		Integration		Varchar(10),
		Company			Varchar(5),
		BatchId			Varchar(20),
		CustomerVendor	Varchar(20),
		ApplyFrom		Varchar(30),
		ApplyTo			Varchar(30),
		ApplyAmount		Numeric(10, 2),
		RecordType		Char(2),
		Notes			Varchar(200) Null,
		ToCreate		Bit Null,
		Status			Smallint,
		StatusText		Varchar(40))

SET @Query = N'SELECT RTRIM(CHEKBKID) FROM ' + RTRIM(@Company) + '.dbo.RM40101'

INSERT INTO @tblCheckBook
EXECUTE(@Query)

SET @CHEKBKID		= (SELECT CHEKBKID FROM @tblCheckBook)
SET @HoldCustomer	= (SELECT RTRIM(VarC) FROM Parameters WHERE ParameterCode = 'LOCKBOX_HOLDCUSTOMERID')

SET XACT_ABORT ON;
SET @DebAccount = (SELECT TOP 1 VarC FROM Parameters WHERE Company IN (@Company, 'ALL') AND ParameterCode = 'CASHGLACCOUNTCRD')
SET @CrdAccount = (SELECT TOP 1 VarC FROM Parameters WHERE Company IN (@Company, 'ALL') AND ParameterCode = 'CASHGLACCOUNTDEB')

SELECT	TOP 1 
		@DocDate	= ProcessingDate,
		@PostDate	= ProcessingDate
FROM	View_CashReceipt
WHERE	Company = @Company
		AND BatchId = @BatchId

INSERT INTO @tblLockbox
SELECT	CRL.Company,
		REPLACE(CRL.BatchNumber, 'LCKBX', 'CH') AS BatchNumber,
		CustomerNumber = ISNULL((SELECT TOP 1 IIF(NationalAccount = '', IIF(CustomerNumber = '', @HoldCustomer, CustomerNumber), NationalAccount) FROM View_CashReceipt VCR WHERE VCR.Company = CRL.Company AND VCR.BatchId = CRL.BatchNumber AND VCR.CheckNumber = CRL.SerialNumber), @HoldCustomer),
		CRL.SerialNumber AS CheckNumber,
		CRL.ProcessingDate,
		CRL.ProcessingDate,
		SUM(CRL.Amount) AS Amount
FROM	CashReceipts_Lockbox CRL
WHERE	CRL.Company = @Company
		AND CRL.BatchNumber = @BatchId
		AND CRL.InvoiceNumber <> ''
		AND SerialNumber = '2558'
GROUP BY
		CRL.Company,
		CRL.BatchNumber,
		CRL.SerialNumber,
		CRL.ProcessingDate
--INSERT INTO [SECSQL04T].Integrations.dbo.Integrations_Cash
--           (Integration,
--			Company,
--			BACHNUMB,
--			CUSTNMBR,
--			DOCNUMBR,
--			DOCDATE,
--			ORTRXAMT,
--			GLPOSTDT,
--			CSHRCTYP,
--			CHEKBKID,
--			CHEKNMBR,
--			CRCARDID,
--			TRXDSCRN,
--			RMDTYPAL,
--			ACTNUMST,
--			DISTTYPE,
--			DEBITAMT,
--			CRDTAMNT,
--			DistRef)
--SELECT	*
--FROM	(
--		SELECT	@Integration AS Integration
--				,Company
--				,BatchNumber AS BatchId
--				,CustomerNumber AS CustomerNumber
--				,CheckNumber AS DOCNUMBR
--				,ProcessDate AS DOCDATE
--				,Amount AS DOCAMNT
--				,ProcessDate AS PostingDate
--				,0 AS CSHRCTYP
--				,@CHEKBKID AS CHEKBKID
--				,CheckNumber
--				,'' AS CRCARDID
--				,'CHK:' + CheckNumber AS TRXDSCRN
--				,9 AS RMDTYPAL
--				,@DebAccount AS ACTNUMST
--				,1 AS DISTTYPE
--				,Amount AS DEBITAMT
--				,0 AS CRDTAMNT
--				,'CHK:' + CheckNumber AS DISTREF
--		FROM	@tblLockbox
--		UNION
--		SELECT	@Integration AS Integration
--				,Company
--				,BatchNumber AS BatchId
--				,CustomerNumber AS CustomerNumber
--				,CheckNumber AS DOCNUMBR
--				,ProcessDate AS DOCDATE
--				,Amount AS DOCAMNT
--				,ProcessDate AS PostingDate
--				,0 AS CSHRCTYP
--				,@CHEKBKID AS CHEKBKID
--				,CheckNumber
--				,'' AS CRCARDID
--				,'CHK:' + CheckNumber AS TRXDSCRN
--				,9 AS RMDTYPAL
--				,@CrdAccount AS ACTNUMST
--				,3 AS DISTTYPE
--				,0 AS DEBITAMT
--				,Amount AS CRDTAMNT
--				,'CHK:' + CheckNumber AS DISTREF
--		FROM	@tblLockbox
--		) RECORDS
--WHERE	DOCAMNT <> 0
--ORDER BY 5

INSERT INTO @tblApplyTo
SELECT	*,
		dbo.CashReceiptStatus(Status) AS TextStatus
FROM	(
		SELECT	'CASHAR' AS Integration,
				Company,
				@NewBatchId AS BatchId,
				IIF(ISNULL(NationalAccount, '') = '', IIF(CustomerNumber IS Null OR CustomerNumber = '', @HoldCustomer, CustomerNumber), NationalAccount) AS Customer,
				CheckNumber AS ApplyFrom,
				InvoiceNumber AS ApplyTo,
				IIF(Balance < Payment, Balance, Payment) AS ApplyAmount,
				'AR' AS RecordType,
				Null AS Notes,
				0 AS ToCreate,
				Status
		FROM	View_CashReceipt_BatchSummary
		WHERE	Company = @Company
				AND BatchId = @BatchId
				AND IIF(Balance < Payment, Balance, Payment) <> 0
				AND Status IN (4,6)
				AND CheckNumber = '2558'
		UNION
		SELECT	'CASHAR' AS Integration,
				Company,
				@NewBatchId AS BatchId,
				IIF(ISNULL(NationalAccount, '') = '', IIF(CustomerNumber IS Null OR CustomerNumber = '', @HoldCustomer, CustomerNumber), NationalAccount) AS CustomerNumber,
				CheckNumber AS ApplyFrom,
				'D' + RTRIM(CheckNumber) AS ApplyTo,
				ApplyAmount = ABS(SUM(Balance)),
				'AR' AS RecordType,
				Null AS Notes,
				1 AS ToCreate,
				Status
		FROM	View_CashReceipt_BatchSummary
		WHERE	Company = @Company
				AND BatchId = @BatchId
				AND Status NOT IN (4,6)
				AND CheckNumber = '2558'
		GROUP BY
				Company,
				BatchId,
				CustomerNumber,
				NationalAccount,
				CheckNumber,
				Status,
				Balance
		UNION
		SELECT	'CASHAR' AS Integration,
				Company,
				@NewBatchId AS BatchId,
				IIF(ISNULL(NationalAccount, '') = '', IIF(CustomerNumber IS Null OR CustomerNumber = '', @HoldCustomer, CustomerNumber), NationalAccount) AS CustomerNumber,
				CheckNumber AS ApplyFrom,
				'C' + IIF(InvoiceNumber = '0' OR InvoiceNumber = '', RTRIM(CheckNumber), RTRIM(InvoiceNumber)) AS ApplyTo,
				ApplyAmount = ABS(SUM(IIF(Status = 4, 0, Balance - Payment))),
				'AR' AS RecordType,
				Null AS Notes,
				1 AS ToCreate,
				Status
		FROM	View_CashReceipt_BatchSummary
		WHERE	Company = @Company
				AND BatchId = @BatchId
				AND Status IN (0,1,2,3,5,7,8)
				AND CheckNumber = '2558'
		GROUP BY
				Company,
				BatchId,
				CustomerNumber,
				NationalAccount,
				InvoiceNumber,
				CheckNumber,
				Status,
				Balance
		) DATA

-- SELECT * FROM @tblApplyTo

IF EXISTS(SELECT TOP 1 Company FROM @tblApplyTo WHERE LEFT(ApplyTo, 1) IN ('C','D') AND ToCreate = 1)
BEGIN
	PRINT 'WITH AR TRANSACTIONS'
		SELECT	*
	FROM	(
			SELECT	'CASHAR' AS Integration
					,Company
					,BatchId
					,ApplyTo AS DOCNUMBR
					,'CHK:' + SUBSTRING(ApplyFrom, 2, 20) + '-D' + IIF(Notes IS Null OR Notes = 'NO_INVOICE', '', '-' + Notes) AS DOCDESCR
					,CustomerVendor AS CustomerNumber
					,@PostDate AS DOCDATE
					,DATEADD(dd, 30, @DocDate) AS DUEDATE
					,@PostDate AS PostingDate
					,ApplyAmount AS DOCAMNT
					,ApplyAmount AS SLSAMNT
					,3 AS RMDTYPAL -- 7 = Credit Memo / 3 = Debit Memo
					,@DebAccount AS ACTNUMST
					,3 AS DISTTYPE
					,ApplyAmount AS DEBITAMT
					,0 AS CRDTAMNT
					,'CHK:' + SUBSTRING(ApplyFrom, 2, 20) AS DISTREF
					,Null AS ApplyTo
					,Null AS Division
					,Null AS ProNumber
					,Null AS VendorId
					,0 AS PopUpId
					,0 AS Processed
					,0 AS DistRecords
					,0 AS IntAPtoBal
					,0 AS GPAPtoBal
					,1 AS WithApplyTo
			FROM	@tblApplyTo
			WHERE	LEFT(ApplyTo, 1) = 'D'
					AND ApplyAmount <> 0
					AND ToCreate = 1
			UNION
			SELECT	'CASHAR' AS Integration
					,Company
					,BatchId
					,ApplyTo AS DOCNUMBR
					,'CHK:' + SUBSTRING(ApplyFrom, 2, 20) + '-D' + IIF(Notes IS Null OR Notes = 'NO_INVOICE', '', '-' + Notes) AS DOCDESCR
					,CustomerVendor AS CustomerNumber
					,@PostDate AS DOCDATE
					,DATEADD(dd, 30, @DocDate) AS DUEDATE
					,@PostDate AS PostingDate
					,ApplyAmount AS DOCAMNT
					,ApplyAmount AS SLSAMNT
					,3 AS RMDTYPAL -- 7 = Credit Memo / 3 = Debit Memo
					,@CrdAccount AS ACTNUMST
					,18 AS DISTTYPE
					,0 AS DEBITAMT
					,ApplyAmount AS CRDTAMNT
					,'CHK:' + SUBSTRING(ApplyFrom, 2, 20) AS DISTREF
					,Null AS ApplyTo
					,Null AS Division
					,Null AS ProNumber
					,Null AS VendorId
					,0 AS PopUpId
					,0 AS Processed
					,0 AS DistRecords
					,0 AS IntAPtoBal
					,0 AS GPAPtoBal
					,1 AS WithApplyTo
			FROM	@tblApplyTo
			WHERE	LEFT(ApplyTo, 1) = 'D'
					AND ApplyAmount <> 0
					AND ToCreate = 1
			UNION
			SELECT	'CASHAR' AS Integration
					,Company
					,BatchId
					,ApplyTo AS DOCNUMBR
					,'CHK:' + SUBSTRING(ApplyFrom, 2, 20) + '-C' AS DOCDESCR
					,CustomerVendor AS CustomerNumber
					,@PostDate AS DOCDATE
					,DATEADD(dd, 30, @DocDate) AS DUEDATE
					,@PostDate AS PostingDate
					,ApplyAmount AS DOCAMNT
					,ApplyAmount AS SLSAMNT
					,7 AS RMDTYPAL -- 7 = Credit Memo / 3 = Debit Memo
					,@CrdAccount AS ACTNUMST
					,3 AS DISTTYPE
					,0 AS DEBITAMT
					,ApplyAmount AS CRDTAMNT
					,'CHK:' + SUBSTRING(ApplyFrom, 2, 20) AS DISTREF
					,Null AS ApplyTo
					,Null AS Division
					,Null AS ProNumber
					,Null AS VendorId
					,0 AS PopUpId
					,0 AS Processed
					,0 AS DistRecords
					,0 AS IntAPtoBal
					,0 AS GPAPtoBal
					,1 AS WithApplyTo
			FROM	@tblApplyTo
			WHERE	LEFT(ApplyTo, 1) = 'C'
					AND ToCreate = 1
			UNION
			SELECT	'CASHAR' AS Integration
					,Company
					,BatchId
					,ApplyTo AS DOCNUMBR
					,'CHK:' + SUBSTRING(ApplyFrom, 2, 20) + '-C' AS DOCDESCR
					,CustomerVendor AS CustomerNumber
					,@PostDate AS DOCDATE
					,DATEADD(dd, 30, @DocDate) AS DUEDATE
					,@PostDate AS PostingDate
					,ApplyAmount AS DOCAMNT
					,ApplyAmount AS SLSAMNT
					,7 AS RMDTYPAL -- 7 = Credit Memo / 3 = Debit Memo
					,@DebAccount AS ACTNUMST
					,19 AS DISTTYPE
					,ApplyAmount AS DEBITAMT
					,0 AS CRDTAMNT
					,'CHK:' + SUBSTRING(ApplyFrom, 2, 20) AS DISTREF
					,Null AS ApplyTo
					,Null AS Division
					,Null AS ProNumber
					,Null AS VendorId
					,0 AS PopUpId
					,0 AS Processed
					,0 AS DistRecords
					,0 AS IntAPtoBal
					,0 AS GPAPtoBal
					,1 AS WithApplyTo
			FROM	@tblApplyTo
			WHERE	LEFT(ApplyTo, 1) = 'C'
					AND ToCreate = 1
			) RECORDS
	WHERE	DOCAMNT <> 0
	ORDER BY 4

	SET @BatchStatus = 0
END
ELSE
	SET @BatchStatus = 5

--DELETE	@tblApplyTo
--WHERE	LEFT(ApplyTo, 1) = 'C'

SELECT	Integration,
		Company,
		BatchId,
		CustomerVendor,
		ApplyFrom,
		ApplyTo,
		ISNULL(ApplyAmount, 0),
		RecordType,
		Notes,
		ToCreate
FROM	@tblApplyTo
WHERE	ApplyAmount <> 0
ORDER BY ApplyFrom
