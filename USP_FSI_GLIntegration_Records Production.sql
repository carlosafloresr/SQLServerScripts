USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[USP_FSI_GLIntegration_Records]    Script Date: 1/26/2023 4:46:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_FSI_GLIntegration_Records 'PDS', '8FSI20220504_1057', 1
*/
ALTER PROCEDURE [dbo].[USP_FSI_GLIntegration_Records]
		@Company		Varchar(5), 
		@BatchId		Varchar(25),
		@Status			Smallint = 0
AS
SET NOCOUNT ON

DECLARE @CompanyNumber	Smallint,
		@CTF_Codes		Varchar(20)
DECLARE @Demurrage		Varchar(10) = (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WHERE Company = @Company AND ParameterCode = 'DEMURRAGE_ACCCODE')
DECLARE @tblVendors		Table (Company Varchar(5), VendorCode Varchar(15), VndType Char(2))
DECLARE	@tblParCodes	Table (ParCode Varchar(50))
DECLARE	@tblParameters	Table (Company Varchar(5), ParameterCode Varchar(75), VarC Varchar(250))

SET @CompanyNumber = (SELECT CompanyNumber FROM PRISQL01P.GPCustom.dbo.Companies WHERE CompanyId = @Company)

INSERT INTO @tblVendors
SELECT	Company, 
		VendorId,
		'PP'
FROM	PRISQL01P.GPCustom.dbo.GPVendorMaster 
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

INSERT INTO @tblParameters
SELECT	Company, ParameterCode, VarC
FROM	PRISQL01P.GPCustom.dbo.Parameters
WHERE	ParameterCode IN (SELECT ParCode FROM @tblParCodes)
		AND Company = @Company

SET @CTF_Codes = ISNULL((SELECT VarC FROM @tblParameters WHERE ParameterCode = 'FSI_CTF_ACCCODES'),'0-0-0-0-0')

SELECT	*
INTO	#tmpFSISubData
FROM	View_Integration_FSI_Full
WHERE	BatchId = @BatchId 
		AND VndIntercompany = 0
		AND SubProcessed = @Status
		AND ((RecordType = 'ACC' AND ISNULL(AR_PrePayType, 'N') = 'A')
		OR RecordType = 'VND')

SELECT	FSI.Company,
		FSI.BatchId,
		FSI.WeekEndDate,
		FSI.InvoiceNumber,
		FSI.InvoiceDate,
		FSI.Equipment,
		FSI.Division,
		FSI.FSI_ReceivedSubDetailId,
		FSI.PrePay,
		FSI.PrePayType,
		FSI.AR_PrePayType,
		FSI.PierPassType,
		FSI.ChargeAmount1,
		FSI.VendorDocument,
		CASE WHEN FSI.RecordType = 'VND' AND FSI.AccCode = @Demurrage THEN CAST(@CompanyNumber AS Varchar) + '-' + FSI.InvoiceNumber + '|' + FSI.Equipment -- AND FSI.CustomerNumber IN (SELECT CustomerId FROM @tblCustomers)
			 WHEN FSI.RecordType = 'ACC' AND FSI.RecordCode = @Demurrage THEN CAST(@CompanyNumber AS Varchar) + '-' + FSI.InvoiceNumber
			 ELSE FSI.PrepayReference END AS PrepayReference,
		FSI.RecordType,
		FSI.RecordCode,
		FSI.AccCode,
		FSI.DetailId,
		FSI.ReceivedOn,
		FSI.PerDiemType,
		CASE WHEN FSI.RecordType = 'VND' AND FSI.AccCode = @Demurrage THEN (SELECT dbo.GLAccountDivision(@Company,FSI.Division,VarC) FROM @tblParameters WHERE Company IN (@Company, 'ALL') AND ParameterCode = IIF(FSI.InvoiceType = 'C'  OR FSI.ChargeAmount1 < 0, 'DEMURRAGE_AP_CREDIT', 'DEMURRAGE_AP_DEBIT')) --AND FSI.CustomerNumber IN (SELECT CustomerId FROM @tblCustomers) 
			 WHEN FSI.PrePay = 1 AND FSI.PrePayType = 'P' AND FSI.ICB_AP = 0 AND @CTF_Codes NOT LIKE ('%' + FSI.AccCode + '%') AND FSI.RecordCode NOT IN (SELECT VendorCode FROM @tblVendors) THEN (SELECT VarC FROM @tblParameters WHERE Company = @Company AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'FSIVENDORPREPAYDEBACCT', 'FSIVENDORDEBACCT'))
			 WHEN FSI.PrePay = 1 AND FSI.PrePayType = 'P' AND FSI.ICB_AP = 0 AND @CTF_Codes LIKE ('%' + FSI.AccCode + '%') AND FSI.RecordCode NOT IN (SELECT VendorCode FROM @tblVendors) THEN (SELECT REPLACE(VarC, 'DD', FSI.Division) FROM @tblParameters WHERE Company = @Company AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'FSI_CTF_CREDIT', 'FSI_CTF_DEBIT'))
			 WHEN FSI.AR_PrePayType = 'A' OR FSI.PrePayType = 'A' THEN (SELECT VarC FROM @tblParameters WHERE Company = @Company AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'FSIACCRUDDEBIT','FSIACCRUDCREDIT'))
			 WHEN FSI.RecordCode IN (SELECT VendorCode FROM @tblVendors) THEN (SELECT VarC FROM @tblParameters WHERE Company = @Company AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'PIERPASS_ACCT_CREDIT', 'PIERPASS_ACCT_DEBIT'))
			 WHEN FSI.PerDiemType = 1 THEN (SELECT dbo.GLAccountDivision(@Company,FSI.Division,VarC) FROM @tblParameters WHERE Company IN (@Company, 'ALL') AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'PRD_CREDITACCOUNT', 'PRD_DEBITACCOUNT'))
		ELSE 'Not Mapped' END AS DebitAccount,
		CASE WHEN FSI.RecordType = 'VND' AND FSI.AccCode = @Demurrage THEN (SELECT dbo.GLAccountDivision(@Company,FSI.Division,VarC) FROM @tblParameters WHERE Company IN (@Company, 'ALL') AND ParameterCode = IIF(FSI.InvoiceType = 'C' OR FSI.ChargeAmount1 < 0, 'DEMURRAGE_AP_DEBIT', 'DEMURRAGE_AP_CREDIT')) -- AND FSI.CustomerNumber IN (SELECT CustomerId FROM @tblCustomers) 
			 WHEN FSI.PrePay = 1 AND FSI.PrePayType = 'P' AND FSI.ICB_AP = 0 AND @CTF_Codes NOT LIKE ('%' + FSI.AccCode + '%') AND FSI.RecordCode NOT IN (SELECT VendorCode FROM @tblVendors) THEN (SELECT VarC FROM @tblParameters WHERE Company = @Company AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'FSIVENDORDEBACCT', 'FSIVENDORPREPAYDEBACCT'))
			 WHEN FSI.PrePay = 1 AND FSI.PrePayType = 'P' AND FSI.ICB_AP = 0 AND @CTF_Codes LIKE ('%' + FSI.AccCode + '%') AND FSI.RecordCode NOT IN (SELECT VendorCode FROM @tblVendors) THEN (SELECT REPLACE(VarC, 'DD', FSI.Division) FROM @tblParameters WHERE Company = @Company AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'FSI_CTF_DEBIT', 'FSI_CTF_CREDIT'))
			 WHEN FSI.AR_PrePayType = 'A' OR FSI.PrePayType = 'A' THEN (SELECT VarC FROM @tblParameters WHERE Company = @Company AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'FSIACCRUDCREDIT','FSIACCRUDDEBIT'))
			 WHEN FSI.RecordCode IN (SELECT VendorCode FROM @tblVendors) THEN (SELECT VarC FROM @tblParameters WHERE Company = @Company AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'PIERPASS_ACCT_DEBIT','PIERPASS_ACCT_CREDIT'))
			 WHEN FSI.PerDiemType = 1 THEN (SELECT dbo.GLAccountDivision(@Company,FSI.Division,VarC) FROM @tblParameters WHERE Company IN (@Company, 'ALL') AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'PRD_DEBITACCOUNT', 'PRD_CREDITACCOUNT'))
		ELSE 'Not Mapped' END AS CreditAccount,
		CASE WHEN FSI.RecordType = 'VND' AND FSI.AccCode = @Demurrage THEN 'DEMURRAGE' --AND FSI.CustomerNumber IN (SELECT CustomerId FROM @tblCustomers) 
			 WHEN FSI.PrePay = 1 AND FSI.PrePayType = 'P' AND FSI.ICB_AP = 0 AND FSI.ICB_AP = 0 AND @CTF_Codes NOT LIKE ('%' + FSI.AccCode + '%') AND FSI.RecordCode NOT IN (SELECT VendorCode FROM @tblVendors) THEN 'PREPAY'
			 WHEN FSI.PrePay = 1 AND FSI.PrePayType = 'P' AND FSI.ICB_AP = 0 AND FSI.ICB_AP = 0 AND @CTF_Codes LIKE ('%' + FSI.AccCode + '%') AND FSI.RecordCode NOT IN (SELECT VendorCode FROM @tblVendors) THEN 'PREPAY CTF'
			 WHEN FSI.AR_PrePayType = 'A' OR FSI.PrePayType = 'A' THEN 'ACCRUAL'
			 WHEN FSI.AccCode <> @Demurrage AND FSI.RecordCode IN (SELECT VendorCode FROM @tblVendors) THEN 'PIERPASS'
			 WHEN FSI.PerDiemType = 1 THEN 'PERDIEM'
		ELSE 'Unknow' END AS TransactionType,
		CASE WHEN RecordType = 'VND' THEN 'AP' ELSE 'AR' END AS SourceType,
		FSI.Processed,
		FSI.SubProcessed,
		ISNULL(FSI.ExternalId, 0) AS ExternalId
FROM	#tmpFSISubData FSI
WHERE	(
			FSI.RecordType = 'VND' 
			AND FSI.SubProcessed = @Status
			AND ((FSI.PrePay = 1 AND ISNULL(FSI.PrePayType, '') IN ('','P'))
			OR FSI.PrePayType = 'A' 
			OR FSI.PerDiemType = 1 
			OR FSI.RecordCode IN (SELECT VendorCode FROM @tblVendors)
			OR FSI.AccCode = @Demurrage)
		)
		OR
		(
			FSI.RecordType = 'ACC' 
			AND FSI.Processed = @Status
			AND (ISNULL(FSI.AR_PrePayType, 'N') = 'A' 
			OR FSI.PerDiemType = 1)
		)

DROP TABLE #tmpFSISubData