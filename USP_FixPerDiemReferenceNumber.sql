/*
EXECUTE USP_FixPerDiemReferenceNumber 'PD160823170304R'
*/
ALTER PROCEDURE USP_FixPerDiemReferenceNumber
		@BatchId	Varchar(25)
AS
UPDATE	SalesInvoices
SET		SalesInvoices.Notes2 = DATA.Reference
FROM	(
			SELECT	DISTINCT Company,
					CustNmbr,
					SopNumbe,
					'Reference Number: ' + RTRIM(Reference) AS Reference
			FROM	ILSINT02.Integrations.dbo.Integrations_SOP
			WHERE	Integration = 'PDINV'
					AND BACHNUMB = @BatchId
		) DATA
WHERE	SalesInvoices.CompanyId = DATA.Company
		AND SalesInvoices.CustomerId = DATA.CustNmbr
		AND SalesInvoices.InvoiceNumber = DATA.SopNumbe
		AND SalesInvoices.Notes2 <> DATA.Reference
GO