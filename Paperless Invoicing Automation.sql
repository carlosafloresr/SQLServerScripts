/*
EXECUTE USP_Automate_InvoicesByEmail 'AIS', 0
*/
ALTER PROCEDURE USP_Automate_InvoicesByEmail (@Company Varchar(5), @JustData Bit = 0)
AS
IF @JustData = 1
BEGIN
	UPDATE	FSI_ReceivedDetails
	SET		RecordStatus = 1
	FROM	(
			SELECT	FSIH.Company
					,FSID.CustomerNumber
					,CUMA.InvoiceEmailOption
					,CASE FSIH.Company WHEN 'NDS' THEN CAST(LEFT(FSIH.BatchId, 2) AS Integer) ELSE COMP.CompanyNumber END AS CompanyNumber
					,FSID.InvoiceType
					,FSID.FSI_ReceivedDetailId
			FROM	Integrations.dbo.FSI_ReceivedDetails FSID
					INNER JOIN Integrations.dbo.FSI_ReceivedHeader FSIH ON FSID.BatchId = FSIH.BatchId
					INNER JOIN ILSGP01.GPCustom.dbo.CustomerMaster CUMA ON FSIH.Company = CUMA.CompanyId AND FSID.CustomerNumber = CUMA.CustNmbr AND CUMA.InvoiceEmailOption > 1
					INNER JOIN ILSGP01.GPCustom.dbo.Companies COMP ON FSIH.Company = COMP.CompanyId
					LEFT JOIN PaperlessInvoices PEP ON FSIH.Company = PEP.Company AND FSID.CustomerNumber = PEP.Customer AND FSID.InvoiceNumber = PEP.InvoiceNumber
			WHERE	FSID.RecordStatus = 0
					--AND FSIH.WeekEndDate > '03/08/2013'
					AND FSID.InvoiceTotal > 0.1
					AND FSIH.Company = @Company
					AND PEP.RunDate IS Null
			) RECS
	WHERE	FSI_ReceivedDetails.FSI_ReceivedDetailId = RECS.FSI_ReceivedDetailId
END
ELSE
BEGIN
	SELECT	DISTINCT dbo.PROPER(RTRIM(CUMA.CustName)) + ' [' + RTRIM(FSID.CustomerNumber) + ']' AS CustomerName,
			RTRIM(FSID.CustomerNumber) AS CustomerNumber
	FROM	Integrations.dbo.FSI_ReceivedDetails FSID
			INNER JOIN Integrations.dbo.FSI_ReceivedHeader FSIH ON FSID.BatchId = FSIH.BatchId
			INNER JOIN ILSGP01.GPCustom.dbo.CustomerMaster CUMA ON FSIH.Company = CUMA.CompanyId AND FSID.CustomerNumber = CUMA.CustNmbr AND CUMA.InvoiceEmailOption > 1
			INNER JOIN ILSGP01.GPCustom.dbo.Companies COMP ON FSIH.Company = COMP.CompanyId
			LEFT JOIN PaperlessInvoices PEP ON FSIH.Company = PEP.Company AND FSID.CustomerNumber = PEP.Customer AND FSID.InvoiceNumber = PEP.InvoiceNumber
	WHERE	FSID.RecordStatus = 0
			AND FSID.InvoiceTotal > 0.1
			AND FSIH.Company = @Company
			AND PEP.RunDate IS Null
	ORDER BY 1
END