/*
EXECUTE sp_send_cdontsmail 'sqlserver@iils.com', 'cflores@iilogistics.com', 'Test Mail', 'Test'
*/
ALTER PROCEDURE [dbo].[sp_send_cdontsmail] 
		@From		varchar(100),
		@To			varchar(100),
		@Subject	varchar(100),
		@Body		varchar(4000),
		@CC			varchar(100) = null,
		@BCC		varchar(100) = null
AS
Declare @MailID int
Declare @hr int

EXECUTE @hr = sp_OACreate 'CDONTS.NewMail', @MailID OUT
EXECUTE @hr = sp_OASetProperty @MailID, 'From',@From
EXECUTE @hr = sp_OASetProperty @MailID, 'Body', @Body
EXECUTE @hr = sp_OASetProperty @MailID, 'BCC',@BCC
EXECUTE @hr = sp_OASetProperty @MailID, 'CC', @CC
EXECUTE @hr = sp_OASetProperty @MailID, 'Subject', @Subject
EXECUTE @hr = sp_OASetProperty @MailID, 'To', @To
EXECUTE @hr = sp_OAMethod @MailID, 'Send', NULL
EXECUTE @hr = sp_OADestroy @MailID