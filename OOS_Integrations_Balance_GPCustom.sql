-- EXECUTE OOS_Integrations_Balance 'AIS','A0196','12/11/2008'
ALTER PROCEDURE OOS_Integrations_Balance
		@Company	Varchar(5),
		@VendorId	Varchar(12),
		@PayDate	Datetime
AS
DECLARE	@Query		Varchar(Max)
SET		@Query		= 'EXECUTE ' + @Company + '.dbo.OOS_Integrations_Balance ''' + @Company + ''',''' + @VendorId + ''',''' +  CONVERT(Char(10), @PayDate, 101) + ''''
EXECUTE(@Query)