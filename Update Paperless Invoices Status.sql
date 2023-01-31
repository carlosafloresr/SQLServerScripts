--SELECT * FROM PaperlessInvoices

UPDATE	FSI_ReceivedDetails
SET		FSI_ReceivedDetails.RecordStatus = 2
WHERE	FSI_ReceivedDetailId IN (
SELECT	FSID.FSI_ReceivedDetailId
	FROM	Integrations.dbo.FSI_ReceivedDetails FSID
			INNER JOIN Integrations.dbo.FSI_ReceivedHeader FSIH ON FSID.BatchId = FSIH.BatchId
			INNER JOIN ILSGP01.GPCustom.dbo.CustomerMaster CUMA ON FSIH.Company = CUMA.CompanyId AND FSID.CustomerNumber = CUMA.CustNmbr AND CUMA.InvoiceEmailOption > 1
			INNER JOIN ILSGP01.GPCustom.dbo.Companies COMP ON FSIH.Company = COMP.CompanyId
			INNER JOIN PaperlessInvoices PLIN ON FSIH.Company = PLIN.Company AND FSID.CustomerNumber = PLIN.Customer AND FSID.InvoiceNumber = PLIN.InvoiceNumber
	WHERE	FSID.RecordStatus = 1
			AND FSID.InvoiceType <> 'C'
	ORDER BY FSIH.Company, FSID.CustomerNumber


	/*
	DISTINCT FSIH.Company
			,FSID.CustomerNumber
			,CUMA.InvoiceEmailOption
			,FSID.InvoiceNumber
			,CASE FSIH.Company WHEN 'NDS' THEN CAST(LEFT(FSIH.BatchId, 2) AS Integer) ELSE COMP.CompanyNumber END AS CompanyNumber
			,
	*/