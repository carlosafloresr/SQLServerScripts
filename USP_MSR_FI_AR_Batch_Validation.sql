/*
EXECUTE USP_MSR_FI_AR_Batch_Validation 'AR_FI_140717'
*/
ALTER PROCEDURE USP_MSR_FI_AR_Batch_Validation (@BatchId Varchar(20))
AS
SELECT	*
FROM	(
		SELECT	DISTINCT Customer
				,CASE	WHEN CustNmbr IS Null THEN 'Customer does not exists in GP' 
						WHEN Inactive = 1 THEN 'Customer is inactive in GP' 
						--WHEN Hold = 1 THEN 'Customer is on hold in GP' 
						ELSE ''
				END AS Verification
		FROM	MSR.FI_AR AR1
				LEFT JOIN ILSGP01.FI.dbo.RM00101 GP ON AR1.Customer = GP.CustNmbr
		WHERE	BatchID = @BatchId
				AND Intercompany = 0
		) DATA
WHERE	Verification <> ''