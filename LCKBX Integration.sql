/*
EXECUTE USP_CashReceipt_Integration 'AIS', 'LCKB0919181501'
*/
CREATE PROCEDURE USP_CashReceipt_Integration
		@Company	Varchar(5),
		@BatchId	Varchar(20)
AS
DECLARE	@DebAccount	Varchar(12),
		@CrdAccount	Varchar(12)

SET @DebAccount = (SELECT TOP 1 VarC FROM Parameters WHERE Company IN (@Company, 'ALL') AND ParameterCode = 'CASHGLACCOUNTDEB')
SET @CrdAccount = (SELECT TOP 1 VarC FROM Parameters WHERE Company IN (@Company, 'ALL') AND ParameterCode = 'CASHGLACCOUNTCRD')

INSERT INTO IntegrationsDb.Integrations.dbo.Integrations_AR
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
		SELECT	'LCKBX' AS Integration
				,Company
				,BatchId
				,CASE	WHEN Status IN (0, 1, 2, 3) THEN RTRIM(ISNULL(IIF(LEN(InvoiceNumber) < 4, CheckNumber, InvoiceNumber), CheckNumber)) + IIF(Status IN (0, 1, 2, 3), 'C', 'D')
						ELSE RTRIM(InvoiceNumber) + IIF(Status IN (0, 1, 2, 3), 'C', 'D') END AS DOCNUMBR
				,'CHK:' + CheckNumber AS DOCDESCR
				,ISNULL(NationalAccount, CustomerNumber) AS CustomerNumber
				,CAST(ISNULL(UploadDate, InvoiceDate) AS Date) AS DOCDATE
				,DATEADD(dd, 30, CAST(ISNULL(UploadDate, InvoiceDate) AS Date)) AS DUEDATE
				,CAST(GETDATE() AS Date) AS PostingDate
				,CASE WHEN Status IN (0, 1, 2, 3) THEN Payment ELSE Payment END AS DOCAMNT
				,CASE WHEN Status IN (0, 1, 2, 3) THEN Payment ELSE Payment END AS SLSAMNT
				,CASE WHEN Status IN (0, 1, 2, 3) THEN 7 ELSE 3 END AS RMDTYPAL -- 7 = Credit Memo / 3 = Debit Memo
				,@DebAccount AS ACTNUMST
				,CASE WHEN Status IN (0, 1, 2, 3) THEN 18 ELSE 3 END AS DISTTYPE
				,IIF(Status IN (0, 1, 2, 3), 0, Payment) AS DEBITAMT
				,IIF(Status IN (0, 1, 2, 3), Payment, 0) AS CRDTAMNT
				,'CHK:' + CheckNumber AS DISTREF
				,IIF(Status IN (0, 1, 2, 3), Null, InvoiceNumber) AS ApplyTo
				,Null AS Division
				,Null AS ProNumber
				,Null AS VendorId
				,0 AS PopUpId
				,Processed
				,0 AS DistRecords
				,0 AS IntAPtoBal
				,0 AS GPAPtoBal
				,CASE WHEN Status IN (0, 1, 2, 3) THEN 0 ELSE 1 END AS WithApplyTo
		FROM	View_CashReceipt
		WHERE	Company = @Company
				AND BatchId = @BatchId
				AND Processed = 0
				AND ISNULL(NationalAccount, CustomerNumber) IS NOT Null
		UNION
		SELECT	'LCKBX' AS Integration
				,Company
				,BatchId
				,CASE	WHEN Status IN (0, 1, 2, 3) THEN RTRIM(ISNULL(IIF(LEN(InvoiceNumber) < 4, CheckNumber, InvoiceNumber), CheckNumber)) + IIF(Status IN (0, 1, 2, 3), 'C', 'D')
						ELSE RTRIM(InvoiceNumber) + IIF(Status IN (0, 1, 2, 3), 'C', 'D') END AS DOCNUMBR
				,'CHK:' + CheckNumber AS DOCDESCR
				,ISNULL(NationalAccount, CustomerNumber) AS CustomerNumber
				,CAST(ISNULL(UploadDate, InvoiceDate) AS Date) AS DOCDATE
				,DATEADD(dd, 30, CAST(ISNULL(UploadDate, InvoiceDate) AS Date)) AS DUEDATE
				,CAST(GETDATE() AS Date) AS PostingDate
				,CASE WHEN Status IN (0, 1, 2, 3) THEN Payment ELSE Payment END AS DOCAMNT
				,CASE WHEN Status IN (0, 1, 2, 3) THEN Payment ELSE Payment END AS SLSAMNT
				,CASE WHEN Status IN (0, 1, 2, 3) THEN 7 ELSE 3 END AS RMDTYPAL -- 7 = Credit Memo / 3 = Debit Memo
				,@CrdAccount AS ACTNUMST
				,CASE WHEN Status IN (0, 1, 2, 3) THEN 3 ELSE 18 END AS DISTTYPE
				,IIF(Status IN (0, 1, 2, 3), Payment, 0) AS DEBITAMT
				,IIF(Status IN (0, 1, 2, 3), 0, Payment) AS CRDTAMNT
				,'CHK:' + CheckNumber AS DISTREF
				,IIF(Status IN (0, 1, 2, 3), Null, InvoiceNumber) AS ApplyTo
				,Null AS Division
				,Null AS ProNumber
				,Null AS VendorId
				,0 AS PopUpId
				,Processed
				,0 AS DistRecords
				,0 AS IntAPtoBal
				,0 AS GPAPtoBal
				,CASE WHEN Status IN (0, 1, 2, 3) THEN 0 ELSE 1 END AS WithApplyTo
		FROM	View_CashReceipt
		WHERE	Company = @Company
				AND BatchId = @BatchId
				AND Processed = 0
				AND ISNULL(NationalAccount, CustomerNumber) IS NOT Null
		) RECORDS
WHERE	DOCAMNT <> 0
ORDER BY 10, 9