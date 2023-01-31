USE [GPCustom]

IF EXISTS (SELECT * FROM Sys.Objects WHERE Object_Id = OBJECT_ID(N'[dbo].[FindFSIApplySummary]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FindFSIApplySummary]
GO

CREATE FUNCTION [dbo].[FindFSIApplySummary] (@BatchId Varchar(25), @ApplyTo Varchar(25), @RecordId Int)
RETURNS Money
BEGIN
	DECLARE	@ReturnValue	Money,
			@DocFound		Varchar(25)
	
	SELECT	@ReturnValue = ISNULL(SUM(InvoiceTotal), 0.0) 
	FROM	GPCustom.dbo.FSI_ReceivedDetails
	WHERE	BatchId = @BatchId 
			AND ApplyTo = @ApplyTo 
			AND FSI_ReceivedDetailId < @RecordId
			
	RETURN @ReturnValue
END
GO