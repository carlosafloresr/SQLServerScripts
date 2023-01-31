DECLARE	@EventDT				Datetime,
		@CustomerID				Varchar(20),
		@DocType				Varchar(30),
		@InvoiceNumber			Varchar(25),
		@WFInsertReason			Varchar(25),
		@DivisionID				Varchar(3),
		@OriginalInvoiceAmount	Numeric(10,2),
		@FromQueue				Varchar(50),
		@ToQueue				Varchar(50),
		@Body					Varchar(MAX) = '',
		@EmailSubject			Varchar(75),
		@ERROR_NUMBER			Int = 0,
		@EventID				Int = 3999652

BEGIN TRY
  SELECT	@EventDT				= WIT.EventDT,
			@CustomerID				= PSP.CustomerID,
			@DocType				= dbo.Proper(RTRIM(PSP.DocType)),
			@InvoiceNumber			= RTRIM(PSP.InvoiceNumber),
			@WFInsertReason			= PSP.WFInsertReason,
			@DivisionID				= PSP.DivisionID,
			@OriginalInvoiceAmount	= PSP.OriginalInvoiceAmount,
			@FromQueue				= QUF.Name,
			@ToQueue				= QUT.Name
	FROM	WFWorkItemEvent WIT
			INNER JOIN WFWorkItem WWI ON WIT.WorkItemID = WWI.WorkItemID
			INNER JOIN WFQueue QUF ON WIT.FromQueueID = QUF.QueueID
			INNER JOIN WFQueue QUT ON WIT.ToQueueID = QUT.QueueID
			LEFT JOIN PacketIDX_ShortPay PSP ON WWI.PacketID = PSP.Packetid
	WHERE	WIT.ToQueueID IN (142, 143, 144, 145, 146)
			AND WIT.ToQueueID <> WIT.FromQueueID
			AND WIT.eventdt > '05/01/2017'
			AND WIT.EventID = @EventID
	ORDER BY WIT.EventDT
END TRY
BEGIN CATCH
	SET @ERROR_NUMBER = ERROR_NUMBER()
	PRINT ERROR_MESSAGE()
END CATCH

IF @ERROR_NUMBER = 0
BEGIN
	BEGIN TRY
		SET @EmailSubject = 'EBE – Short Pay Escalation Warning on the ' + @DocType + ' ' + @InvoiceNumber

		SET @Body = '<html><body style="color:blue;font-family:Arial;font-size:10pt;"><p>Please be advised that short paid ' + @DocType + ' ' + @InvoiceNumber + ' has been moved to an escalated queue in EBE due to time restrictions. Once an invoice is in an Escalated queue, the short pay will be credited if resolution has not been reached within a reasonable amount of time. Please work the invoices in your EBE queues ASAP.</p>'
		SET @Body = @Body + '<table border="1" cellpadding="1" cellspacing="1" style="color:blue;font-family:Arial;font-size:10pt;border-collapse:collapse;">'

		SET @Body = @Body + '<tr><td style="text-align:center;background-color:Yellow">Event Date</td>'
		SET @Body = @Body + '<td style="text-align:center;background-color:Yellow">From Queue</td>'
		SET @Body = @Body + '<td style="text-align:center;background-color:Yellow">To Queue</td></tr>'

		SET @Body = @Body + '<tr><td style="color:blue">' + CONVERT(Varchar, GETDATE(), 20) + '</td>'
		SET @Body = @Body + '<td style="color:blue">' + @FromQueue + '</td>'
		SET @Body = @Body + '<td style="color:blue">' + @ToQueue + '</td></tr></table></br>'

		SET @Body = @Body + '<table border="1" cellpadding="1" cellspacing="1" style="color:blue;font-family:Arial;font-size:10pt;border-collapse:collapse;">'
		SET @Body = @Body + '<tr><td style="text-align:right;background-color:Yellow">Document Type</td>'
		SET @Body = @Body + '<td style="color:blue">' + @DocType + '</td></tr>'

		SET @Body = @Body + '<tr><td style="text-align:right;background-color:Yellow">Document Number</td>'
		SET @Body = @Body + '<td style="color:blue">' + @InvoiceNumber + '</td></tr>'

		SET @Body = @Body + '<tr><td style="text-align:right;background-color:Yellow">Customer</td>'
		SET @Body = @Body + '<td style="color:blue">' + @CustomerID + '</td></tr>'

		SET @Body = @Body + '<tr><td style="text-align:right;background-color:Yellow">Original Amount</td>'
		SET @Body = @Body + '<td style="color:blue">' + FORMAT(@OriginalInvoiceAmount, '$###,##0.#0') + '</td></tr>'

		SET @Body = @Body + '<tr><td style="text-align:right;background-color:Yellow">Insert Reason</td>'
		SET @Body = @Body + '<td style="color:blue">' + @WFInsertReason + '</td></tr>'

		SET @Body = @Body + '<tr><td style="text-align:right;background-color:Yellow">Division</td>'
		SET @Body = @Body + '<td style="color:blue">' + RTRIM(@DivisionID) + '</td></tr>'

		SET @Body = @Body + '</table></body></html>'
	END TRY
	BEGIN CATCH
		PRINT ERROR_MESSAGE()
	END CATCH

	EXECUTE msdb.dbo.sp_send_dbmail @profile_name = 'Listener Email Profile',  
									@recipients = 'cflores@iils.com',
									@subject = @EmailSubject,
									@body_format = 'HTML',
									@body = @Body
END
ELSE
	PRINT 'ERROR'