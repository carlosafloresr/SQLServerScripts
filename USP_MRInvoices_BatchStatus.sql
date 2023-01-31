CREATE PROCEDURE USP_MRInvoices_BatchStatus
AS
DECLARE @Batch			Varchar(20)
DECLARE @tblInvoices	Table (BatchId Varchar(20), Invoice Varchar(15), Approved Bit)

DECLARE curBatches CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	BatchId 
FROM	LENSASQL002.FI.dbo.BatchesReceived 
WHERE	Integration = 0

OPEN curBatches 
FETCH FROM curBatches INTO @Batch

WHILE @@FETCH_STATUS = 0 
BEGIN
	INSERT INTO @tblInvoices (Invoice)
	SELECT	DISTINCT REPLACE(MSR.Inv_no, 'I', '') AS InvoiceNumber
	FROM	LENSASQL002.FI.Staging.MSR_Import MSR
	WHERE	MSR.BatchId = @Batch
			AND MSR.Intercompany = 1
	ORDER BY 1

	UPDATE @tblInvoices SET BatchId = @Batch WHERE BatchId IS Null

	FETCH FROM curBatches INTO @Batch
END

CLOSE curBatches
DEALLOCATE curBatches

UPDATE	LENSASQL002.FI.dbo.BatchesReceived 
SET		Integration = 1
FROM	(
		SELECT	INV.BatchId AS Batch,
				COUNT(*) AS Counter,
				SUM(CAST(MRI.Accepted AS Int)) AS Accepted
		FROM	@tblInvoices INV
				LEFT JOIN MRInvoices_AP MRI ON INV.Invoice = MRI.InvoiceNumber
		GROUP BY INV.BatchId
		) DATA
WHERE	BatchId = Batch
		AND Counter = Accepted