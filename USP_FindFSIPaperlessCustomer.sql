/*
EXECUTE USP_FindFSIPaperlessCustomer '7FSI111014_1623'
EXECUTE USP_FindFSIPaperlessCustomer '25FSI111025_1841'
*/
ALTER PROCEDURE USP_FindFSIPaperlessCustomer (@BatchId Varchar(25))
AS
SELECT	DISTINCT FSID.CustomerNumber
		,FSIH.Company
		,CUMA.InvoiceEmailOption
		,CASE @BatchId WHEN 'NDS' THEN CAST(LEFT(@BatchId, 2) AS Integer) ELSE COMP.CompanyNumber END AS CompanyNumber
FROM	Integrations.dbo.FSI_ReceivedDetails FSID
		INNER JOIN Integrations.dbo.FSI_ReceivedHeader FSIH ON FSID.BatchId = FSIH.BatchId
		INNER JOIN ILSGP01.GPCustom.dbo.CustomerMaster CUMA ON FSIH.Company = CUMA.CompanyId AND FSID.CustomerNumber = CUMA.CustNmbr AND CUMA.InvoiceEmailOption > 1
		INNER JOIN ILSGP01.GPCustom.dbo.Companies COMP ON FSIH.Company = COMP.CompanyId
WHERE	FSID.BatchId = @BatchId
		AND FSID.RecordStatus = 0