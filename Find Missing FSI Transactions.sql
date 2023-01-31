USE [Integrations]
GO

DECLARE @tblVendors	Table (Company Varchar(5), VendorCode Varchar(15), VndType Char(2))

INSERT INTO @tblVendors
--SELECT	Company,
--		VarC,
--		'PD'
--FROM	PRISQL01P.GPCustom.dbo.Parameters 
--WHERE	Company = @Company
--		AND ParameterCode = 'PRD_VENDORCODE'
--UNION
SELECT	Company, 
		VendorId,
		'PP'
FROM	PRISQL01P.GPCustom.dbo.GPVendorMaster 
WHERE	Company = 'AIS' 
		AND PierPassType = 1

--update PRISQL01P.GPCustom.dbo.GPVendorMaster 
--set		PierPassType = 0
--WHERE	Company = 'GLSO' 
--		AND PierPassType = 1

SELECT	*, CAST(FSI_ReceivedSubDetailId AS varchar) + ',' AS RecordId, '''' + InvoiceNumber + ''','
--SELECT	distinct batchid
--SELECT	Company, BatchId, InvoiceNumber, CustomerNumber, InvoiceTotal
FROM	View_Integration_FSI_Full
WHERE	--BatchId IN ('9FSI20200603_1420')
		--BatchId LIKE '3FSI20200429_1141%'
		InvoiceNumber IN ('57-122355')	
		-- FSIP
		--AND RecordCode IN ('100','1073')
		AND RecordType = 'EQP'
		--AND RecordType = 'VND'
		AND (PrePay = 0
		AND PrePayType IS Null
		AND VndIntercompany = 0 
		AND RecordCode NOT IN (SELECT VendorCode FROM @tblVendors))
		-- FSIP
		OR 
		-- FSIG
		(VndIntercompany = 0
		AND (RecordType = 'VND'
		AND (((PrePay = 1 AND ISNULL(PrePayType, '') IN ('','P')))
		OR PrePayType = 'A' 
		OR PerDiemType = 1 
		OR RecordCode IN (SELECT VendorCode FROM @tblVendors))
		OR ISNULL(AR_PrePayType, 'N') = 'A'))
		-- FSIG

ORDER BY BATCHID

/*
SELECT	* 
FROM	View_Integration_FSI_Full 
WHERE	BatchId = '6FSI20200120_1633' 
		AND Company = 'HMIS' 
		AND RecordType IN ('VND','EQP')
		AND ((PrePay = 1 AND ISNULL(PrePayType, '') IN ('','P')) OR PrePayType = 'A' OR AR_PrePayType IN ('A','P')) AND VndIntercompany = 0
		AND InvoiceNumber in ('54-113396-A','D54-111456-A','D54-111839-B')
*/