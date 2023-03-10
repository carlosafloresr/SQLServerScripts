USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_CashReceipt_Integration]    Script Date: 11/2/2021 8:46:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_CashReceipt_Integration 'AIS', 'LCKBX072121IREC'
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
		@NewBatchId2	Varchar(15) = REPLACE(@BatchId, 'LCKBX', 'CH'),
		@DocDate		Date,
		@PostDate		Date,
		@Query			Varchar(1000),
		@BatchStatus	Int = 0,
		@WriteOff		Numeric(10,2) = 5,
		@WithAR			Bit = 0,
		@WithApplyTo	Bit = 0,
		@AltCompany		Varchar(5) = 'IMCG',
		@CheckBookParam	Varchar(25) = CASE WHEN @BatchID LIKE '%BOA%' THEN 'CHECKID_BOA' WHEN @BatchID LIKE '%IREC%' THEN 'CHECKID_BOA' ELSE 'CHECKID_REGIONS' END,
		@BatchConsecut	Char(2) = '00'

IF dbo.AT('-', RIGHT(@BatchId, 3), 1) > 0
	SET @BatchConsecut = dbo.PADL(RTRIM(SUBSTRING(@BatchId, dbo.AT('-', @BatchId, 1) + 1, 2)), 2, '0')

DECLARE	@tblCheckBook	Table (CHEKBKID Varchar(20))

DECLARE	@tblLockbox		Table (
		Company			Varchar(5),
		BatchNumber		Varchar(15),
		CustomerNumber	Varchar(12),
		CheckNumber		Varchar(21),
		UploadedOn		Date,
		ProcessDate		Date,
		Amount			Numeric(10,2),
		RowId			Int)

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

SET @Company = CASE WHEN @Company = 'IMCNA' THEN 'GLSO' WHEN @Company = 'IMCG' THEN 'IMC' WHEN @Company = 'IMCC' THEN 'IILS' ELSE @Company END
/*
********************************************************************************************
* Code replaced with a mapped value under the Parameters table on 03/29/2021 by CFLORES
********************************************************************************************

SET @Query = N'SELECT RTRIM(CHEKBKID) FROM ' + RTRIM(@Company) + '.dbo.RM40101'

INSERT INTO @tblCheckBook
EXECUTE(@Query)

SET @CHEKBKID		= (SELECT CHEKBKID FROM @tblCheckBook)
*/
SET @CHEKBKID		= (SELECT TOP 1 VarC FROM Parameters WHERE Company = @Company AND ParameterCode = @CheckBookParam) -- Check Book Id now on the Parameters table
SET @HoldCustomer	= (SELECT RTRIM(VarC) FROM Parameters WHERE ParameterCode = 'LOCKBOX_HOLDCUSTOMERID')

SET XACT_ABORT ON;
SET @DebAccount = (SELECT TOP 1 VarC FROM Parameters WHERE Company IN (@Company, 'ALL') AND ParameterCode = 'CASHGLACCOUNTCRD')
SET @CrdAccount = (SELECT TOP 1 VarC FROM Parameters WHERE Company IN (@Company, 'ALL') AND ParameterCode = 'CASHGLACCOUNTDEB')
SET @AltCompany = CASE WHEN @Company = 'IMC' THEN 'IMCG' WHEN @Company = 'GLSO' THEN 'IMCNA' ELSE @Company END

SELECT	TOP 1 
		@DocDate	= ProcessingDate,
		@PostDate	= ProcessingDate
FROM	View_CashReceipt
WHERE	Company = @AltCompany
		AND BatchId = @BatchId

PRINT 'Selecting lockbox transactions'

INSERT INTO @tblLockbox
SELECT	CASE
			WHEN CRL.Company = 'IMCG' THEN 'IMC' 
			WHEN CRL.Company = 'IMCNA' THEN 'GLSO'
			WHEN CRL.Company = 'IMCC' THEN 'IILS'
			ELSE CRL.Company 
		END AS [Company],
		REPLACE(CRL.BatchId, 'LCKBX', 'CH') AS BatchNumber,
		CustomerNumber = ISNULL((SELECT TOP 1 IIF(NationalAccount = '', IIF(CustomerNumber = '', @HoldCustomer, CustomerNumber), NationalAccount) FROM View_CashReceipt VCR WHERE VCR.Company = CRL.Company AND VCR.BatchId = CRL.BatchId AND VCR.CheckNumber = CRL.CheckNumber), @HoldCustomer),
		CRL.CheckNumber,
		CRL.ProcessingDate,
		CRL.ProcessingDate,
		SUM(CRL.Amount) AS Amount,
		ROW_NUMBER() OVER(ORDER BY CRL.CheckNumber) AS RowId
FROM	View_CashReceipt CRL
WHERE	CRL.Company = @AltCompany
		AND CRL.BatchId = @BatchId
		AND CRL.InvoiceNumber <> ''
GROUP BY
		CRL.Company,
		CRL.BatchId,
		CRL.CheckNumber,
		CRL.ProcessingDate

PRINT 'Deleting previous integration records'

DELETE	PRISQL004P.Integrations.dbo.Integrations_AR 
WHERE	Integration = 'CASHAR' 
		AND Company = @Company 
		AND BatchId = @NewBatchId

DELETE	PRISQL004P.Integrations.dbo.Integrations_ApplyTo 
WHERE	Integration = 'APPLYAR' 
		AND Company = @Company 
		AND BatchId = @NewBatchId

DELETE	PRISQL004P.Integrations.dbo.Integrations_Cash 
WHERE	Integration = 'LCKBX' 
		AND Company = @Company 
		AND BACHNUMB = REPLACE(@BatchId, 'LCKBX', 'CH')

PRINT 'Inserting Cash Integration records'
INSERT INTO PRISQL004P.Integrations.dbo.Integrations_Cash
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
				,LEFT(BatchNumber, 10) + '_' + @BatchConsecut + dbo.PADL(RowId, 3, '0') AS DOCNUMBR
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
				,LEFT(BatchNumber, 10) + '_' + @BatchConsecut + dbo.PADL(RowId, 3, '0') AS DOCNUMBR
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
		SELECT	'APPLYAR' AS Integration,
				VCS.Company,
				@NewBatchId AS BatchId,
				IIF(ISNULL(VCS.NationalAccount, '') = '', IIF(VCS.CustomerNumber IS Null OR VCS.CustomerNumber = '', @HoldCustomer, VCS.CustomerNumber), VCS.NationalAccount) AS Customer,
				LEFT(BatchNumber, 10) + '_' + @BatchConsecut + dbo.PADL(RowId, 3, '0') AS ApplyFrom,
				InvoiceNumber AS ApplyTo,
				IIF(Balance < Payment, Balance, Payment) AS ApplyAmount,
				WriteOffAmnt = IIF(Status = 7, Difference, 0),
				'AR' AS RecordType,
				Null AS Notes,
				0 AS ToCreate,
				Status
		FROM	View_CashReceipt_BatchSummary VCS
				INNER JOIN @tblLockbox LBX ON VCS.CheckNumber = LBX.CheckNumber --AND VCS.Company = LBX.Company
		WHERE	VCS.Company = @AltCompany
				AND BatchId = @BatchId
				AND Status IN (4,5,6,7)
		UNION
		SELECT	'APPLYAR' AS Integration,
				VCS.Company,
				@NewBatchId AS BatchId,
				IIF(ISNULL(VCS.NationalAccount, '') = '', IIF(VCS.CustomerNumber IS Null OR VCS.CustomerNumber = '', @HoldCustomer, VCS.CustomerNumber), VCS.NationalAccount) AS CustomerNumber,
				LEFT(BatchNumber, 10) + '_' + @BatchConsecut + dbo.PADL(RowId, 3, '0') AS ApplyFrom,
				'C' + IIF(InvoiceNumber IN ('','0','NO_INVOICE'), RTRIM(VCS.CheckNumber), RTRIM(InvoiceNumber)) AS ApplyTo,
				ApplyAmount = ABS(SUM(IIF(Status = 4, 0, Balance - Payment))),
				WriteOffAmnt = 0,
				'AR' AS RecordType,
				Null AS Notes,
				1 AS ToCreate,
				Status
		FROM	View_CashReceipt_BatchSummary VCS
				INNER JOIN @tblLockbox LBX ON VCS.CheckNumber = LBX.CheckNumber --AND VCS.Company = LBX.Company
		WHERE	VCS.Company = @AltCompany
				AND BatchId = @BatchId
				AND Status NOT IN (4,6,7)
		GROUP BY
				VCS.Company,
				BatchId,
				BatchNumber,
				RowId,
				VCS.CustomerNumber,
				NationalAccount,
				InvoiceNumber,
				VCS.CheckNumber,
				Status,
				Balance
		UNION
		SELECT	'APPLYAR' AS Integration,
				VCS.Company,
				@NewBatchId AS BatchId,
				IIF(ISNULL(VCS.NationalAccount, '') = '', IIF(VCS.CustomerNumber IS Null OR VCS.CustomerNumber = '', @HoldCustomer, VCS.CustomerNumber), VCS.NationalAccount) AS CustomerNumber,
				LEFT(BatchNumber, 10) + '_' + @BatchConsecut + dbo.PADL(RowId, 3, '0') AS ApplyFrom,
				'D' + IIF(InvoiceNumber IN ('','0','NO_INVOICE'), RTRIM(VCS.CheckNumber), RTRIM(InvoiceNumber)) AS ApplyTo,
				ApplyAmount = ABS(SUM(IIF(Status = 4, 0, Balance - Payment))),
				WriteOffAmnt = 0,
				'AR' AS RecordType,
				Null AS Notes,
				1 AS ToCreate,
				Status
		FROM	View_CashReceipt_BatchSummary VCS
				INNER JOIN @tblLockbox LBX ON VCS.CheckNumber = LBX.CheckNumber --AND VCS.Company = LBX.Company
		WHERE	VCS.Company = @AltCompany
				AND BatchId = @BatchId
				AND Status NOT IN (4,6,7)
		GROUP BY
				VCS.Company,
				BatchId,
				BatchNumber,
				RowId,
				VCS.CustomerNumber,
				NationalAccount,
				InvoiceNumber,
				VCS.CheckNumber,
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
	
	INSERT INTO PRISQL004P.Integrations.dbo.Integrations_AR
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
					,@Company AS Company
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
					,@Company AS Company
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
					,@Company AS Company
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
					,@Company AS Company
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

INSERT INTO PRISQL004P.Integrations.dbo.Integrations_ApplyTo
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
		,[ToCreate]
		,[PostingDate])
SELECT	Integration,
		@Company AS Company,
		BatchId,
		CustomerVendor,
		ApplyFrom,
		ApplyTo,
		ISNULL(ApplyAmount, 0),
		ABS(WriteOffAmnt),
		RecordType,
		Notes,
		ToCreate,
		@PostDate
FROM	@tblApplyTo
WHERE	ApplyAmount <> 0
		AND NOT (LEFT(ApplyTo, 1) = 'C'
		AND ToCreate = 1)
ORDER BY ApplyFrom

IF @@ROWCOUNT > 0
	SET @WithApplyTo = 1
IF @@ERROR > 0
	UPDATE CashReceiptBatches SET BatchStatus = 2 WHERE BatchId = @BatchId AND Company = @AltCompany
IF @@ERROR = 0
BEGIN
	UPDATE	PRISQL004P.Integrations.dbo.Integrations_ApplyTo
	SET		Integrations_ApplyTo.ApplyFrom = DATA.DOCNUMBR
	FROM	(
				SELECT	CUSTNMBR, CHEKNMBR, DOCNUMBR
				FROM	PRISQL004P.Integrations.dbo.Integrations_Cash
				WHERE	BACHNUMB = @NewBatchId2
			) DATA
	WHERE	Integrations_ApplyTo.BatchId = @NewBatchId
			AND Integrations_ApplyTo.CustomerVendor = DATA.CUSTNMBR
			AND Integrations_ApplyTo.ApplyFrom = DATA.CHEKNMBR

	DECLARE	@Param1		Varchar(10) = 'LCKBX',
			@Param2		Varchar(5) = @Company,
			@Param3		Varchar(30) = @NewBatchId2,
			@Param4		Int = @BatchStatus,
			@Param5		Varchar(30) = @BatchId

	EXECUTE PRISQL004P.Integrations.dbo.USP_ReceivedIntegrations @Integration = @Param1, @Company = @Param2, @BatchId = @Param3, @Status = @Param4, @SourceBatchId = @Param5
	UPDATE CashReceiptBatches SET BatchStatus = 3 WHERE BatchId = @BatchId AND Company = @AltCompany

	IF @WithAR = 1 OR @WithApplyTo = 1
	BEGIN
		IF @WithAR = 0 AND @WithApplyTo = 1
			SET @BatchStatus = 10

		IF @WithApplyTo = 1
			EXECUTE PRISQL004P.Integrations.dbo.USP_ReceivedIntegrations 'APPLYAR', @Company, @NewBatchId, 20

		IF EXISTS(SELECT TOP 1 Integration FROM PRISQL004P.Integrations.dbo.Integrations_AR WHERE Integration = 'CASHAR' AND Company = @Company AND BatchId = @NewBatchId)
			EXECUTE PRISQL004P.Integrations.dbo.USP_ReceivedIntegrations 'CASHAR', @Company, @NewBatchId, @BatchStatus
	END
END
