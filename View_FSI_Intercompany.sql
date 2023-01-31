USE [Integrations]
GO

/****** Object:  View [dbo].[View_FSI_Intercompany]    Script Date: 1/30/2023 2:58:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*
SELECT * FROM View_FSI_Intercompany WHERE BatchId = '1TIP1601051715'
SELECT * FROM View_FSI_Intercompany WHERE OriginalBatchId = '9FSI20201207_1529' 
SELECT * FROM View_FSI_Intercompany WHERE OriginalBatchId = '1FSI20210125_1618' AND RecordId IN (6806581,6806583)
AND InvoiceNumber = '95-118968_T'
*/
ALTER VIEW [dbo].[View_FSI_Intercompany]
AS
-- AR Transactions [AccountNumber = Credit/InterAccount = Debit]
SELECT	DET.FSI_ReceivedDetailId AS RecordId
		,HDR.Company
		,REPLACE(REPLACE(REPLACE(DET.BatchId, CAST(YEAR(HDR.ReceivedOn) AS Varchar), SUBSTRING(CAST(YEAR(HDR.ReceivedOn) AS Varchar), 3, 2)), '_', ''), 'FSI', 'TIP') AS BatchId
		,HDR.WeekEndDate
		,DET.CustomerNumber AS BooksAccount
		,DET.InvoiceNumber
		,DET.InvoiceDate
		,DET.InvoiceTotal AS Amount
		,DET.BillToRef
		,ARAP.LinkedCompany
		,CASE WHEN DET.InvoiceType = 'C' THEN ACCT.AccountNumber ELSE CASE WHEN DET.ICB = 1 THEN CASE WHEN PARC.VarC LIKE '%AA%' THEN REPLACE(REPLACE(PARC.VarC, 'DD', RTRIM(ISNULL(RDM.Division_Replace, DET.Division))), 'AA', LEFT(DET.BatchId, 2)) ELSE PARC.VarC END
		 ELSE ACCT.AccountNumber END END AS AccountNumber
		--,IIF(DET.PrePayType = 'A', ACCT.AccountNumber, CASE WHEN PARD.VarC LIKE '%AA%' THEN REPLACE(REPLACE(PARD.VarC, 'DD', RTRIM(ISNULL(RDM.Division_Replace, DET.Division))), 'AA', LEFT(DET.BatchId, 2)) ELSE PARD.VarC END) AS InterAccount
		,CASE WHEN DET.InvoiceType <> 'C' THEN ACCT.AccountNumber ELSE CASE WHEN DET.ICB = 1 THEN CASE WHEN PARC.VarC LIKE '%AA%' THEN REPLACE(REPLACE(PARC.VarC, 'DD', RTRIM(ISNULL(RDM.Division_Replace, DET.Division))), 'AA', LEFT(DET.BatchId, 2)) ELSE PARC.VarC END
		 ELSE PARD.VarC END END AS InterAccount
		,IIF(DET.ICB = 0, 'Inv#', 'ICB|') + RTRIM(DET.InvoiceNumber) + IIF(DET.ICB = 0, '/Ref#', '|') + RTRIM(DET.BillToRef) AS Description
		,DET.Processed
		,ISNULL(ACCT.LinkType, '') AS LinkType
		,DET.Division
		,'AR' AS Source
		,DET.BatchId AS FSIBatchId
		,DET.Processed AS TIPProcessed
		,DET.BatchId AS OriginalBatchId
		,HDR.ReceivedOn
		,PARC.VarC
		,DET.ICB
		,0 AS PrePay
		,ISNULL(DET.PrePayType, '') AS AR_PrePayType
		,PARC.ParameterCode AS Parameter
		,0 AS FSI_ReceivedSubDetailId
		,DET.Intercompany
		,0 AS VndIntercompany
		,CASE WHEN ARAP.Account IS Null THEN 'Unmapped ' + IIF(DET.ICB = 1, 'ICB','FRGT') + ' Customer'
			  WHEN ACCT.LinkType IS Null THEN 'Unmapped ' + IIF(DET.ICB = 1, 'ICB','FRGT') + ' GL Account'
		ELSE '' END MappingValidation,
		DET.Equipment,
		0 AS ExternalId
FROM	FSI_ReceivedDetails DET WITH (NOLOCK)
		INNER JOIN FSI_ReceivedHeader HDR WITH (NOLOCK) ON DET.BatchId = HDR.BatchId
		LEFT JOIN FSI_Intercompany_ARAP ARAP ON HDR.Company = ARAP.Company AND DET.CustomerNumber = ARAP.Account AND ARAP.RecordType = 'C' AND ARAP.ForGLIntegration = 1 AND ARAP.Transtype = IIF(DET.ICB = 1, 'ICB', 'FRG')
		LEFT JOIN FSI_Intercompany_Companies ACCT ON HDR.Company = ACCT.ForCompany AND ARAP.LinkedCompany = ACCT.LinkedCompany AND ACCT.LinkType = 'R' AND ACCT.Transtype = IIF(DET.ICB = 1, 'ICB', 'FRG')
		LEFT JOIN PRISQL01P.GPCustom.dbo.Parameters PARD ON HDR.Company = PARD.Company AND PARD.ParameterCode = IIF(DET.ICB = 0, 'FSISALESCREACCT', 'ICB_DEBIT_ACCT')
		LEFT JOIN PRISQL01P.GPCustom.dbo.Parameters PARC ON HDR.Company = PARC.Company AND PARC.ParameterCode = IIF(DET.ICB = 0, 'FSISALESDEBACCT', 'ICB_CREDIT_ACCT')
		LEFT JOIN PRISQL01P.GPCustom.dbo.RSA_Divisions_Mapping RDM WITH (NOLOCK) ON HDR.Company = RDM.Company AND DET.Division = RDM.Division_Original AND RDM.MappingType = 'ALL'
WHERE	DET.Intercompany = 1
		OR DET.ICB = 1
UNION
-- AP Transactions
SELECT	SUB.FSI_ReceivedSubDetailId AS RecordId
		,HDR.Company
		,REPLACE(REPLACE(REPLACE(DET.BatchId, CAST(YEAR(HDR.ReceivedOn) AS Varchar), SUBSTRING(CAST(YEAR(HDR.ReceivedOn) AS Varchar), 3, 2)), '_', ''), 'FSI', 'TIP') AS BatchId
		,HDR.WeekEndDate
		,SUB.RecordCode AS BooksAccount
		,DET.InvoiceNumber
		,DET.InvoiceDate
		,SUB.ChargeAmount1 + SUB.ChargeAmount2 AS Amount
		,DET.BillToRef
		,ARAP.LinkedCompany
		,CASE	WHEN SUB.ICB = 1 AND SUB.PrePay = 0 THEN ACCT.AccountNumber
				WHEN SUB.ICB = 1 AND SUB.PrePay = 1 AND SUB.PrePayType = 'P' THEN (SELECT VarC FROM PRISQL01P.GPCustom.dbo.Parameters P1 WHERE P1.Company = HDR.Company AND P1.ParameterCode = 'ICB_CRDACCT')
				ELSE ACCT.AccountNumber 
		 END AS AccountNumber
		,IIF(SUB.ICB = 1 AND SUB.PrePay = 1, PAR.VarC, CASE WHEN PAR.VarC LIKE '%AA%' THEN REPLACE(REPLACE(PAR.VarC, 'DD', RTRIM(ISNULL(RDM.Division_Replace, DET.Division))), 'AA', LEFT(DET.BatchId, 2)) ELSE PAR.VarC END) AS InterAccount
		,IIF(SUB.ICB = 0, 'PN: ' + RTRIM(DET.InvoiceNumber) + '/CNT: ' + RTRIM(DET.Equipment), 'ICB|' + RTRIM(DET.InvoiceNumber) + '|' + RTRIM(SUB.VendorDocument)) AS Description
		,SUB.Processed
		,ISNULL(ACCT.LinkType, '') AS LinkType
		,DET.Division
		,'AP' AS Source
		,DET.BatchId AS FSIBatchId
		,SUB.Processed AS TIPProcessed
		,DET.BatchId AS OriginalBatchId
		,HDR.ReceivedOn
		,PAR.VarC
		,SUB.ICB
		,IIF(SUB.PrePay = 1 AND SUB.ICB = 0, 1, SUB.PrePay) AS PrePay
		,'' AS AR_PrePayType
		,CASE WHEN SUB.PrePay = 1 AND SUB.ICB = 0 AND SUB.PrePayType = 'P' THEN 'ICB_DEBACCT'
		WHEN SUB.PrePayType = 'A' THEN 'ICB_DEBACCT'
		ELSE 'ICB_DEBACCT' END AS Parameter
		,SUB.FSI_ReceivedSubDetailId
		,0 AS Intercompany
		,SUB.VndIntercompany
		,CASE WHEN ARAP.Account IS Null THEN 'Unmapped ' + IIF(SUB.ICB = 1, 'ICB','FRGT') + ' Vendor'
			  WHEN ACCT.LinkType IS Null THEN 'Unmapped ' + IIF(SUB.ICB = 1, 'ICB','FRGT') + ' GL Account'
		ELSE '' END MappingValidation,
		DET.Equipment,
		ISNULL(SUB.ExternalId,0) AS ExternalId
FROM	FSI_ReceivedSubDetails SUB WITH (NOLOCK)
		INNER JOIN FSI_ReceivedDetails DET WITH (NOLOCK) ON SUB.BatchId = DET.BatchId AND SUB.DetailId = DET.DetailId
		INNER JOIN FSI_ReceivedHeader HDR WITH (NOLOCK) ON DET.BatchId = HDR.BatchId
		LEFT JOIN FSI_Intercompany_ARAP ARAP ON HDR.Company = ARAP.Company AND SUB.RecordCode = ARAP.Account AND ARAP.RecordType = 'V' AND ARAP.ForGLIntegration = 1 AND ARAP.Transtype = IIF(SUB.ICB = 1, 'ICB', 'FRG')
		LEFT JOIN FSI_Intercompany_Companies ACCT ON HDR.Company = ACCT.ForCompany AND ARAP.LinkedCompany = ACCT.LinkedCompany AND ACCT.LinkType = 'P' AND ACCT.Transtype = IIF(SUB.ICB = 1, 'ICB', 'FRG')
		LEFT JOIN PRISQL01P.GPCustom.dbo.Parameters PAR ON HDR.Company = PAR.Company AND PAR.ParameterCode = CASE 
			WHEN SUB.PrePay = 1 AND SUB.ICB = 0 AND SUB.PrePayType = 'P' THEN 'FSIVENDORPREPAYDEBACCT' 
			WHEN SUB.PrePay = 1 AND SUB.ICB = 1 AND SUB.PrePayType = 'P' THEN 'ICB_DEBACCT' 
			WHEN SUB.ICB = 0 AND SUB.PrePayType = 'A' THEN 'ICB_DEBACCT' 
			ELSE 'ICB_DEBACCT' END
		LEFT JOIN PRISQL01P.GPCustom.dbo.RSA_Divisions_Mapping RDM WITH (NOLOCK) ON HDR.Company = RDM.Company AND DET.Division = RDM.Division_Original AND RDM.MappingType = 'ALL'
WHERE	SUB.ChargeAmount1 <> 0
		AND (SUB.RecordType = 'VND' AND (SUB.VndIntercompany = 1 OR SUB.ICB = 1) AND SUB.AccCode <> 'DEM')
GO


