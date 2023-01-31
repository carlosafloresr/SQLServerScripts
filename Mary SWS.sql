DECLARE	@BatchId		Varchar(20)

DECLARE @tblSWSData		Table (
		DivPro			Varchar(20),
		Base_Pro		Varchar(20),
		Container		Varchar(20),
		Vendor_Code		Varchar(20),
		Vendor			Varchar(100),
		Prepay			Char(1),
		Acc_Code		Varchar(10),
		Acc_Descrip		Varchar(100),
		Amount			Numeric(10,2),
		Vendor_Invoice	Varchar(50),
		Invoiced_Date	Date,
		Created_Date	Date,
		RecordType		Varchar(20),
		VendorDocument	Varchar(50),
		ChargeAmount1	Numeric(10,2),
		BatchId			Varchar(20),
		TransType		Varchar(20),
		IntegrationType	Varchar(5),
		Reference		Varchar(75),
		Previous		bit)

INSERT INTO @tblSWSData
SELECT	CND.DivPro
		,CND.Base_Pro
		,CND.container
		,CND.Vendor_Code
		,CND.Vendor
		,ISNULL(CND.prepay,'')
		,CND.accessorial_code
		,CND.Accessorial_Description
		,CND.amount
		,CND.vendor_invoice
		,CND.Invoiced_Date
		,CND.Created_Date
		,FSI.RecordType
		,FSI.VendorDocument
		,FSI.ChargeAmount1
		,FSI.BatchId
		,FTD.TransType
		,FTD.IntegrationType
		,FTD.RefDocument
		,0
FROM	TEMP_IMCNA_CD CND
		LEFT JOIN IntegrationsDB.Integrations.dbo.View_Integration_FSI_Full FSI ON CND.DivPro = FSI.InvoiceNumber AND FSI.Company = 'GLSO' AND FSI.RecordType = 'VND' AND ROUND(CND.amount, 2) = FSI.ChargeAmount1
		LEFT JOIN IntegrationsDB.Integrations.dbo.FSI_TransactionDetails FTD ON FSI.FSI_ReceivedSubDetailId = FTD.SourceRecordId AND FTD.SourceType = 'AP'

INSERT INTO	tmpMary_CNDs
SELECT	*
FROM	@tblSWSData
WHERE	BatchId IS NOT Null
		AND IntegrationType IS NOT Null

--DECLARE curSWSMatch CURSOR LOCAL KEYSET OPTIMISTIC FOR
--SELECT	DISTINCT BatchId
--FROM	@tblSWSData
--WHERE	IntegrationType IS Null

--OPEN curSWSMatch 
--FETCH FROM curSWSMatch INTO @BatchId

--WHILE @@FETCH_STATUS = 0 
--BEGIN
--	PRINT @BatchId

--	EXECUTE IntegrationsDB.Integrations.dbo.USP_FSI_TransactionDetails @BatchId

--	FETCH FROM curSWSMatch INTO @BatchId
--END

--CLOSE curSWSMatch
--DEALLOCATE curSWSMatch

--DROP TABLE tmpMary_CNDs