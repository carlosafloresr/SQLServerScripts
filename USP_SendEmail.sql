/*
EXECUTE USP_SendEmail 'cflores@iils.com', Null, 'Test', 'Test'
*/
ALTER PROCEDURE [dbo].[USP_SendEmail]
		@To				Varchar(250),
		@ToCC			Varchar(250) = Null,
		@EmailSubject	Varchar(150),
		@EmailBody		Varchar(MAX),
		@IsHTML			Bit = 0
AS
DECLARE	@MailFormat		Varchar(10) = CASE WHEN @IsHTML = 1 THEN 'HTML' ELSE 'TEXT' END

EXECUTE msdb.dbo.sp_send_dbmail @profile_name = 'Listener',  
								@recipients = @To,
								@copy_recipients = @ToCC,
								@subject = @EmailSubject,
								@body_format = @MailFormat,
								@body = @EmailBody
GO