USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_CashReceipt_Integration]    Script Date: 8/7/2019 12:02:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_CashReceipt_Integration 'AIS', 'LCKBX062719120000'
EXECUTE USP_CashReceipt_Integration 'AIS', 'LCKBX010419034626'
*/
ALTER PROCEDURE [dbo].[USP_CashReceipt_Integration]
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
SET @DebAccount = (SELECT TOP 1 VarC FROM Parameters WHERE Company IN (@Company, 'ALL') AND ParameterCode = 'CASHGLACCOUNTDEB')
SET @CrdAccount = (SELECT TOP 1 VarC FROM Parameters WHERE Company IN (@Company, 'ALL') AND ParameterCode = 'CASHGLACCOUNTCRD')

SELECT	TOP 1 
		@DocDate	= ProcessingDate,
		@PostDate	= ProcessingDate
FROM	View_CashReceipt
WHERE	Company = @Company
		AND BatchId = @BatchId

INSERT INTO @tblLockbox
SELECT	CRL.Company,
		REPLACE(CRL.BatchNumber, 'LCKBX', 'CH') AS BatchNumber,
		CustomerNumber = ISNULL((SELECT TOP 1 IIF(NationalAccount = '', CustomerNumber, NationalAccount) FROM View_CashReceipt VCR WHERE VCR.Company = CRL.Company AND VCR.BatchId = CRL.BatchNumber AND VCR.CheckNumber = CRL.SerialNumber), @HoldCustomer),
		CRL.SerialNumber AS CheckNumber,
		CRL.ProcessingDate,
		CRL.ProcessingDate,
		SUM(CRL.Amount) AS Amount
FROM	CashReceipts_Lockbox CRL
WHERE	CRL.Company = @Company
		AND CRL.BatchNumber = @BatchId
GROUP BY
		CRL.Company,
		CRL.BatchNumber,
		CRL.SerialNumber,
		CRL.ProcessingDate

DELETE	[INTEGRATIONSDB].Integrations.dbo.Integrations_AR 
WHERE	Integration = 'CASHAR' 
		AND Company = @Company 
		AND BatchId = @NewBatchId

DELETE	[INTEGRATIONSDB].Integrations.dbo.Integrations_ApplyTo 
WHERE	Integration = 'CASHAR' 
		AND Company = @Company 
		AND BatchId = @NewBatchId

DELETE	[INTEGRATIONSDB].Integrations.dbo.Integrations_Cash 
WHERE	Integration = 'LCKBX' 
		AND Company = @Company 
		AND BACHNUMB = REPLACE(@BatchId, 'LCKBX', 'CH')

INSERT INTO [INTEGRATIONSDB].Integrations.dbo.Integrations_Cash
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

INSERT INTO @tblApplyTo
SELECT	'CASHAR' AS Integration,
		Company,
		@NewBatchId AS BatchId,
		IIF(ISNULL(NationalAccount, '') = '', ISNULL(CustomerNumber, @HoldCustomer), NationalAccount),
		CheckNumber AS ApplyFrom,
		InvoiceNumber AS ApplyTo,
		Payment AS ApplyAmount,
		'AR' AS RecordType,
		Null AS Notes,
		0 AS ToCreate
FROM	View_CashReceipt
WHERE	Company = @Company
		AND BatchId = @BatchId
		AND Status > 2
UNION
SELECT	'CASHAR' AS Integration,
		Company,
		@NewBatchId AS BatchId,
		ISNULL(CustomerNumber, @HoldCustomer) AS CustomerNumber,
		CheckNumber AS ApplyFrom,
		'D' + RTRIM(CheckNumber) AS ApplyTo,
		SUM(Payment) AS ApplyAmount,
		'AR' AS RecordType,
		Null AS Notes,
		1 AS ToCreate
FROM	View_CashReceipt
WHERE	Company = @Company
		AND BatchId = @BatchId
		AND Status < 3
GROUP BY
		Company,
		BatchId,
		CustomerNumber,
		CheckNumber

INSERT INTO @tblApplyTo
SELECT	'CASHAR' AS Integration,
		Company,
		@NewBatchId AS BatchId,
		ISNULL(CustomerNumber, @HoldCustomer) AS CustomerNumber,
		CheckNumber AS ApplyFrom,
		'C' + RTRIM(CheckNumber) AS ApplyTo,
		SUM(Payment) AS ApplyAmount,
		'AR' AS RecordType,
		InvoiceNumber AS Notes,
		1 AS ToCreate
FROM	View_CashReceipt
WHERE	Company = @Company
		AND BatchId = @BatchId
		AND Status < 3
GROUP BY
		Company,
		BatchId,
		CustomerNumber,
		CheckNumber,
		InvoiceNumber

IF EXISTS(SELECT TOP 1 Company FROM @tblApplyTo WHERE LEFT(ApplyTo, 1) IN ('C','D') AND ToCreate = 1)
BEGIN
	PRINT 'WITH AR TRANSACTIONS'
	INSERT INTO [INTEGRATIONSDB].Integrations.dbo.Integrations_AR
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
					,'CHK:' + SUBSTRING(ApplyFrom, 2, 20) + '-' + IIF(Notes IS Null OR Notes = 'NO_INVOICE', '', Notes) AS DOCDESCR
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
					,'CHK:' + SUBSTRING(ApplyFrom, 2, 20) + '-' + IIF(Notes IS Null OR Notes = 'NO_INVOICE', '', Notes) AS DOCDESCR
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
					,'CHK:' + SUBSTRING(ApplyFrom, 2, 20) AS DOCDESCR
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
					,'CHK:' + SUBSTRING(ApplyFrom, 2, 20) AS DOCDESCR
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

DELETE	@tblApplyTo
WHERE	LEFT(ApplyTo, 1) = 'C'

SELECT	*
FROM	@tblApplyTo
ORDER BY ApplyFrom

INSERT INTO [INTEGRATIONSDB].Integrations.dbo.Integrations_ApplyTo
        ([Integration]
        ,[Company]
        ,[BatchId]
        ,[CustomerVendor]
        ,[ApplyFrom]
        ,[ApplyTo]
        ,[ApplyAmount]
        ,[RecordType]
		,[Notes]
		,[ToCreate])
SELECT	*
FROM	@tblApplyTo
ORDER BY ApplyFrom

IF @@ERROR = 0
BEGIN
	EXECUTE [INTEGRATIONSDB].Integrations.dbo.USP_ReceivedIntegrations 'CASHAR', @Company, @NewBatchId, @BatchStatus

	SET @NewBatchId = REPLACE(@BatchId, 'LCKBX', 'CH')
	EXECUTE [INTEGRATIONSDB].Integrations.dbo.USP_ReceivedIntegrations @Integration, @Company, @NewBatchId, 0

	UPDATE	CashReceiptBatches 
	SET		BatchStatus = 3 
	WHERE	Company = @Company 
			AND BatchId = @BatchId
END