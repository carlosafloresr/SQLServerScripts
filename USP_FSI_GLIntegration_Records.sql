USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[USP_FSI_GLIntegration_Records]    Script Date: 1/27/2023 8:56:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_FSI_GLIntegration_Records 'GLSO', '9FSI20230125_1451', 1
*/
ALTER PROCEDURE [dbo].[USP_FSI_GLIntegration_Records]
		@Company		Varchar(5), 
		@BatchId		Varchar(25),
		@Status			Smallint = 0
AS
SET NOCOUNT ON

DECLARE @CompanyNumber	Smallint,
		@CTF_Codes		Varchar(20)
DECLARE @Demurrage		Varchar(10) = (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters WITH (NOLOCK) WHERE Company = @Company AND ParameterCode = 'DEMURRAGE_ACCCODE')
DECLARE @tblVendors		Table (VendorCode Varchar(15), VndType Char(2))
DECLARE	@tblParCodes	Table (ParCode Varchar(50))
DECLARE	@tblParameters	Table (Company Varchar(5), ParameterCode Varchar(75), VarC Varchar(250))
DECLARE	@tblDivisions	Table (FromDiv Varchar(5), ToDiv Varchar(5), Product Char(1))

SET @CompanyNumber = (SELECT CompanyNumber FROM PRISQL01P.GPCustom.dbo.Companies WITH (NOLOCK) WHERE CompanyId = @Company)

INSERT INTO @tblVendors
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

INSERT INTO @tblParameters
SELECT	Company, ParameterCode, VarC
FROM	PRISQL01P.GPCustom.dbo.Parameters WITH (NOLOCK)
WHERE	ParameterCode IN (SELECT ParCode FROM @tblParCodes)
		AND Company = @Company

INSERT INTO @tblDivisions
SELECT	[Division_Original],
		[Division_Replace],
		[ProductSpecific]
FROM	PRISQL01P.GPCustom.dbo.RSA_Divisions_Mapping WITH (NOLOCK)
WHERE	Company = @Company
		AND Inactive = 0
		AND MappingType IN ('FSI','FSIP','ALL')

SET @CTF_Codes = ISNULL((SELECT VarC FROM @tblParameters WHERE ParameterCode = 'FSI_CTF_ACCCODES'),'0-0-0-0-0')

SELECT	*
INTO	#tmpSubDetais
FROM	FSI_ReceivedSubDetails
WHERE	BatchId = @BatchId
		AND Processed = @Status
		AND VndIntercompany = 0
		AND	((RecordType = 'VND' AND ((PrePay = 1 AND ISNULL(PrePayType, '') IN ('','P'))
			OR PrePayType = 'A'
			OR RecordCode IN (SELECT VendorCode FROM @tblVendors)
			OR AccCode = @Demurrage))
		OR RecordType = 'ACC') 

SELECT	FH.Company,
		FD.BatchId,
		WeekEndDate,
		InvoiceType,
		InvoiceNumber,
		InvoiceDate,
		Equipment,
		Division,
		FSI_ReceivedSubDetailId,
		PrePay,
		IIF(FS.PrePayType IN ('A','P'), FS.PrePayType, Null) AS PrePayType,
		ISNULL(IIF(FD.PrePayType IN ('A','P'), FD.PrePayType, Null),'') AS AR_PrePayType,
		CAST(IIF(VND.VendorCode IS Null, 0, 1) AS Bit) AS PierPassType,
		ChargeAmount1,
		VendorDocument,
		LEFT(CASE WHEN FH.Company = 'GLSO' THEN InvoiceNumber + '|' + VendorDocument ELSE Equipment + '|' + InvoiceNumber END, 30) AS PrepayReference,
		RecordType,
		RecordCode,
		AccCode,
		FD.DetailId,
		ReceivedOn,
		PerDiemType,
		FD.Processed,
		FS.Processed AS SubProcessed,
		ExternalId,
		FS.ICB AS ICB_AP
INTO	#tmpFSISubData
FROM    FSI_ReceivedDetails FD WITH (NOLOCK)
		INNER JOIN FSI_ReceivedHeader FH WITH (NOLOCK) ON FD.BatchID = FH.BatchId
		INNER JOIN #tmpSubDetais FS WITH (NOLOCK) ON FD.BatchID = FS.BatchId AND FD.DetailId = FS.DetailId
		LEFT JOIN @tblVendors VND ON FS.RecordCode = VND.VendorCode AND FS.RecordType = 'VND'
WHERE	FD.BatchId = @BatchId
		AND FH.Company = @Company
		AND FS.VndIntercompany = 0
		AND (FS.Processed = @Status) --FD.Processed = @Status OR 
		AND	(RecordType = 'VND' OR (RecordType = 'ACC' AND (ISNULL(FD.PrePayType, 'N') = 'A')))

DROP TABLE #tmpSubDetais

DECLARE @tblFSIG_Data			Table (
	[Company]					[varchar](5) NOT NULL,
	[BatchId]					[varchar](25) NOT NULL,
	[WeekEndDate]				[smalldatetime] NOT NULL,
	[InvoiceNumber]				[varchar](20) NOT NULL,
	[InvoiceDate]				[datetime] NULL,
	[Equipment]					[varchar](15) NULL,
	[Division]					[char](2) NULL,
	[FSI_ReceivedSubDetailId]	[int] NULL,
	[PrePay]					[bit] NULL,
	[PrePayType]				[char](1) NULL,
	[AR_PrePayType]				[char](1) NOT NULL,
	[PierPassType]				[bit] NULL,
	[ChargeAmount1]				[money] NULL,
	[VendorDocument]			[nvarchar](30) NULL,
	[PrepayReference]			[nvarchar](67) NULL,
	[RecordType]				[char](3) NOT NULL,
	[RecordCode]				[varchar](12) NOT NULL,
	[AccCode]					[varchar](5) NULL,
	[DetailId]					[int] NULL,
	[ReceivedOn]				[smalldatetime] NOT NULL,
	[PerDiemType]				[bit] NULL,
	[DebitAccount]				[varchar](15) NULL,
	[CreditAccount]				[varchar](15) NULL,
	[TransactionType]			[varchar](10) NOT NULL,
	[SourceType]				[varchar](2) NOT NULL,
	[Processed]					[bit] NOT NULL,
	[SubProcessed]				[bit] NULL,
	[ExternalId]				[varchar](20) NOT NULL)

INSERT INTO @tblFSIG_Data
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
			 WHEN FSI.AR_PrePayType = 'A' OR FSI.PrePayType = 'A' THEN (SELECT VarC FROM @tblParameters WHERE Company = @Company AND ParameterCode = 'FSIACCRUDCREDIT') --IIF(FSI.InvoiceType = 'C', 'FSIACCRUDDEBIT','FSIACCRUDCREDIT'))
			 WHEN FSI.RecordCode IN (SELECT VendorCode FROM @tblVendors) THEN (SELECT VarC FROM @tblParameters WHERE Company = @Company AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'PIERPASS_ACCT_CREDIT', 'PIERPASS_ACCT_DEBIT'))
			 WHEN FSI.PerDiemType = 1 THEN (SELECT dbo.GLAccountDivision(@Company,FSI.Division,VarC) FROM @tblParameters WHERE Company IN (@Company, 'ALL') AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'PRD_CREDITACCOUNT', 'PRD_DEBITACCOUNT'))
		ELSE 'Not Mapped' END AS DebitAccount,
		CASE WHEN FSI.RecordType = 'VND' AND FSI.AccCode = @Demurrage THEN (SELECT dbo.GLAccountDivision(@Company,FSI.Division,VarC) FROM @tblParameters WHERE Company IN (@Company, 'ALL') AND ParameterCode = IIF(FSI.InvoiceType = 'C' OR FSI.ChargeAmount1 < 0, 'DEMURRAGE_AP_DEBIT', 'DEMURRAGE_AP_CREDIT')) -- AND FSI.CustomerNumber IN (SELECT CustomerId FROM @tblCustomers) 
			 WHEN FSI.PrePay = 1 AND FSI.PrePayType = 'P' AND FSI.ICB_AP = 0 AND @CTF_Codes NOT LIKE ('%' + FSI.AccCode + '%') AND FSI.RecordCode NOT IN (SELECT VendorCode FROM @tblVendors) THEN (SELECT VarC FROM @tblParameters WHERE Company = @Company AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'FSIVENDORDEBACCT', 'FSIVENDORPREPAYDEBACCT'))
			 WHEN FSI.PrePay = 1 AND FSI.PrePayType = 'P' AND FSI.ICB_AP = 0 AND @CTF_Codes LIKE ('%' + FSI.AccCode + '%') AND FSI.RecordCode NOT IN (SELECT VendorCode FROM @tblVendors) THEN (SELECT REPLACE(VarC, 'DD', FSI.Division) FROM @tblParameters WHERE Company = @Company AND ParameterCode = IIF(FSI.InvoiceType = 'C', 'FSI_CTF_DEBIT', 'FSI_CTF_CREDIT'))
			 WHEN FSI.AR_PrePayType = 'A' OR FSI.PrePayType = 'A' THEN (SELECT VarC FROM @tblParameters WHERE Company = @Company AND ParameterCode = 'FSIACCRUDDEBIT') --IIF(FSI.InvoiceType = 'C', 'FSIACCRUDCREDIT','FSIACCRUDDEBIT'))
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
--SELECT * FROM @tblFSIG_Data WHERE 
SELECT	DISTINCT DAT.Company,
		DAT.BatchId,
		DAT.WeekEndDate,
		DAT.InvoiceNumber,
		DAT.InvoiceDate,
		DAT.Equipment,
		DAT.Division,
		DAT.FSI_ReceivedSubDetailId,
		DAT.PrePay,
		DAT.PrePayType,
		DAT.AR_PrePayType,
		DAT.PierPassType,
		DAT.ChargeAmount1,
		DAT.VendorDocument,
		DAT.PrepayReference,
		DAT.RecordType,
		DAT.RecordCode,
		DAT.AccCode,
		DAT.DetailId,
		DAT.ReceivedOn,
		DAT.PerDiemType,
		CASE WHEN DAT.ChargeAmount1 > 0 THEN (CASE WHEN DIV1.ToDiv IS Null THEN DAT.DebitAccount ELSE LEFT(DAT.DebitAccount, 2) + DIV1.ToDiv + RIGHT(DAT.DebitAccount, 5) END)
			 ELSE (CASE WHEN DIV2.ToDiv IS Null THEN DAT.CreditAccount ELSE LEFT(DAT.CreditAccount, 2) + DIV2.ToDiv + RIGHT(DAT.CreditAccount, 5) END) END AS DebitAccount,
		CASE WHEN DAT.ChargeAmount1 > 0 THEN (CASE WHEN DIV2.ToDiv IS Null THEN DAT.CreditAccount ELSE LEFT(DAT.CreditAccount, 2) + DIV2.ToDiv + RIGHT(DAT.CreditAccount, 5) END)
			 ELSE (CASE WHEN DIV1.ToDiv IS Null THEN DAT.DebitAccount ELSE LEFT(DAT.DebitAccount, 2) + DIV1.ToDiv + RIGHT(DAT.DebitAccount, 5) END) END AS CreditAccount,
		DAT.TransactionType,
		DAT.SourceType,
		DAT.Processed,
		DAT.SubProcessed,
		DAT.ExternalId
FROM	@tblFSIG_Data DAT
		LEFT JOIN @tblDivisions DIV1 ON SUBSTRING(DAT.DebitAccount, 3, 2) = DIV1.FromDiv
		LEFT JOIN @tblDivisions DIV2 ON SUBSTRING(DAT.CreditAccount, 3, 2) = DIV2.FromDiv
ORDER BY DAT.TransactionType, DAT.ChargeAmount1

DROP TABLE #tmpFSISubData