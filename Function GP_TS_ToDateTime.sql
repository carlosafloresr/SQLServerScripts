/*
PRINT dbo.GP_TS_ToDateTime('2022-11-09 15:49:56.707')
*/
CREATE FUNCTION GP_TS_ToDateTime (@parTS Datetime) 
RETURNS Datetime
AS
BEGIN
	DECLARE @ReturnValue Datetime = DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), @parTS)

	RETURN @ReturnValue
END
