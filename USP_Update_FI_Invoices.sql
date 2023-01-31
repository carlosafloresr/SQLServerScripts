/*
EXECUTE USP_Update_FI_Invoices 'AR_FI_111111'
*/
ALTER PROCEDURE USP_Update_FI_Invoices (@BatchId Varchar(20))
AS
UPDATE	FI_Data.dbo.Invoices
SET		BatchId = @BatchId
WHERE	Inv_No IN (
					SELECT	DISTINCT CAST(REPLACE(DocNumber, 'I', '') AS Int) AS DocNumber
					FROM	View_MSR_ReceivedTransactions
					WHERE	Company = 'FI'
							AND BatchId = @BatchId
							AND LEFT(DocNumber, 1) = 'I'
				)

UPDATE	FI_Data.dbo.Invoices
SET		BatchId = @BatchId
WHERE	Inv_Batch IN (
					SELECT	DISTINCT CAST(REPLACE(DocNumber, 'B', '') AS Int) AS DocNumber
					FROM	View_MSR_ReceivedTransactions
					WHERE	Company = 'FI'
							AND BatchId = @BatchId
							AND LEFT(DocNumber, 1) = 'B'
							AND DocNumber <> 'B0'
				)
				
/*
SELECT	DISTINCT REPLACE(DocNumber, 'B', '') AS DocNumber
FROM	View_MSR_ReceivedTransactions
WHERE	Company = 'FI'
		AND BatchId = 'AR_FI_111111'
		AND LEFT(DocNumber, 1) = 'B'
		AND DocNumber <> 'B0'
		

SELECT	* 
FROM	FI_Data.dbo.Invoices 
WHERE	Inv_Batch = '72749'

SELECT	*
FROM	View_MSR_ReceivedTransactions
WHERE	Company = 'FI'
		AND BatchId = 'AR_FI_111111'
		AND Description = 'B72749'
*/