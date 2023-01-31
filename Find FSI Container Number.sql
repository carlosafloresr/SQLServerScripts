CREATE PROCEDURE USP_FSI_FindContainer (@InvoiceNo	Varchar(20))
AS
SELECT	SUB.RecordCode AS Container
		,SUB.Reference AS ProNumber
FROM	FSI_ReceivedDetails DET
		INNER JOIN FSI_ReceivedSubDetails SUB ON DET.BatchId = SUB.BatchId AND DET.DetailId = SUB.DetailId
WHERE	DET.InvoiceNumber = @InvoiceNo
		AND SUB.RecordType = 'EQP'