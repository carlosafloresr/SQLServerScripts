UPDATE	FSI_ReceivedDetails
SET		FSI_ReceivedDetails.RecordStatus = 1
FROM	(
		SELECT	FSI.FSI_ReceivedDetailId
		FROM	FSI_ReceivedDetails FSI
				INNER JOIN View_Integration_FSI VIW ON FSI.FSI_ReceivedDetailId = VIW.FSI_ReceivedDetailId
		WHERE	FSI.InvoiceNumber IN (SELECT InvoiceNumber FROM PaperlessInvoices)
		) RECS
WHERE	FSI_ReceivedDetails.FSI_ReceivedDetailId = RECS.FSI_ReceivedDetailId
GO

EXECUTE USP_FindSelectedPaperlessInvoices

-- SELECT * INTO BACKUP_PaperlessInvoices FROM PaperlessInvoices
-- TRUNCATE TABLE PaperlessInvoices

SELECT * FROM PaperlessInvoices