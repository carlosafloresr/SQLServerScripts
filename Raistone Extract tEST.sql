DECLARE @Query			nvarchar(MAX) = '',
		@Company		nvarchar(5)	= '',
		@Delim			nvarchar(1) = '*',
		@DOSCommand		nvarchar(4000),
		@DatePortion	char(10) = GPCustom.dbo.PADL(YEAR(GETDATE()), 4, '0') + '_' + GPCustom.dbo.PADL(MONTH(GETDATE()), 2, '0') + '_' + GPCustom.dbo.PADL(DAY(GETDATE()), 2, '0'),
		@Counter		Int = 0,
		@Amount			Numeric(12,2),
		@Body			Varchar(MAX) = '',
		@HTMLTable		Varchar(500) = '<table border="1" cellpadding="1" cellspacing="1" style="color:blue;font-family:Arial;font-size:10pt;border-collapse:collapse;">',
		@EmailSubject	Varchar(100) = 'Raistone - IMC Control Totals ' + FORMAT(GETDATE(),'d', 'en-US'),
		@Email			Varchar(200) = 'carlosafloresr@hotmail.com',
		@EmailCC		Varchar(200) = 'cflores@imcc.com',
		@DaySeconds		Varchar(10) = CAST(DATEDIFF(SS, CAST(GETDATE() AS Date), GETDATE()) AS Varchar),
		@FileName		Varchar(150)

SET @FileName = '*** No file exported ***'
	SET @Amount = 0
	SET @Counter = 0

	SET @Body = @HTMLTable
SET @Body = @Body + '<tr><td style="text-align:center;background-color:Yellow;width:100px;">Export Date</td>'
SET @Body = @Body + '<td style="text-align:center;background-color:Yellow;width:100px;">Invoices Count</td>'
SET @Body = @Body + '<td style="text-align:center;background-color:Yellow;width:100px;">Invoices Amount</td>'
SET @Body = @Body + '<td style="text-align:center;background-color:Yellow;width:250px;">File Name</td></tr>'

SET @Body = @Body + '<tr><td style="text-align:center;color:blue;vertical-align:top;">' + FORMAT(GETDATE(),'d', 'en-US') + '</td>'
SET @Body = @Body + '<td style="text-align:center;color:blue;vertical-align:top;">' + CAST(@Counter AS Varchar) + '</td>'
SET @Body = @Body + '<td style="text-align:center;color:blue;vertical-align:top;">$ ' + FORMAT(@Amount,'n2') + '</td>'
SET @Body = @Body + '<td style="text-align:center;color:blue;vertical-align:top;">' + REPLACE(@FileName, '\\PRIAPINT01P\Shared\Raistone\', '') + '</td></tr>'

SET @Body = @Body + '</table></body></html>'

EXECUTE msdb.dbo.sp_send_dbmail @profile_name = 'GP_Notifications',  
									@recipients = @Email,
									@copy_recipients = @EmailCC,
									@subject = @EmailSubject,
									@body_format = 'HTML',
									@body = @Body