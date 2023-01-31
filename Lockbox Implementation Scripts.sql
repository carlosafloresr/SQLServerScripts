USE [GPCustom]
GO

CREATE TABLE [dbo].[CashReceiptTracking](
	[pk_id] [int] IDENTITY(1,1) NOT NULL,
	[company] [varchar](5) NOT NULL,
	[batch_id] [varchar](20) NOT NULL,
	[import_success] [bit] NULL,
	[import_message] [varchar](max) NULL,
	[integration_success] [bit] NULL,
	[integration_message] [varchar](max) NULL,
	[created_by] [varchar](25) NULL,
	[created_date] [date] NULL,
	[modified_by] [varchar](25) NULL,
	[modified_date] [date] NULL,
 CONSTRAINT [PK_CashReceiptTracking_Main] PRIMARY KEY CLUSTERED 
(
	[pk_id] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[CashReceiptTracking] ADD  DEFAULT ((0)) FOR [import_success]
GO

ALTER TABLE [dbo].[CashReceiptTracking] ADD  DEFAULT ((0)) FOR [integration_success]
GO

CREATE TABLE [dbo].[CashReceiptAudit](
	[CashReceiptAuditId] [int] IDENTITY(1,1) NOT NULL,
	[RecordIndex] [int] NULL,
	[RecordIndexString] [varchar](100) NULL,
	[TableChanged] [varchar](50) NULL,
	[UserId] [varchar](25) NULL,
	[ChangeDescription] [varchar](max) NULL,
	[ChangedDate] [date] NULL,
 CONSTRAINT [PK_CashReceiptAudit_Main] PRIMARY KEY CLUSTERED 
(
	[CashReceiptAuditId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE CashReceipt
ADD [Difference] numeric(18,2) Null
GO 

ALTER VIEW [dbo].[View_CashReceipt]
AS
SELECT DISTINCT CashReceiptId
              , CASE
                  WHEN CAD.InvoiceNumber IN ('0', '00', '000') THEN 'NO_INVOICE'
                  ELSE CAD.InvoiceNumber END                                   AS InvoiceNumber
              , CAD.Amount
              , CAD.InvoiceDate
              , CAD.Equipment
              , CAD.WorkOrder
              , CAD.NationalAccount
              , CAD.BatchId
              , CAD.Company
              , CAD.MatchedRecord
              , CAD.Processed
              , CAD.CustomerNumber
              , CAD.InvBalance
              , CAD.InvAmount
              , dbo.CashReceiptStatus(CAD.Status)                              AS TextStatus
              , CAD.Status
              , CAD.Comments
              , CAH.UploadDate
              , CAH.BatchStatus
              , CAH.PaymentDate
              , CAH.UserId
              , CONVERT(NUMERIC(18,2), ISNULL(CAD.Payment,0))                                               AS Payment
              , RTRIM(LOC.SerialNumber)                                        AS CheckNumber
              , LOC.CheckAccount
              , CAD.Inv_Batch
              , ISNULL(CAD.Difference, 0) AS [Difference]
              , CAD.CreditAmount
              , LOC.RecordId
              , CAD.Orig_InvoiceNumber
			  , REPLACE(LOC.Reference, ',' + LOC.InvoiceNumber, '') AS Reference
			  , LOC.ProcessingDate
FROM	CashReceipt CAD
		INNER JOIN CashReceiptBatches CAH ON CAD.BatchId = CAH.BatchId AND CAD.Company = CAH.Company
		LEFT JOIN CashReceipts_Lockbox LOC ON CAD.SourceId = LOC.RecordId
GO

ALTER VIEW [dbo].[View_CashReceipt_BatchSummary]
AS
SELECT	Company,
		NationalAccount,
		BatchId,
		CustomerNumber,
		CheckNumber,
		InvoiceNumber,
		Payment,
		Balance,
		[Difference] = (Payment - Balance),
		CASE	WHEN InvoiceNumber IS Null THEN 2 -- The invoice is unmatched
				WHEN Balance = 0 THEN 3 -- The invoice is fully paid already
				WHEN Payment = Balance THEN 4 -- Perfect match
				WHEN Payment > Balance THEN 5 -- Payment grather than current balance
				WHEN Payment < (Balance - 5) THEN 6 -- Underpaid
				WHEN ABS(Payment - Balance) <= 5 THEN 7 -- Writeoff
				ELSE 1 END AS Status -- Undefined
FROM	(
SELECT	Company,
		NationalAccount,
		BatchId,
		CustomerNumber,
		CheckNumber,
		InvoiceNumber,
		MAX(Payment) AS Payment,
		MAX(InvBalance) AS Balance
FROM	View_CashReceipt
GROUP BY
		Company,
		BatchId,
		CustomerNumber,
		NationalAccount,
		CheckNumber,
		InvoiceNumber
		) DATA
GO

ALTER VIEW [dbo].[View_CashReceipts_Lockbox_Summay]
AS
SELECT	Company
		,BatchNumber
		,RTRIM(SerialNumber) AS CheckNumber
		,CheckAccount
		,RTRIM(InvoiceNumber) AS InvoiceNumber
		,SUM(INV_Number) AS Amount
FROM	CashReceipts_Lockbox
WHERE	INV_Number <> 0
GROUP BY Company
		,BatchNumber
		,SerialNumber
		,CheckAccount
		,InvoiceNumber
GO

/*
EXECUTE USP_CashReceipt_Integration 'AIS', 'LCKBX052120120000'
*/
CREATE PROCEDURE [dbo].[USP_CashReceipt_Integration]
		@Company		Varchar(5),
		@BatchId		Varchar(20)
AS
SET NOCOUNT ON

DECLARE	@DebAccount		Varchar(12),
		@CrdAccount		Varchar(12),
		@CHEKBKID		Varchar(25),
		@Integration	Varchar(10) = 'LCKBX',
		@HoldCustomer	Varchar(15),
		@NewBatchId		Varchar(15) = REPLACE(@BatchId, 'LCKBX', 'LB'),
		@NewBatchId2	Varchar(15) = REPLACE(@BatchId, 'LCKBX', 'CH'),
		@DocDate		Date,
		@PostDate		Date,
		@Query			Varchar(1000),
		@BatchStatus	Int = 0,
		@WriteOff		Numeric(10,2) = 5,
		@WithAR			Bit = 0

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
		WriteOffAmnt	Numeric(10, 2),
		RecordType		Char(2),
		Notes			Varchar(200) Null,
		ToCreate		Bit Null,
		Status			Smallint,
		StatusText		Varchar(40))

PRINT 'Selecting table parameters'

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

PRINT 'Selecting lockbox transactions'

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
GROUP BY
		CRL.Company,
		CRL.BatchNumber,
		CRL.SerialNumber,
		CRL.ProcessingDate

PRINT 'Deleting previous integration records'
DELETE	[PRISQL004P].Integrations.dbo.Integrations_AR 
WHERE	Integration = 'CASHAR' 
		AND Company = @Company 
		AND BatchId = @NewBatchId

DELETE	[PRISQL004P].Integrations.dbo.Integrations_ApplyTo 
WHERE	Integration = 'CASHAR' 
		AND Company = @Company 
		AND BatchId = @NewBatchId

DELETE	[PRISQL004P].Integrations.dbo.Integrations_Cash 
WHERE	Integration = 'LCKBX' 
		AND Company = @Company 
		AND BACHNUMB = REPLACE(@BatchId, 'LCKBX', 'CH')

PRINT 'Inserting Cash Integration records'
INSERT INTO [PRISQL004P].Integrations.dbo.Integrations_Cash
           (Integration,
			Company,
			BACHNUMB,
			CUSTNMBR,
			DOCNUMBR,
			DOCDATE,
			ORTRXAMT,
			GLPOSTDT,
			CSHRCTYP,
			CHEKBKID,
			CHEKNMBR,
			CRCARDID,
			TRXDSCRN,
			RMDTYPAL,
			ACTNUMST,
			DISTTYPE,
			DEBITAMT,
			CRDTAMNT,
			DistRef)
SELECT	*
FROM	(
		SELECT	@Integration AS Integration
				,Company
				,BatchNumber AS BatchId
				,CustomerNumber AS CustomerNumber
				,CheckNumber AS DOCNUMBR
				,ProcessDate AS DOCDATE
				,Amount AS DOCAMNT
				,ProcessDate AS PostingDate
				,0 AS CSHRCTYP
				,@CHEKBKID AS CHEKBKID
				,CheckNumber
				,'' AS CRCARDID
				,'CHK:' + CheckNumber AS TRXDSCRN
				,9 AS RMDTYPAL
				,@DebAccount AS ACTNUMST
				,1 AS DISTTYPE
				,Amount AS DEBITAMT
				,0 AS CRDTAMNT
				,'CHK:' + CheckNumber AS DISTREF
		FROM	@tblLockbox
		UNION
		SELECT	@Integration AS Integration
				,Company
				,BatchNumber AS BatchId
				,CustomerNumber AS CustomerNumber
				,CheckNumber AS DOCNUMBR
				,ProcessDate AS DOCDATE
				,Amount AS DOCAMNT
				,ProcessDate AS PostingDate
				,0 AS CSHRCTYP
				,@CHEKBKID AS CHEKBKID
				,CheckNumber
				,'' AS CRCARDID
				,'CHK:' + CheckNumber AS TRXDSCRN
				,9 AS RMDTYPAL
				,@CrdAccount AS ACTNUMST
				,3 AS DISTTYPE
				,0 AS DEBITAMT
				,Amount AS CRDTAMNT
				,'CHK:' + CheckNumber AS DISTREF
		FROM	@tblLockbox
		) RECORDS
WHERE	DOCAMNT <> 0
ORDER BY 5

PRINT 'Inserting Apply To Integration records'
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
				WriteOffAmnt = IIF(Status = 7, Difference, 0),
				'AR' AS RecordType,
				Null AS Notes,
				0 AS ToCreate,
				Status
		FROM	View_CashReceipt_BatchSummary
		WHERE	Company = @Company
				AND BatchId = @BatchId
				AND Status IN (4,5,6,7)
		UNION
		SELECT	'CASHAR' AS Integration,
				Company,
				@NewBatchId AS BatchId,
				IIF(ISNULL(NationalAccount, '') = '', IIF(CustomerNumber IS Null OR CustomerNumber = '', @HoldCustomer, CustomerNumber), NationalAccount) AS CustomerNumber,
				CheckNumber AS ApplyFrom,
				'C' + IIF(InvoiceNumber IN ('','0','NO_INVOICE'), RTRIM(CheckNumber), RTRIM(InvoiceNumber)) AS ApplyTo,
				ApplyAmount = ABS(SUM(IIF(Status = 4, 0, Balance - Payment))),
				WriteOffAmnt = 0,
				'AR' AS RecordType,
				Null AS Notes,
				1 AS ToCreate,
				Status
		FROM	View_CashReceipt_BatchSummary
		WHERE	Company = @Company
				AND BatchId = @BatchId
				AND Status NOT IN (4,6,7)
		GROUP BY
				Company,
				BatchId,
				CustomerNumber,
				NationalAccount,
				InvoiceNumber,
				CheckNumber,
				Status,
				Balance
		UNION
		SELECT	'CASHAR' AS Integration,
				Company,
				@NewBatchId AS BatchId,
				IIF(ISNULL(NationalAccount, '') = '', IIF(CustomerNumber IS Null OR CustomerNumber = '', @HoldCustomer, CustomerNumber), NationalAccount) AS CustomerNumber,
				CheckNumber AS ApplyFrom,
				'D' + IIF(InvoiceNumber IN ('','0','NO_INVOICE'), RTRIM(CheckNumber), RTRIM(InvoiceNumber)) AS ApplyTo,
				ApplyAmount = ABS(SUM(IIF(Status = 4, 0, Balance - Payment))),
				WriteOffAmnt = 0,
				'AR' AS RecordType,
				Null AS Notes,
				1 AS ToCreate,
				Status
		FROM	View_CashReceipt_BatchSummary
		WHERE	Company = @Company
				AND BatchId = @BatchId
				AND Status NOT IN (4,6,7)
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

DECLARE	@Customer	Varchar(15),
		@Document	Varchar(25),
		@tmpDocNo	Varchar(25),
		@DocExists	Bit = 0,
		@DocCount	Int = 0

DECLARE	@tblCredits Table (Customer Varchar(15), Document Varchar(25))
DECLARE @tblDocData	Table (Document Varchar(20))

DECLARE curTransactions CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	CustomerVendor,
		ApplyTo
FROM	@tblApplyTo
WHERE	LEFT(ApplyTo, 1) = 'C'

OPEN curTransactions 
FETCH FROM curTransactions INTO @Customer, @Document

WHILE @@FETCH_STATUS = 0
BEGIN
	DELETE @tblDocData
	SET @DocCount = 0
	SET @DocExists = 0
	SET @tmpDocNo = RTRIM(@Document)

	WHILE @DocExists = 0
	BEGIN
		SET @Query = 'SELECT DOCNUMBR FROM ' + @Company + '.dbo.RM00401 WHERE CUSTNMBR = ''' + RTRIM(@Customer) + ''' AND DOCNUMBR = ''' + RTRIM(@tmpDocNo) + ''''
		SET @DocCount = @DocCount + 1
		SET @tmpDocNo = RTRIM(@Document) + '-' + CAST(@DocCount AS Varchar)
		
		INSERT INTO @tblDocData
		EXECUTE(@Query)

		IF (SELECT COUNT(*) FROM @tblDocData) > 0
		BEGIN
			SET @DocExists = 1

			UPDATE	@tblApplyTo 
			SET		ApplyTo = @tmpDocNo 
			WHERE	CustomerVendor = @Customer 
					AND ApplyTo = @Document
		END
		ELSE
			SET @DocExists = 1
	END

	FETCH FROM curTransactions INTO @Customer, @Document
END

CLOSE curTransactions
DEALLOCATE curTransactions

IF EXISTS(SELECT TOP 1 Company FROM @tblApplyTo WHERE LEFT(ApplyTo, 1) IN ('C','D') AND ToCreate = 1)
BEGIN
	PRINT 'WITH AR TRANSACTIONS'
	
	INSERT INTO [PRISQL004P].Integrations.dbo.Integrations_AR
			([Integration]
			,[Company]
			,[BatchId]
			,[DOCNUMBR]
			,[DOCDESCR]
			,[CUSTNMBR]
			,[DOCDATE]
			,[DUEDATE]
			,[PostingDate]
			,[DOCAMNT]
			,[SLSAMNT]
			,[RMDTYPAL]
			,[ACTNUMST]
			,[DISTTYPE]
			,[DEBITAMT]
			,[CRDTAMNT]
			,[DistRef]
			,[ApplyTo]
			,[Division]
			,[ProNumber]
			,[VendorId]
			,[PopUpId]
			,[Processed]
			,[DistRecords]
			,[IntApToBal]
			,[GPAptoBal]
			,[WithApplyTo])
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

	IF @@ROWCOUNT > 0
		SET @WithAR = 1

	SET @BatchStatus = 0
END

--SELECT	*
--FROM	@tblApplyTo
--ORDER BY ApplyFrom

INSERT INTO [PRISQL004P].Integrations.dbo.Integrations_ApplyTo
        ([Integration]
        ,[Company]
        ,[BatchId]
        ,[CustomerVendor]
        ,[ApplyFrom]
        ,[ApplyTo]
        ,[ApplyAmount]
		,[WriteOffAmnt]
        ,[RecordType]
		,[Notes]
		,[ToCreate])
SELECT	Integration,
		Company,
		BatchId,
		CustomerVendor,
		ApplyFrom,
		ApplyTo,
		ISNULL(ApplyAmount, 0),
		ABS(WriteOffAmnt),
		RecordType,
		Notes,
		ToCreate
FROM	@tblApplyTo
WHERE	ApplyAmount <> 0
		AND NOT (LEFT(ApplyTo, 1) = 'C'
		AND ToCreate = 1)
ORDER BY ApplyFrom

IF @@ERROR = 0
BEGIN
	EXECUTE PRISQL004P.Integrations.dbo.USP_ReceivedIntegrations 'LCKBX', @Company, @NewBatchId2, @BatchStatus

	IF @WithAR = 1
		EXECUTE PRISQL004P.Integrations.dbo.USP_ReceivedIntegrations 'CASHAR', @Company, @NewBatchId, @BatchStatus
END
GO

