/*
PRINT dbo.FindRecordTypes(4679) + '1'
*/
ALTER FUNCTION [dbo].[FindRecordTypes] (@OrderId Int)
RETURNS Varchar(4)
AS
BEGIN
	DECLARE	@ReturnValue Varchar(4)
	SET @ReturnValue = ''
	
	IF EXISTS(SELECT RepairCode
				FROM	DirectorSeries.dbo.RepairInvoiceOperationHistory ROO
				WHERE	RepairInvoiceHistoryId = @OrderId
						AND RepairCode IN ('CLAIM'))
	BEGIN
		SET @ReturnValue = @ReturnValue + 'S'
	END
	
	IF EXISTS(SELECT RepairCode
				FROM	DirectorSeries.dbo.RepairInvoiceOperationHistory ROO
				WHERE	RepairInvoiceHistoryId = @OrderId
						AND RepairCode NOT IN ('INSTALL','PEOPLNET','REMOVAL','TIRES','TIRE R AND R','CLAIM'))
	BEGIN
		SET @ReturnValue = @ReturnValue + 'M'
	END
	
	IF EXISTS(SELECT RepairCode
				FROM	DirectorSeries.dbo.RepairInvoiceOperationHistory ROO
				WHERE	RepairInvoiceHistoryId = @OrderId
						AND RepairCode IN ('TIRES','TIRE R AND R'))
	BEGIN
		SET @ReturnValue = @ReturnValue + 'T'
	END
	
	IF EXISTS(SELECT RepairCode
				FROM	DirectorSeries.dbo.RepairInvoiceOperationHistory ROO
				WHERE	RepairInvoiceHistoryId = @OrderId
						AND RepairCode IN ('INSTALL','PEOPLNET','REMOVAL'))
	BEGIN
		SET @ReturnValue = @ReturnValue + 'P'
	END
	
	RETURN dbo.PADR(@ReturnValue, 4, ' ')
END