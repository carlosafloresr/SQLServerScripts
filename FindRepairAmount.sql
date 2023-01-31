/*
PRINT dbo.FindRepairAmount(6442, 'P')
*/
ALTER FUNCTION FindRepairAmount (@OrderId Int, @Type Char(1))
RETURNS	Money
AS
BEGIN
	DECLARE	@ReturnValue Money
	SET @ReturnValue = 0
	
	IF @Type = 'M'
	BEGIN
		SELECT	@ReturnValue = SUM(Amount)
		FROM	(
				SELECT	ExtendedPrice AS Amount 
				FROM	DirectorSeries.dbo.RepairInvoiceLaborDetailHistory
				WHERE	RepairInvoiceOperationHistoryId IN (SELECT	RepairInvoiceOperationHistoryId
															FROM	DirectorSeries.dbo.RepairInvoiceOperationHistory
															WHERE	RepairInvoiceHistoryId = @OrderId
																	AND RepairCode NOT IN ('INSTALL','PEOPLNET','REMOVAL','TIRES','CLAIM'))
				UNION
				SELECT	ExtendedPrice AS Amount 
				FROM	DirectorSeries.dbo.RepairInvoiceDetailHistory
				WHERE	RepairInvoiceOperationHistoryId IN (SELECT	RepairInvoiceOperationHistoryId
															FROM	DirectorSeries.dbo.RepairInvoiceOperationHistory
															WHERE	RepairInvoiceHistoryId = @OrderId
																	AND RepairCode NOT IN ('INSTALL','PEOPLNET','REMOVAL','TIRES','CLAIM'))) RECS
	END
	
	IF @Type = 'P'
	BEGIN
		SELECT	@ReturnValue = SUM(Amount)
		FROM	(
				SELECT	ExtendedPrice AS Amount 
				FROM	DirectorSeries.dbo.RepairInvoiceLaborDetailHistory
				WHERE	RepairInvoiceOperationHistoryId IN (SELECT	RepairInvoiceOperationHistoryId
															FROM	DirectorSeries.dbo.RepairInvoiceOperationHistory
															WHERE	RepairInvoiceHistoryId = @OrderId
																	AND RepairCode IN ('INSTALL','PEOPLNET','REMOVAL'))
				UNION
				SELECT	ExtendedPrice AS Amount 
				FROM	DirectorSeries.dbo.RepairInvoiceDetailHistory
				WHERE	RepairInvoiceOperationHistoryId IN (SELECT	RepairInvoiceOperationHistoryId
															FROM	DirectorSeries.dbo.RepairInvoiceOperationHistory
															WHERE	RepairInvoiceHistoryId = @OrderId
																	AND RepairCode IN ('INSTALL','PEOPLNET','REMOVAL'))) RECS
	END
	
	IF @Type = 'T'
	BEGIN
		SELECT	@ReturnValue = SUM(Amount)
		FROM	(
				SELECT	ExtendedPrice AS Amount 
				FROM	DirectorSeries.dbo.RepairInvoiceLaborDetailHistory
				WHERE	RepairInvoiceOperationHistoryId IN (SELECT	RepairInvoiceOperationHistoryId
															FROM	DirectorSeries.dbo.RepairInvoiceOperationHistory
															WHERE	RepairInvoiceHistoryId = @OrderId
																	AND RepairCode = 'TIRES')
				UNION
				SELECT	ExtendedPrice AS Amount 
				FROM	DirectorSeries.dbo.RepairInvoiceDetailHistory
				WHERE	RepairInvoiceOperationHistoryId IN (SELECT	RepairInvoiceOperationHistoryId
															FROM	DirectorSeries.dbo.RepairInvoiceOperationHistory
															WHERE	RepairInvoiceHistoryId = @OrderId
																	AND RepairCode = 'TIRES')) RECS
	END
	
	RETURN @ReturnValue
END