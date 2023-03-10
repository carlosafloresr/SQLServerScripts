USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[USP_FSI_NonSalesRecords]    Script Date: 5/3/2022 5:39:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE Integrations.dbo.USP_FSI_NonSalesRecords '1FSI20220502_1629'
*/
ALTER PROCEDURE [dbo].[USP_FSI_NonSalesRecords]
		@BatchId		Varchar(25)
AS
SET NOCOUNT ON 

SET @BatchId = (SELECT batchId FROM FSI_ReceivedHeader WHERE BatchId LIKE (@BatchId + '%'))

PRINT @BatchId

DECLARE @Company		Varchar(5) = (SELECT Company FROM FSI_ReceivedHeader WHERE BatchId = @BatchId),
		@Query			Varchar(1000)

DECLARE	@tblParCodes	Table (ParCode Varchar(50))
DECLARE	@tblParameters	Table (Company Varchar(5), ParameterCode Varchar(50), VarC Varchar(100))
DECLARE @tblVendors		Table (VendorId Varchar(15), VendName Varchar(100))
DECLARE	@tblInterCpy	Table (RecordId Int, CreditAcct Varchar(20), DebitAcct Varchar(20))
DECLARE @tblDocuments	Table (VndDoc Varchar(50), DocumentCounter Int)

SET @Query = N'SELECT VENDORID, VENDNAME FROM PRISQL01P.' + @Company + '.dbo.PM00200'

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

INSERT INTO @tblParameters
SELECT	Company, ParameterCode, VarC
FROM	PRISQL01P.GPCustom.dbo.Parameters
WHERE	ParameterCode IN (SELECT ParCode FROM @tblParCodes)
		AND Company = @Company

INSERT INTO @tblVendors
EXECUTE(@Query)

INSERT INTO @tblInterCpy
SELECT	FSI_ReceivedSubDetailId, AccountNumber, InterAccount
FROM	View_FSI_Intercompany
WHERE	OriginalBatchId = @BatchId

INSERT INTO @tblDocuments
SELECT	VendorDocument,
		COUNT(*)
FROM	View_FSI_NonSale
WHERE	Company = @Company
		AND BatchId =  @BatchId
		AND TransTypeId = 1
GROUP BY VendorDocument

SELECT	FSI.Company,
		FSI.BatchId,
		FSI.WeekEndDate,
		FSI.InvoiceNumber,
		FSI.VendorId,
		FSI.Amount,
		CASE WHEN FSI.TransTypeId = 1 THEN (CASE WHEN LEN(FSI.VendorDocument) > 19 THEN LEFT(FSI.VendorDocument, 16) + '_' + RIGHT(CAST(FSI.RecordId AS Varchar), 3) 
			 WHEN LEN(FSI.VendorDocument) <= 20 AND FSU.DocumentCounter > 1 THEN RTRIM(LEFT(FSI.VendorDocument, 16)) + '_' + RIGHT(CAST(FSI.RecordId AS Varchar), 3)
			 ELSE VendorDocument END) 
		 ELSE FSI.PrepayReference END PrepayReference,
		FSI.TransType,
		FSI.TransTypeId,
		FSI.RecordId,
		FSI.Division
INTO	#tmpData
FROM	View_FSI_NonSale FSI
		LEFT JOIN @tblDocuments FSU ON FSI.VendorDocument = FSU.VndDoc
WHERE	FSI.BatchId = @BatchId

DELETE FSI_NonSalesRecords WHERE Company = @Company AND BatchId = @BatchId

INSERT INTO [dbo].[FSI_NonSalesRecords]
           ([Company]
           ,[BatchId]
           ,[GL_BatchId]
           ,[InvoiceNumber]
           ,[VendorId]
           ,[VendorName]
           ,[Amount]
           ,[Reference]
           ,[TransType]
           ,[CreditAccount]
           ,[DebitAccount]
           ,[IntegrationType])
SELECT	@Company AS Company,
		FSI.BatchId,
		LEFT(FSI.BatchId, 15) AS GL_BatchId,
		FSI.InvoiceNumber,
		FSI.VendorId,
		VendorName = (SELECT UPPER(RTRIM(VND.VENDNAME)) FROM @tblVendors VND WHERE VND.VENDORID = FSI.VENDORID),
		FSI.Amount,
		FSI.PrepayReference AS Reference,
		FSI.TransType,
		CASE WHEN FSI.TransTypeId = 1 THEN (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = 'FSIVENDORCREACCT')
			 WHEN FSI.TransTypeId = 3 THEN (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = 'FSIVENDORPREPAYDEBACCT')
		     WHEN FSI.TransTypeId = 4 THEN FIN.CreditAcct 
			 WHEN FSI.TransTypeId = 5 THEN (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = 'PIERPASS_ACCT_CREDIT')
			 WHEN FSI.TransTypeId = 7 THEN (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = 'FSIACCRUDDEBIT')
			 WHEN FSI.TransTypeId = 8 THEN REPLACE((SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = 'DEMURRAGE_AP_CREDIT'), 'DD', Division)
		ELSE '' END AS CreditAccount,
		CASE WHEN FSI.TransTypeId = 1 THEN (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = 'FSIVENDORDEBACCT')
			 WHEN FSI.TransTypeId = 3 THEN (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = 'FSIVENDORDEBACCT')
		     WHEN FSI.TransTypeId = 4 THEN FIN.DebitAcct 
			 WHEN FSI.TransTypeId = 5 THEN (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = 'PIERPASS_ACCT_DEBIT')
			 WHEN FSI.TransTypeId = 7 THEN (SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = 'FSIACCRUDCREDIT')
			 WHEN FSI.TransTypeId = 8 THEN REPLACE((SELECT VarC FROM @tblParameters P1 WHERE P1.ParameterCode = 'DEMURRAGE_AP_DEBIT'), 'DD', Division)
		ELSE '' END AS DebitAccount,
		CASE WHEN FSI.TransTypeId IN (2,4) THEN 'TIP'
			 WHEN FSI.TransTypeId IN (3,5,6,7,8) THEN 'FSIG'
			 ELSE 'FSIP' END AS IntegrationType
FROM	#tmpData FSI
		LEFT JOIN @tblInterCpy FIN ON FSI.RecordId = FIN.RecordId
ORDER BY 10, FSI.TransType, FSI.InvoiceNumber

DROP TABLE #tmpData

EXECUTE USP_FSI_TransactionDetails @BatchId
--EXECUTE USP_FSI_ReceivedDetails_WorkOrderUpdate @BatchId