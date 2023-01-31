USE [Integrations]
GO

SET NOCOUNT OFF

DECLARE	@Company		Varchar(5) = 'nds'
DECLARE	@RunDate		Date = GETDATE()
DECLARE	@WeekEndDate	Date = CASE WHEN DATENAME(Weekday, @RunDate) = 'Saturday' THEN @RunDate ELSE dbo.DayFwdBack(@RunDate, 'P', 'Saturday') END

PRINT @WeekEndDate

--DELETE	PaperlessInvoices
--WHERE	Company = @Company
--		--AND Customer = '119D'
--		AND InvoiceNumber IN (	SELECT	FSID.InvoiceNumber
--								FROM	FSI_ReceivedDetails FSID
--										INNER JOIN Integrations.dbo.FSI_ReceivedHeader FSIH ON FSID.BatchId = FSIH.BatchId AND FSIH.WeekEndDate BETWEEN DATEADD(dd, -6, @WeekEndDate) AND @WeekEndDate AND FSIH.Company = @Company
--										INNER JOIN ILSGP01.GPCustom.dbo.CustomerMaster CUMA ON FSIH.Company = CUMA.CompanyId AND FSID.CustomerNumber = CUMA.CustNmbr AND CUMA.InvoiceEmailOption > 1
--								--WHERE	FSID.CustomerNumber = '5703'
--								--WHERE	FSID.InvoiceNumber IN ('D8-419179','13-111760','D8-448724','D8-427099A','8-448976','8-448977','8-448978','8-448979','8-448980','8-448981','8-448982','8-448983','D8-444172','D8-440195','8-450294','8-450298','8-450479','8-450598','8-450601','8-450639','8-451099','D9-268694','8-446833-A')
--							)

--DELETE	PaperlessInvoices
--WHERE	InvoiceNumber IN (SELECT InvoiceNumber FROM FSI_ReceivedDetails WHERE VoucherNumber IN (SELECT DocumentNumber FROM InvoicesToRun WHERE Company = @Company))
--		AND Company = @Company

UPDATE	FSI_ReceivedDetails
SET		RecordStatus = 1
WHERE	InvoiceNumber IN (	SELECT	FSID.InvoiceNumber
							FROM	FSI_ReceivedDetails FSID
									INNER JOIN Integrations.dbo.FSI_ReceivedHeader FSIH ON FSID.BatchId = FSIH.BatchId AND FSIH.WeekEndDate BETWEEN DATEADD(dd, -6, @WeekEndDate) AND @WeekEndDate
									INNER JOIN LENSASQL001.GPCustom.dbo.CustomerMaster CUMA ON FSIH.Company = CUMA.CompanyId AND FSID.CustomerNumber = CUMA.CustNmbr AND CUMA.InvoiceEmailOption > 1
									LEFT JOIN Integrations.dbo.PaperlessInvoices PAPL ON FSID.InvoiceNumber = PAPL.InvoiceNumber AND FSID.CustomerNumber = PAPL.Customer AND FSIH.Company = PAPL.Company
							WHERE	FSIH.Company = @Company
									AND FSID.InvoiceTotal > 0
									AND PAPL.InvoiceNumber IS NULL
							--WHERE	FSID.CustomerNumber = '11304'
							--WHERE	FSID.InvoiceNumber IN ('21-145166')
							--WHERE	FSID.InvoiceNumber IN (SELECT InvoiceNumber FROM FSI_ReceivedDetails WHERE VoucherNumber IN (SELECT DocumentNumber FROM InvoicesToRun WHERE Company = @Company))
						 )

SELECT	FSID.CustomerNumber, 
		FSID.InvoiceNumber, 
		FSID.RecordStatus, 
		FSIH.WeekEndDate,
		CUMA.InvoiceEmailOption
FROM	FSI_ReceivedDetails FSID
		INNER JOIN Integrations.dbo.FSI_ReceivedHeader FSIH ON FSIH.Company = @Company AND FSID.BatchId = FSIH.BatchId AND FSIH.WeekEndDate BETWEEN DATEADD(dd, -6, @WeekEndDate) AND @WeekEndDate
		INNER JOIN LENSASQL001.GPCustom.dbo.CustomerMaster CUMA ON FSIH.Company = CUMA.CompanyId AND FSID.CustomerNumber = CUMA.CustNmbr AND CUMA.InvoiceEmailOption > 1
		LEFT JOIN Integrations.dbo.PaperlessInvoices PAPL ON FSID.InvoiceNumber = PAPL.InvoiceNumber AND FSID.CustomerNumber = PAPL.Customer AND FSIH.Company = PAPL.Company
WHERE	LEFT(FSID.InvoiceNumber, 1) NOT IN ('C')
		AND PAPL.InvoiceNumber IS NULL
		AND FSID.RecordStatus = 1
		AND FSID.InvoiceTotal > 0
		--AND FSID.CustomerNumber = '5703'
ORDER BY FSID.CustomerNumber, FSID.InvoiceNumber

-- truncate table invoicestorun
