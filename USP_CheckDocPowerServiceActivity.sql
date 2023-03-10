/*
EXECUTE USP_CheckDocPowerServiceActivity
*/
ALTER PROCEDURE USP_CheckDocPowerServiceActivity
AS
DECLARE	@LastActivity	Datetime,
		@EmailTo		Varchar(200) = 'cflores@imcc.com',
		@EmailSubject	Varchar(100) = 'The DocPower Documents by Email Service Has Stopped',
		@body			Varchar(MAX) = 'Test'

SELECT	@LastActivity = LastActivity
FROM	DocPowerImagingService

IF DATEDIFF(mi, @LastActivity, GETDATE()) > 9
BEGIN
	EXECUTE msdb.dbo.sp_send_dbmail @profile_name = 'Listener',  
									@recipients = @EmailTo,
									@subject = @EmailSubject,
									@body_format = 'HTML',
									@body = @Body,
									@from_address = 'services@imccompanies.com'
END
GO