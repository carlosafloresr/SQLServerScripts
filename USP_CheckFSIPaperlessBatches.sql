/*
EXECUTE USP_CheckFSIPaperlessBatches
*/
ALTER PROCEDURE USP_CheckFSIPaperlessBatches
AS
DECLARE	@BatchId Varchar(25)

DECLARE FSIBatches CURSOR LOCAL KEYSET OPTIMISTIC
FOR
	SELECT	DISTINCT FSI.BatchId
	FROM	View_Integration_FSI FSI
	WHERE	Status = 2

OPEN FSIBatches 
FETCH FROM FSIBatches INTO @BatchId

WHILE @@FETCH_STATUS = 0 
BEGIN
	IF NOT EXISTS(SELECT DISTINCT FSI.BatchId FROM View_Integration_FSI FSI INNER JOIN ILSGP01.GPCustom.dbo.CustomerMaster CUS ON FSI.CustomerNumber = CUS.CustNmbr AND FSI.Company = CUS.CompanyId WHERE FSI.BatchId = @BatchId AND CUS.InvoiceEmailOption > 1)
	BEGIN
		UPDATE FSI_ReceivedHeader SET Status = 4 WHERE BatchId = @BatchId
	END
		
	FETCH FROM FSIBatches INTO @BatchId
END

CLOSE FSIBatches
DEALLOCATE FSIBatches

SELECT	DISTINCT FSI.BatchId
FROM	View_Integration_FSI FSI
		INNER JOIN ILSGP01.GPCustom.dbo.CustomerMaster CUS ON FSI.CustomerNumber = CUS.CustNmbr AND FSI.Company = CUS.CompanyId
WHERE	FSI.Status IN (2,3) 
		AND FSI.RecordStatus = 0
		AND CUS.InvoiceEmailOption > 1