USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[USP_FSI_TransactionDetails]    Script Date: 1/26/2023 7:23:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
EXECUTE USP_FSI_TransactionDetails '9FSI20230125_1451'
*/
ALTER PROCEDURE [dbo].[USP_FSI_TransactionDetails]
		@BatchId	Varchar(25)
AS
SET NOCOUNT ON

DECLARE @Company		Varchar(5) = (SELECT Company FROM FSI_ReceivedHeader WITH (NOLOCK) WHERE BatchId = @BatchId),
		@CompanyNumber	Smallint,
		@DemmurageAcc	Varchar(5),
		@Query			Varchar(1000),
		@CTF_Codes		Varchar(20)

SET @CompanyNumber = (SELECT CompanyNumber FROM PRISQL01P.GPCustom.dbo.Companies WITH (NOLOCK) WHERE CompanyId = @Company)
SET @DemmurageAcc  = (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WITH (NOLOCK) WHERE Company = @Company AND ParameterCode = 'DEMURRAGE_ACCCODE')

DECLARE	@tblParCodes		Table (ParCode Varchar(50))
DECLARE	@tblParameters		Table (Company Varchar(5), ParameterCode Varchar(75), VarC Varchar(250))
DECLARE @tblVendors			Table (VendorId Varchar(12), VendName Varchar(100))
DECLARE @tblGPVendors		Table (VendorCode Varchar(15), VndType Char(2))
DECLARE @tblCustomers		Table (CustomerId Varchar(15), CustName Varchar(100), SWSId Varchar(15) Null)
DECLARE	@tblInterCpy		Table (RecordId Int, CreditAcct Varchar(20), DebitAcct Varchar(20), Description Varchar(50))
DECLARE @tblDocuments		Table (VndDoc Varchar(50), DocumentCounter Int)
DECLARE @tblFSISubDetails	Table (DetailId Varchar(10), RecordType Varchar(5), AccCode Varchar(5), ChargeAmount1 Numeric(10,2), DemurrageAdminFee Numeric(10,2))

SET @Query = N'SELECT RTRIM(CUSTNMBR) AS CUSTNMBR, RTRIM(LEFT(CUSTNAME, 100)) AS CUSTNAME, SWSCustomerId FROM PRISQL01P.GPCustom.dbo.CustomerMaster WITH (NOLOCK) WHERE CompanyId = ''' + @Company + ''''

INSERT INTO @tblCustomers
EXECUTE(@Query)

SET @Query = N'SELECT RTRIM(VENDORID) AS VENDORID, RTRIM(LEFT(VENDNAME, 100)) AS VENDNAME FROM PRISQL01P.' + @Company + '.dbo.PM00200 WITH (NOLOCK)'

INSERT INTO @tblVendors
EXECUTE(@Query)

INSERT INTO @tblGPVendors
SELECT	VendorId,
		'PP'
FROM	PRISQL01P.GPCustom.dbo.GPVendorMaster WITH (NOLOCK)
WHERE	Company = @Company 
		AND PierPassType = 1

INSERT INTO @tblParCodes VALUES ('FSIVENDORCREACCT')
INSERT INTO @tblParCodes VALUES ('FSIVENDORPREPAYDEBACCT')
INSERT INTO @tblParCodes VALUES ('PIERPASS_ACCT_DEBIT')
INSERT INTO @tblParCodes VALUES ('PIERPASS_ACCT_CREDIT')
INSERT INTO @tblParCodes VALUES ('FSIACCRUDDEBIT')
INSERT INTO @tblParCodes VALUES ('FSIACCRUDCREDIT')
INSERT INTO @tblParCodes VALUES ('DEMURRAGE_AP_CREDIT')
INSERT INTO @tblParCodes VALUES ('DEMURRAGE_AP_DEBIT')
INSERT INTO @tblParCodes VALUES ('DEMURRAGE_AR_CREDIT')
INSERT INTO @tblParCodes VALUES ('DEMURRAGE_AR_DEBIT')
INSERT INTO @tblParCodes VALUES ('FSIVENDORDEBACCT')
INSERT INTO @tblParCodes VALUES ('FSISALESCREACCT')
INSERT INTO @tblParCodes VALUES ('FSISALESDEBACCT')
INSERT INTO @tblParCodes VALUES ('FSI_CTF_CREDIT')
INSERT INTO @tblParCodes VALUES ('FSI_CTF_DEBIT')
INSERT INTO @tblParCodes VALUES ('FSI_CTF_ACCCODES')
INSERT INTO @tblParCodes VALUES ('DEMURRAGE_ACCCODE')

INSERT INTO @tblParameters
SELECT	Company, ParameterCode, VarC
FROM	PRISQL01P.GPCustom.dbo.Parameters  WITH (NOLOCK)
WHERE	ParameterCode IN (SELECT ParCode FROM @tblParCodes)
		AND Company = @Company

SET @CTF_Codes = ISNULL((SELECT VarC FROM @tblParameters WHERE ParameterCode = 'FSI_CTF_ACCCODES'),'0-0-0-0-0')

SELECT	*
INTO	#tmpFSIInter
FROM	View_FSI_Intercompany
WHERE	Company = @Company
		AND BatchId =  @BatchId

INSERT INTO @tblInterCpy
SELECT	FSI_ReceivedSubDetailId, AccountNumber, InterAccount, [Description]
FROM	View_FSI_Intercompany WITH (NOLOCK)
WHERE	OriginalBatchId = @BatchId

SELECT	DATA.*,
		LEFT(CASE WHEN Company = 'GLSO' THEN InvoiceNumber + '|' + VendorDocument ELSE Equipment + '|' + InvoiceNumber END, 30) AS PrepayReference,
		CASE WHEN ICB_AP = 1 AND RecordType = 'VND' AND IsDemurrage = 0 THEN 'ICB' -- 4
			 WHEN ICB_AR = 1 AND RecordType <> 'VND' AND IsDemurrage = 0 THEN 'ICB' -- 4
			 WHEN ICB_AP = 0 AND PrePay = 1 AND PrePayType = 'P' AND PierPassType = 0 AND IsDemurrage = 0 THEN 'PREPAY' -- 3
			 WHEN PrePayType = 'A' AND IsDemurrage = 0 THEN 'ACCRUAL' -- 7
			 WHEN PierPassType = 1 AND IsDemurrage = 0 THEN 'PIERPASS' -- 5
			 WHEN VndIntercompany = 1 AND IsDemurrage = 0 THEN 'INTERCOMPANY' -- 2
			 WHEN PerDiemType = 1 AND IsDemurrage = 0 THEN 'PERDIEM' -- 6
			 WHEN IsDemurrage = 1 THEN 'DEMURRAGE' -- 8
			 ELSE 'VENDOR PAY' END AS TransType, -- 1
		CASE WHEN ICB_AP = 1 AND RecordType = 'VND' AND IsDemurrage = 0 THEN 4
			 WHEN ICB_AR = 1 AND RecordType <> 'VND' AND IsDemurrage = 0 THEN 4
			 WHEN ICB_AP = 0 AND PrePay = 1 AND PrePayType = 'P' AND PierPassType = 0 AND IsDemurrage = 0 THEN 3
			 WHEN PrePayType = 'A' AND IsDemurrage = 0 THEN 7
			 WHEN PierPassType = 1 AND IsDemurrage = 0 THEN 5
			 WHEN VndIntercompany = 1 AND IsDemurrage = 0 THEN 2
			 WHEN PerDiemType = 1 AND IsDemurrage = 0 THEN 6
			 WHEN IsDemurrage = 1 THEN 8
			 ELSE 1 END AS TransTypeId,
		CASE WHEN VndIntercompany = 1 OR ICB_AP = 1 THEN 'TIP'
			 WHEN (ICB_AP = 0 AND PrePay = 1 AND PrePayType = 'P') OR PierPassType = 1 OR PerDiemType = 1 OR PrePayType = 'A' OR IsDemurrage = 1 THEN 'FSIG'
			 ELSE 'FSIP' END AS IntegrationType
INTO	#tmpNonSale
FROM	(
		SELECT	FH.Company,
				FH.BatchId,
				FH.WeekEndDate, 
				FD.InvoiceNumber,
				CAST(FD.InvoiceDate AS Date) AS InvoiceDate,
				FS.RecordCode AS VendorId,
				FS.ChargeAmount1 AS Amount,
				FD.Division, 
				FS.FSI_ReceivedSubDetailId AS RecordId,
				FD.Equipment,
				FS.AccCode,
				CASE WHEN FS.RecordType = 'ACC' THEN FD.Equipment ELSE CASE WHEN DEM.VarC IS NOT Null THEN CAST(@CompanyNumber AS Varchar) + '-' + FD.InvoiceNumber ELSE 
					CASE WHEN FD.InvoiceType IN ('C','D') AND FS.VendorReference IS NOT Null AND FS.VendorReference <> '' THEN FS.VendorReference
							WHEN FD.InvoiceType IN ('C','D') AND (FS.VendorDocument IS Null OR FS.VendorDocument = '') THEN InvoiceNumber ELSE
							RTRIM(LEFT(CASE WHEN FS.VendorDocument IS NOT Null THEN CASE WHEN RTRIM(FS.VendorDocument) = RTRIM(FD.Equipment) THEN RTRIM(LEFT(FD.Equipment, 10)) + '/' + dbo.ReturnPureProNumber(FD.InvoiceNumber, 1) ELSE RTRIM(VendorDocument) END
							WHEN FD.Equipment IS NOT Null AND FD.Equipment <> '' THEN RTRIM(LEFT(FD.Equipment, 10)) + '/' + dbo.ReturnPureProNumber(FD.InvoiceNumber, 1)
							WHEN (LEN(RTRIM(ISNULL(FD.Equipment,''))) = 10 OR ISNULL(FD.Equipment,'') = 'FLATBED') AND ISNULL(FD.Equipment,'') <> VendorDocument THEN RTRIM(ISNULL(LEFT(FD.Equipment, 10),'')) + dbo.PADL(FSI_ReceivedSubDetailId, 9, '0')
							ELSE CASE WHEN RTRIM(FS.VendorDocument) = '' THEN CAST(FS.FSI_ReceivedSubDetailId AS Varchar) ELSE RTRIM(FS.VendorDocument) END + dbo.PADL(FSI_ReceivedSubDetailId, 9, '0')
						END, 20)) END END END AS VendorDocument,
				ISNULL(RecordType, 'NONE') AS RecordType, 
				ISNULL(RecordCode, 'NONE') AS RecordCode,
				IIF(EXISTS(SELECT AR.Company FROM FSI_Intercompany_ARAP AR WHERE AR.Company = FH.Company AND AR.Account = FD.CustomerNumber AND AR.Transtype = 'ICB' AND AR.RecordType = 'C'), 1, 0) AS ICB_AR,
				IIF(EXISTS(SELECT AP.Company FROM FSI_Intercompany_ARAP AP WHERE AP.Company = FH.Company AND AP.Account = FS.RecordCode AND AP.Transtype = 'ICB' AND AP.RecordType = 'V'), 1, 0) AS ICB_AP,
				IIF(DEM.VarC IS Null, 0, 1) AS IsDemurrage,
				FS.VndIntercompany,
				FS.PrePay,
				IIF(FS.PrePayType IN ('A','P'), FS.PrePayType, Null) AS PrePayType,
				ISNULL(IIF(FD.PrePayType IN ('A','P'), FD.PrePayType, Null),'') AS AR_PrePayType,
				CAST(IIF(VND.VendorCode IS Null, 0, 1) AS Bit) AS PierPassType,
				CAST(0 AS Bit) AS PerDiemType
		FROM    FSI_ReceivedDetails FD
				INNER JOIN FSI_ReceivedHeader FH WITH (NOLOCK) ON FD.BatchID = FH.BatchId
				INNER JOIN FSI_ReceivedSubDetails FS WITH (NOLOCK) ON FD.BatchID = FS.BatchId AND FD.DetailId = FS.DetailId AND FS.RecordType = 'VND'
				LEFT JOIN @tblParameters DEM ON DEM.ParameterCode = 'DEMURRAGE_ACCCODE' AND FS.AccCode = DEM.VarC
				LEFT JOIN @tblGPVendors VND ON FS.RecordCode = VND.VendorCode
		WHERE	FD.BatchId = @BatchId
		) DATA

INSERT INTO @tblDocuments
SELECT	VendorDocument,
		COUNT(*)
FROM	#tmpNonSale WITH (NOLOCK)
WHERE	TransTypeId = 1
GROUP BY VendorDocument

SELECT	FSI.Company,
		FSI.BatchId,
		FSI.WeekEndDate,
		FSI.InvoiceNumber,
		CAST(FSI.InvoiceDate AS Date) AS InvoiceDate,
		FSI.VendorId,
		FSI.Amount,
		CASE WHEN FSI.TransTypeId = 1 THEN (CASE WHEN LEN(FSI.VendorDocument) > 19 THEN LEFT(FSI.VendorDocument, 16) + '_' + RIGHT(CAST(FSI.RecordId AS Varchar), 3) 
			 WHEN LEN(FSI.VendorDocument) <= 20 AND FSU.DocumentCounter > 1 THEN RTRIM(LEFT(FSI.VendorDocument, 16)) + '_' + RIGHT(CAST(FSI.RecordId AS Varchar), 3)
			 ELSE VendorDocument END) 
		 ELSE FSI.PrepayReference END PrepayReference,
		FSI.TransType,
		FSI.TransTypeId,
		FSI.Division,
		FSI.RecordId,
		FSI.Equipment,
		FSI.AccCode,
		FSI.ICB_AR,
		FSI.ICB_AP,
		FSI.IsDemurrage
INTO	#tmpData
FROM	#tmpNonSale FSI WITH (NOLOCK)
		LEFT JOIN @tblDocuments FSU ON FSI.VendorDocument = FSU.VndDoc
WHERE	FSI.BatchId = @BatchId

DROP TABLE #tmpNonSale

INSERT INTO @tblFSISubDetails
SELECT	DetailId, RecordType, ISNULL(AccCode, RecordCode) AS AccCode, SUM(ChargeAmount1) AS ChargeAmount1, SUM(DemurrageAdminFee) AS DemurrageAdminFee
FROM	FSI_ReceivedSubDetails WITH (NOLOCK)
WHERE	BatchId = @BatchId
		AND VndIntercompany = 0
		AND ICB = 0
		AND ((RecordType = 'ACC' AND RecordCode = @DemmurageAcc)
		OR (RecordType = 'VND' AND (AccCode = 'DEM')))
GROUP BY DetailId, RecordType, ISNULL(AccCode, RecordCode)

DELETE	FSI_TransactionDetails 
WHERE	Company = @Company 
		AND BatchId = @BatchId

BEGIN TRY
	INSERT INTO [dbo].[FSI_TransactionDetails]
			([Company]
			,[BatchId]
			,[WeekendDate]
			,[GL_BatchId]
			,[InvoiceNumber]
			,[InvoiceDate]
			,[VndCustId]
			,[VndCustName]
			,[Amount]
			,[RefDocument]
			,[VoucherNumber]
			,[TransType]
			,[CreditAccount]
			,[DebitAccount]
			,[IntegrationType]
			,[SourceType]
			,[SourceRecordId]
			,[GPBatch])
	SELECT	@Company AS Company,
			FSI.BatchId,
			FSI.WeekEndDate,
			LEFT(FSI.BatchId, 15) AS GL_BatchId,
			FSI.InvoiceNumber,
			FSI.InvoiceDate,
			FSI.VendorId,
			VendorName = (SELECT UPPER(RTRIM(VND.VENDNAME)) FROM @tblVendors VND WHERE VND.VENDORID = FSI.VENDORID),
			FSI.Amount,
			CASE WHEN FSI.TransTypeId = 8 THEN CAST(@CompanyNumber AS Varchar) + '-' + FSI.InvoiceNumber + '|' + FSI.Equipment
				 WHEN FSI.TransTypeId IN (2,4) THEN REPLACE(FIN.Description, ' ', '')
				 WHEN FSI.TransTypeId IN (3,5,6,7) THEN REPLACE(FSI.PrepayReference, ' ', '')
				 ELSE FSI.PrepayReference END AS Reference,
			IIF(FSI.TransTypeId = 1, 'FSI' + REPLACE(SUBSTRING(FSI.BatchId, dbo.AT('FSI', FSI.BatchId, 1) + 5, 8), '_', '') + '_' + RIGHT(CAST(FSI.RecordId AS Varchar), 6), '') AS VoucherNumber,
			CASE WHEN FSI.TransTypeId = 3 AND @CTF_Codes LIKE ('%' + FSI.AccCode + '%') THEN 'PREPAY CTF'
				 ELSE FSI.TransType END AS TransType,
			CASE WHEN FSI.TransTypeId = 5 THEN (SELECT REPLACE(VarC, 'DD', FSI.Division) FROM @tblParameters P1 WHERE P1.ParameterCode = IIF(FSI.Amount > 0, 'PIERPASS_ACCT_CREDIT', 'PIERPASS_ACCT_DEBIT'))
				 WHEN FSI.TransTypeId = 1 THEN (SELECT REPLACE(VarC, 'DD', FSI.Division) FROM @tblParameters P1 WHERE P1.ParameterCode = IIF(FSI.Amount > 0, 'FSIVENDORCREACCT', 'FSIVENDORDEBACCT'))
				 WHEN FSI.TransTypeId = 3 AND @CTF_Codes LIKE ('%' + FSI.AccCode + '%') THEN (SELECT REPLACE(VarC, 'DD', FSI.Division) FROM @tblParameters P1 WHERE P1.ParameterCode = IIF(FSI.Amount > 0, 'FSI_CTF_CREDIT', 'FSI_CTF_DEBIT'))
				 WHEN FSI.TransTypeId = 3 AND @CTF_Codes NOT LIKE ('%' + FSI.AccCode + '%') THEN (SELECT REPLACE(VarC, 'DD', FSI.Division) FROM @tblParameters P1 WHERE P1.ParameterCode = IIF(FSI.Amount > 0, 'FSIVENDORPREPAYDEBACCT', 'FSIVENDORDEBACCT'))
				 WHEN FSI.TransTypeId = 4 THEN IIF(FSI.Amount > 0, FIN.CreditAcct, FIN.DebitAcct)
				 WHEN FSI.TransTypeId = 7 THEN (SELECT REPLACE(VarC, 'DD', FSI.Division) FROM @tblParameters P1 WHERE P1.ParameterCode = IIF(FSI.Amount > 0, 'FSIACCRUDDEBIT', 'FSIACCRUDCREDIT'))
				 WHEN FSI.TransTypeId = 8 THEN REPLACE((SELECT REPLACE(VarC, 'DD', FSI.Division) FROM @tblParameters P1 WHERE P1.ParameterCode = IIF(FSI.Amount > 0, 'DEMURRAGE_AP_CREDIT', 'DEMURRAGE_AP_DEBIT')), 'DD', Division)
			ELSE '' END AS CreditAccount,
			CASE WHEN FSI.TransTypeId = 5 THEN (SELECT REPLACE(VarC, 'DD', FSI.Division) FROM @tblParameters P1 WHERE P1.ParameterCode = IIF(FSI.Amount > 0, 'PIERPASS_ACCT_DEBIT', 'PIERPASS_ACCT_CREDIT'))
				 WHEN FSI.TransTypeId = 1 THEN (SELECT REPLACE(VarC, 'DD', FSI.Division) FROM @tblParameters P1 WHERE P1.ParameterCode = IIF(FSI.Amount > 0, 'FSIVENDORDEBACCT', 'FSIVENDORCREACCT'))
				 WHEN FSI.TransTypeId = 3 AND @CTF_Codes LIKE ('%' + FSI.AccCode + '%') THEN (SELECT REPLACE(VarC, 'DD', FSI.Division) FROM @tblParameters P1 WHERE P1.ParameterCode = IIF(FSI.Amount > 0, 'FSI_CTF_DEBIT', 'FSI_CTF_CREDIT'))
				 WHEN FSI.TransTypeId = 3 AND @CTF_Codes NOT LIKE ('%' + FSI.AccCode + '%') THEN (SELECT REPLACE(VarC, 'DD', FSI.Division) FROM @tblParameters P1 WHERE P1.ParameterCode = IIF(FSI.Amount > 0, 'FSIVENDORDEBACCT', 'FSIVENDORPREPAYDEBACCT'))
				 WHEN FSI.TransTypeId = 4 THEN IIF(FSI.Amount > 0, FIN.DebitAcct, FIN.CreditAcct)		 
				 WHEN FSI.TransTypeId = 7 THEN (SELECT REPLACE(VarC, 'DD', FSI.Division) FROM @tblParameters P1 WHERE P1.ParameterCode = IIF(FSI.Amount > 0, 'FSIACCRUDCREDIT', 'FSIACCRUDDEBIT'))
				 WHEN FSI.TransTypeId = 8 THEN REPLACE((SELECT REPLACE(VarC, 'DD', FSI.Division) FROM @tblParameters P1 WHERE P1.ParameterCode = IIF(FSI.Amount > 0, 'DEMURRAGE_AP_DEBIT', 'DEMURRAGE_AP_CREDIT')), 'DD', Division)
			ELSE '' END AS DebitAccount,
			CASE WHEN FSI.TransTypeId IN (2,4) THEN 'TIP'
				 WHEN FSI.TransTypeId IN (3,5,6,7,8) THEN 'FSIG'
				 ELSE 'FSIP' END AS IntegrationType,
			'AP' AS SourceType,
			FSI.RecordId,
			STUFF(FSI.BatchId, dbo.AT('FSI', FSI.BatchId, 1), 5, 'FSI') AS GL_BatchId
	FROM	#tmpData FSI
			LEFT JOIN @tblInterCpy FIN ON FSI.RecordId = FIN.RecordId
	WHERE	(FSI.TransTypeId IN (2,4) AND FIN.RecordId IS NOT Null)
			OR FSI.TransTypeId NOT IN (2,4)
	ORDER BY 13, FSI.TransType, FSI.InvoiceNumber
END TRY
BEGIN CATCH
	PRINT 'AP ERROR: ' + ERROR_MESSAGE() 
END CATCH

DROP TABLE #tmpData

SELECT	Company
		,BatchId
		,WeekEndDate
		,LEFT(BatchId, 15) AS GL_BatchId
		,InvoiceNumber
		,InvoiceDate
		,CustomerNumber
		,CustomerName = (SELECT CUST.CustName FROM @tblCustomers CUST WHERE ISNULL(CUST.SWSId, CUST.CustomerId) = FSAL.CustomerNumber)
		,InvoiceTotal
		,InvoiceType
		,IsDemurrage = IIF(EXISTS(SELECT TOP 1 BatchId FROM @tblFSISubDetails FS WHERE FS.RecordType = 'ACC'), 1, 0)
		,FSI_ReceivedDetailId
INTO	#tmpFSIAR
FROM	View_Integration_FSI_Sales FSAL WITH (NOLOCK)
WHERE	FSAL.BatchId = @BatchId
		AND FSAL.InvoiceTotal <> 0

SELECT	FSAL.Company,
		FSAL.BatchId,
		FSAL.WeekEndDate,
		LEFT(FSAL.BatchId, 15) AS GL_BatchId,
		FSAL.InvoiceNumber,
		FSAL.InvoiceDate,
		FSAL.CustomerNumber,
		CustomerName = (SELECT CUST.CustName FROM @tblCustomers CUST WHERE ISNULL(CUST.SWSId,CUST.CustomerId) = FSAL.CustomerNumber),
		FSAL.InvoiceTotal,
		CASE WHEN FINT.ICB = 1 OR FINT.Intercompany = 1 THEN FINT.Description
		ELSE FSAL.InvoiceNumber END AS Reference,
		CASE WHEN IsDemurrage = 0 AND FINT.AR_PrePayType = 'A' THEN 'ACCRUAL'
			 WHEN IsDemurrage = 0 AND FINT.ICB = 1 THEN 'ICB'
			 WHEN IsDemurrage = 0 AND FINT.ICB = 0 AND FINT.Intercompany = 1 THEN 'INTERCOMPANY'
			 WHEN IsDemurrage = 1 THEN 'SALES_DEMURRAGE'
		ELSE 'SALES' END AS TransType,
		CreditAccount = CASE WHEN IsDemurrage = 1 THEN (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = IIF(InvoiceTotal < 0, 'DEMURRAGE_AR_DEBIT', 'DEMURRAGE_AR_CREDIT')) 
							 WHEN IsDemurrage = 0 AND FINT.RecordId IS Null AND ISNULL(FINT.AR_PrePayType, 'N') <> 'A' THEN (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = IIF(InvoiceType <> 'C', 'FSISALESCREACCT', 'FSISALESDEBACCT')) 
						     WHEN IsDemurrage = 0 AND FINT.RecordId IS Null AND ISNULL(FINT.AR_PrePayType, 'N') = 'A' THEN (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = IIF(InvoiceType <> 'C', 'FSIACCRUDDEBIT', 'FSIACCRUDCREDIT')) 
		                ELSE FINT.AccountNumber END,
		DebitAccount = CASE WHEN IsDemurrage = 1 THEN (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = IIF(InvoiceTotal < 0, 'DEMURRAGE_AR_CREDIT', 'DEMURRAGE_AR_DEBIT')) 
							WHEN IsDemurrage = 0 AND FINT.RecordId IS Null AND ISNULL(FINT.AR_PrePayType, 'N') <> 'A' THEN (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = IIF(InvoiceType <> 'C', 'FSISALESDEBACCT', 'FSISALESCREACCT')) 
					        WHEN IsDemurrage = 0 AND FINT.RecordId IS Null AND ISNULL(FINT.AR_PrePayType, 'N') = 'A' THEN (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = IIF(InvoiceType <> 'C', 'FSIACCRUDCREDIT', 'FSIACCRUDDEBIT')) 
					   ELSE FINT.InterAccount END,
		CASE WHEN FINT.ICB = 1 OR FINT.Intercompany = 1 THEN 'TIP'
		     WHEN FINT.AR_PrePayType = 'A' THEN 'FSIG'
		 ELSE 'FSI' END AS IntegrationType,
		'AR' AS SourceType,
		FSAL.FSI_ReceivedDetailId
INTO	#tmpData2
FROM	#tmpFSIAR FSAL
		LEFT JOIN #tmpFSIInter FINT ON FSAL.FSI_ReceivedDetailId = FINT.RecordId AND FINT.LinkType = 'R'
ORDER BY FSAL.InvoiceNumber

DROP TABLE #tmpFSIAR
DROP TABLE #tmpFSIInter

BEGIN TRY
	INSERT INTO [dbo].[FSI_TransactionDetails]
			([Company]
			,[BatchId]
			,[WeekendDate]
			,[GL_BatchId]
			,[InvoiceNumber]
			,[InvoiceDate]
			,[VndCustId]
			,[VndCustName]
			,[Amount]
			,[RefDocument]
			,[VoucherNumber]
			,[TransType]
			,[CreditAccount]
			,[DebitAccount]
			,[IntegrationType]
			,[SourceType]
			,[SourceRecordId]
			,[GPBatch])
	SELECT	Company,
			BatchId,
			WeekEndDate,
			GL_BatchId,
			InvoiceNumber,
			InvoiceDate,
			ISNULL(CustomerNumber, ''),
			RTRIM(LEFT(CustomerName, 90)) AS CustomerName,
			InvoiceTotal,
			LEFT(Reference, 30) AS Reference,
			'' AS VoucherNumber,
			TransType,
			LEFT(CreditAccount, 15) AS CreditAccount,
			LEFT(DebitAccount, 15) AS DebitAccount,
			IntegrationType,
			SourceType,
			FSI_ReceivedDetailId,
			STUFF(BatchId, dbo.AT('FSI', BatchId, 1), 5, 'FSI')
	FROM	#tmpData2
END TRY
BEGIN CATCH
	PRINT 'AR ERROR: ' + ERROR_MESSAGE() 
END CATCH

DROP TABLE #tmpData2