/*
EXECUTE USP_UpdateFSIPaperlessBatchStatus '7FSI111014_1623'
*/
ALTER PROCEDURE USP_UpdateFSIPaperlessBatchStatus (@BatchId Varchar(25))
AS
DECLARE	@TotalRecords	Smallint,
		@PendingRecords	Smallint
		
SELECT	@TotalRecords = COUNT(FSI.BatchId)
FROM	View_Integration_FSI FSI 
		INNER JOIN ILSGP01.GPCustom.dbo.CustomerMaster CUS ON FSI.CustomerNumber = CUS.CustNmbr AND FSI.Company = CUS.CompanyId 
WHERE	FSI.BatchId = @BatchId 
		AND CUS.InvoiceEmailOption > 1 
		
SELECT	@PendingRecords = COUNT(FSI.BatchId)
FROM	View_Integration_FSI FSI 
		INNER JOIN ILSGP01.GPCustom.dbo.CustomerMaster CUS ON FSI.CustomerNumber = CUS.CustNmbr AND FSI.Company = CUS.CompanyId 
WHERE	FSI.BatchId = @BatchId 
		AND CUS.InvoiceEmailOption > 1 
		AND FSI.RecordStatus = 0
		
IF @TotalRecords = @PendingRecords
BEGIN
	UPDATE	FSI_ReceivedHeader
	SET		Status = 2 
	WHERE	BatchId = @BatchId
END
ELSE
BEGIN
	IF @TotalRecords > @PendingRecords AND @PendingRecords > 0
	BEGIN
		UPDATE	FSI_ReceivedHeader
		SET		Status = 3
		WHERE	BatchId = @BatchId
	END
	ELSE
	BEGIN
		IF @TotalRecords > 0 AND @PendingRecords = 0
		BEGIN
			UPDATE	FSI_ReceivedHeader
			SET		Status = 4
			WHERE	BatchId = @BatchId
		END
	END
END