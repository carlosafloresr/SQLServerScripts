USE [FI]
GO
/****** Object:  StoredProcedure [dbo].[USP_IntercompanyInvoices]    Script Date: 1/18/2018 11:41:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_IntercompanyInvoices 'REPAR_011718'
*/
ALTER PROCEDURE [dbo].[USP_IntercompanyInvoices]
		@BatchId	Varchar(15)
AS
DECLARE	@tblInvoices TABLE (InvoiceNumber Varchar(12), FIInvoice Varchar(15) Null)

INSERT INTO @tblInvoices
SELECT	DISTINCT REPLACE(MSR.Inv_no, 'I', '') AS InvoiceNumber,
		INV.inv_no
FROM	Staging.MSR_Import MSR
		LEFT JOIN ILSINT02.FI_Data.dbo.Invoices INV ON REPLACE(MSR.inv_no, 'I', '') = INV.inv_no
WHERE	MSR.BatchId = @BatchId
		AND MSR.Intercompany = 1
ORDER BY 1

DECLARE @InvoiceNumber	Int,
		@FIInvoice		Varchar(15)

DECLARE ImportInvoices CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	InvoiceNumber,
		FIInvoice
FROM	@tblInvoices

OPEN ImportInvoices
FETCH FROM ImportInvoices INTO @InvoiceNumber, @FIInvoice

WHILE @@FETCH_STATUS = 0 
BEGIN
	IF @FIInvoice IS Null
		EXECUTE ILSINT02.FI_Data.dbo.USP_Import_FIDepot_Estimate @InvoiceNumber

	FETCH FROM ImportInvoices INTO @InvoiceNumber, @FIInvoice
END

CLOSE ImportInvoices
DEALLOCATE ImportInvoices

SELECT	InvoiceNumber
FROM	@tblInvoices
ORDER BY InvoiceNumber