CREATE FUNCTION [dbo].[DriverPayrollConceptBalance](@Company Varchar(5), @VendorId Varchar(12), @Concept Varchar(30), @Days Int)
RETURNS Numeric(12,2)
AS
BEGIN
	-- Returns the Requested History Records Average
	DECLARE	@Balance	Numeric(12,2),
			@Amount		Numeric(12,2),
			@Records	Int
	
	SELECT	@Records = COUNT(Balance),
			@Amount = SUM(Balance)
	FROM	(
	SELECT	Balance
			,ROW_NUMBER() OVER (PARTITION BY VendorId ORDER BY PayDate DESC) AS 'RowNumber'
	FROM	ILS_Datawarehouse.dbo.MyTruck
	WHERE	VendorId = @VendorId
			AND CompanyId = @Company
			AND Description = @Concept) RECS
	WHERE	RowNumber <= @Days
	
	IF @Records > 0
		SET @Balance = ROUND(@Amount / @Records, 2)
	
	RETURN @Balance
END
