CREATE PROCEDURE USP_DocPowerImages_LastMessage
AS
DECLARE	@Body					Varchar(MAX) = '',
		@EmailTo				Varchar(250) = 'cflores@imcc.com',
		@EmailCC				Varchar(250) = 'cflores@imcc.com',
		@EmailSubject			Varchar(75) = '',
		@HTMLTable				Varchar(500) = '<table border="1" cellpadding="1" cellspacing="1" style="color:blue;font-family:Arial;font-size:10pt;border-collapse:collapse;">',
		@Company				Varchar(5),
		@FromUser				Varchar(100),
		@Subject				Varchar(250),
		@ProcessedOn			Varchar(50)

DECLARE curDocPower CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	Company, FromUser, EmailSubject, CONVERT(Varchar, ProcessedOn, 22)
FROM	DocPowerImages 
WHERE	DocPowerImagesId = (SELECT MAX(DocPowerImagesId) FROM DocPowerImages)

OPEN curDocPower 
FETCH FROM curDocPower INTO @Company, @FromUser, @Subject, @ProcessedOn

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Body = @HTMLTable
	SET @Body = @Body + '<tr><td style="text-align:right;background-color:Yellow">Company:</td><td>' + @Company + '</tr>'
	SET @Body = @Body + '<tr><td style="text-align:right;background-color:Yellow">From:</td><td>' + @FromUser + '</tr>'
	SET @Body = @Body + '<tr><td style="text-align:right;background-color:Yellow">Subject:</td><td>' + @Subject + '</tr>'
	SET @Body = @Body + '<tr><td style="text-align:right;background-color:Yellow">Processed On:</td><td>' + @ProcessedOn + '</tr>'

	FETCH FROM curDocPower INTO @Company, @FromUser, @Subject, @ProcessedOn
END

SET @Body = 'LAST PROCESSED MESSAGE:<br/>' + @Body + '</table></body></html>'

CLOSE curDocPower
DEALLOCATE curDocPower

--EXECUTE msdb.dbo.sp_send_dbmail @profile_name = 'GP_Notifications',  
--								@recipients = @EmailTo,
--								@subject = @EmailSubject,
--								@body_format = 'HTML',
--								@body = @Body

SELECT @Body AS LastMessage