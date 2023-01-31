/*
EXECUTE USP_KarmaBatchRecords 'SLSWE121810'
*/
ALTER PROCEDURE USP_KarmaBatchRecords (@BatchId Varchar(25))
AS
DECLARE	@MinInvoice	Int,
		@MaxInvoice	Int
		
SELECT	@MinInvoice	= MIN(InvoiceNumber),
		@MaxInvoice	= MAX(InvoiceNumber)
FROM	KarmakIntegration
WHERE	BatchId = @BatchId

SELECT	* 
FROM	[RCCLSRV01\SQLEXPRESS].ILS_Data.dbo.View_SalesOrders 
WHERE	InvoiceNumber BETWEEN @MinInvoice AND @MaxInvoice 
ORDER BY InvoiceNumber

/*
--SELECT SAL.* FROM [RCCLSRV01\SQLEXPRESS].ILS_Data.dbo.View_SalesOrders SAL INNER JOIN KarmakIntegration KAR ON SAL.InvoiceNumber = KAR.InvoiceNumber AND KAR.BatchId = 'SLSWE121810'--  WHERE SAL.InvoiceNumber --IN (SELECT InvoiceNumber FROM KarmakIntegration WHERE BatchId = 'SLSWE121810')

SELECT SAL.* FROM KarmakIntegration KAR, [RCCLSRV01\SQLEXPRESS].ILS_Data.dbo.View_SalesOrders SAL WHERE KAR.BatchId = 'SLSWE121810' AND KAR.InvoiceNumber = SAL.InvoiceNumber

SELECT * FROM KarmakIntegration KAR WHERE KAR.BatchId = 'SLSWE121810' ORDER BY InvoiceNumber

SELECT * FROM [RCCLSRV01\SQLEXPRESS].ILS_Data.dbo.View_SalesOrders WHERE InvoiceNumber BETWEEN (SELECT MIN(InvoiceNumber) FROM KarmakIntegration WHERE BatchId = 'SLSWE121810') AND 3578
*/