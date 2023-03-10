USE [Integrations]
GO
/****** Object:  StoredProcedure [dbo].[USP_FSI_APIntegration_Select]    Script Date: 9/8/2021 10:35:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_FSI_APIntegration_Select_GLSO 'GLSO', '9FSI20210723_1149', 0
*/
ALTER PROCEDURE [dbo].[USP_FSI_APIntegration_Select_GLSO]
		@Company	Varchar(5),
		@BatchId	Varchar(25),
		@Status		Smallint = 0
AS
DECLARE @CompanyNumber	Smallint
DECLARE @tblVendors		Table (Company Varchar(5), VendorCode Varchar(15), VndType Char(2))
DECLARE @tblDocuments	Table (VndDoc Varchar(50), DocumentCounter Int)
DECLARE @tblCustomers	Table (CustomerId Varchar(15), CustType Char(3))
DECLARE	@tblParameters	Table (ParameterCode Varchar(50), VarC Varchar(100))

SET @CompanyNumber = (SELECT CompanyNumber FROM SECSQL01T.GPCustom.dbo.Companies WHERE CompanyId = @Company)

INSERT INTO @tblVendors
SELECT	Company, 
		VendorId,
		'PP'
FROM	SECSQL01T.GPCustom.dbo.GPVendorMaster 
WHERE	Company = @Company 
		AND PierPassType = 1

INSERT INTO @tblDocuments
SELECT	VendorDocument,
		COUNT(*)
FROM	View_Integration_FSI_Vendors
WHERE	Company = @Company
		AND BatchId =  @BatchId
GROUP BY VendorDocument

INSERT INTO @tblCustomers
SELECT	CustNmbr,
		'DEM'
FROM	SECSQL01T.GPCustom.dbo.CustomerMaster
WHERE	CompanyId = @Company 
		AND WithDemurrage = 1

INSERT INTO @tblParameters
SELECT	ParameterCode, VarC
FROM	SECSQL01T.GPCustom.dbo.Parameters
WHERE	ParameterCode IN ('FSIVENDORDEBACCT','FSIVENDORCREACCT')
		AND Company = @Company

SELECT	DISTINCT *
FROM	(
SELECT	DISTINCT FSI.*,
		CASE WHEN LEN(VendorDocument) > 19 THEN LEFT(VendorDocument, 16) + '_' + RIGHT(CAST(FSI_ReceivedSubDetailId AS Varchar), 3) 
			 WHEN LEN(VendorDocument) <= 20 AND FSU.DocumentCounter > 1 THEN RTRIM(LEFT(VendorDocument, 16)) + '_' + RIGHT(CAST(FSI_ReceivedSubDetailId AS Varchar), 3)
			 ELSE VendorDocument END AS APDocument,
		CAST(ISNULL(PAR.ParBit, 0) AS Bit) AS FSIAP_Hold,
		FSU.DocumentCounter,
		DebitAccount = (SELECT VarC FROM @tblParameters WHERE ParameterCode = IIF(FSI.ChargeAmount1 > 0, 'FSIVENDORDEBACCT','FSIVENDORCREACCT')),
		CreditAccount = (SELECT VarC FROM @tblParameters WHERE ParameterCode = IIF(FSI.ChargeAmount1 > 0, 'FSIVENDORCREACCT','FSIVENDORDEBACCT'))
FROM	View_Integration_FSI_Vendors FSI
		INNER JOIN @tblDocuments FSU ON FSI.VendorDocument = FSU.VndDoc
		LEFT JOIN SECSQL01T.GPCustom.dbo.Companies_Parameters PAR ON FSI.Company = PAR.CompanyId AND PAR.ParameterCode = 'FSI_AP_Hold'
		LEFT JOIN SECSQL01T.GPCustom.dbo.Parameters PA2 ON PA2.Company = FSI.Company AND PA2.ParameterCode = 'DEMURRAGE_ACCCODE' AND FSI.AccCode = PA2.VarC
WHERE	FSI.Company = @Company
		AND BatchId =  @BatchId
		AND VndIntercompany = 0 
		AND RecordCode NOT IN (SELECT VendorCode FROM @tblVendors)
		AND Processed = @Status
		AND NOT (FSI.AccCode = PA2.VarC)
		--AND ((@Status = 0 
		--	AND FSI_ReceivedSubDetailId NOT IN (SELECT RecordId FROM FSI_PayablesRecords)
		--	AND Processed = @Status)
		--	OR @Status = 1)
		) DAT
ORDER BY APDocument

