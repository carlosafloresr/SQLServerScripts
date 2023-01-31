SET NOCOUNT ON

DECLARE	@Company		Varchar(5),
		@Email			Varchar(50),
		@Query			Varchar(Max),
		@Body			Varchar(MAX) = '',
		@EmailTo		Varchar(250) = 'cflores@imcc.com',
		@EmailCC		Varchar(250) = 'cflores@imcc.com',
		@EmailSubject	Varchar(75) = '',
		@HTMLTable		Varchar(500) = '<table border="1" cellpadding="1" cellspacing="1" style="color:blue;font-family:Arial;font-size:10pt;border-collapse:collapse;">',
		@Counter		Int = 0,
		@PaymentNumber	Varchar(30),
		@Review_Date	Date,
		@DeclinedBy		Varchar(25),
		@Regal_Status	Varchar(20),
		@Comment		Varchar(200),
		@Voided			Varchar(100),
		@VoidDate		Date,
		@VendorId		Varchar(15),
		@VendorName		Varchar(100),
		@VendorCheckN	Varchar(100),
		@CheckNumber	Varchar(30),
		@DocumentAmount	Numeric(10,2)

DECLARE	@tblParameters	Table (Company Varchar(5), Email Varchar(50))

DECLARE @tblDeclined	Table (
		PaymentNumber	Varchar(30),
		Review_Date		Date,
		DeclinedBy		Varchar(25),
		Regal_Status	Varchar(20),
		Comment			Varchar(200) Null,
		Voided			Varchar(100),
		VoidDate		Date,
		VendorId		Varchar(15),
		VendorName		Varchar(100),
		VendorCheckName	Varchar(100),
		CheckNumber		Varchar(30),
		DocumentAmount	Numeric(10,2))

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	[CompanyId], [parString]
FROM	[GPCustom].[dbo].[Companies_Parameters]
WHERE	ParameterCode = 'DECLINEDTRANSACTIONS'
		AND Inactive = 0

OPEN curCompanies 
FETCH FROM curCompanies INTO @Company, @Email

WHILE @@FETCH_STATUS = 0 
BEGIN
	DELETE @tblDeclined

	SET @Counter = 0

	SET @Query = N'SELECT R.PaymentNumber,
			FORMAT(R.ReviewDateTime,''d'', ''en-US'') as ''Review Date'',
			U.UserName as ''Declined By'',
			case R.Status
					  when 0 then ''Declined''
					  when 1 then ''Live''
					  end ''Regal Status'',
			   R.Comment,
			case D.VOIDED
					  when 0 then ''Not Voided Yet''
					  when 1 then ''Voided''
					  end Voided,
			   format(D.VOIDPDATE,''d'', ''en-US'') as "Void Date",
			   D.VENDORID,
			   V.VENDNAME as "Vendor Name",
			   D.VNDCHKNM as "Vendor Check Name",
			   D.DOCNUMBR as "Check Number",
			   D.DOCAMNT
		FROM	[RegalPay].[dbo].[PaymentApprovals] R
				JOIN ' + @Company + '.dbo.PM30200 D ON D.VCHRNMBR = R.PaymentNumber
				JOIN ' + @Company + '.dbo.PM00200 V ON V.VENDORID = D.VENDORID
				JOIN [RegalPay].[dbo].[Users] U ON U.UserID = R.UserId
		WHERE	r.Status = 0 
				AND D.DOCTYPE = 6 
				AND D.VOIDED = ''0'''

	INSERT INTO @tblDeclined
	EXECUTE(@Query)

	IF (SELECT COUNT(*) FROM @tblDeclined) > 0
	BEGIN
		SET @Body = ''
		SET @EmailSubject = 'Declined Transactions to be Voided in GP ' + @Company

		DECLARE curTransactions CURSOR LOCAL KEYSET OPTIMISTIC FOR
		SELECT	*
		FROM	@tblDeclined

		OPEN curTransactions 
		FETCH FROM curTransactions INTO @PaymentNumber, @Review_Date, @DeclinedBy, @Regal_Status,
										@Comment, @Voided, @VoidDate, @VendorId, @VendorName, @VendorCheckN,
										@CheckNumber, @DocumentAmount

		WHILE @@FETCH_STATUS = 0 
		BEGIN
			IF @Counter = 0
			BEGIN
				SET @Body = @HTMLTable
				SET @Body = @Body + '<td style="text-align:center;background-color:Yellow">Payment</td>'
				SET @Body = @Body + '<td style="text-align:center;background-color:Yellow">Review Date</td>'
				SET @Body = @Body + '<td style="text-align:center;background-color:Yellow">Declined By</td>'
				SET @Body = @Body + '<td style="text-align:center;background-color:Yellow">Comments</td>'
				SET @Body = @Body + '<td style="text-align:center;background-color:Yellow">Regal Status</td>'
				SET @Body = @Body + '<td style="text-align:center;background-color:Yellow">Voided</td>'
				SET @Body = @Body + '<td style="text-align:center;background-color:Yellow">Vendor Id</td>'
				SET @Body = @Body + '<td style="text-align:center;background-color:Yellow">Vendor Name</td>'
				SET @Body = @Body + '<td style="text-align:center;background-color:Yellow">Vendor Chk Name</td>'
				SET @Body = @Body + '<td style="text-align:center;background-color:Yellow">Check Number</td>'
				SET @Body = @Body + '<td style="text-align:center;background-color:Yellow">Amount</td></tr>'
			END
			ELSE
				SET @Body = @Body + '</td></tr>'

			SET @Body = @Body + '<td style="text-align:center;color:blue;vertical-align:top;">' + @PaymentNumber + '</td>'
			SET @Body = @Body + '<td style="text-align:center;color:blue;vertical-align:top;">' + FORMAT(@Review_Date,'d', 'en-US') + '</td>'
			SET @Body = @Body + '<td style="text-align:center;color:blue;vertical-align:top;">' + @DeclinedBy + '</td>'
			SET @Body = @Body + '<td style="text-align:center;color:blue;vertical-align:top;">' + ISNULL(@Comment, '') + '</td>'
			SET @Body = @Body + '<td style="text-align:center;color:blue;vertical-align:top;">' + @Regal_Status + '</td>'
			SET @Body = @Body + '<td style="text-align:center;color:blue;vertical-align:top;">' + @Voided + '</td>'
			SET @Body = @Body + '<td style="text-align:center;color:blue;vertical-align:top;">' + @VendorId + '</td>'
			SET @Body = @Body + '<td style="text-align:center;color:blue;vertical-align:top;">' + @VendorName + '</td>'
			SET @Body = @Body + '<td style="text-align:center;color:blue;vertical-align:top;">' + @VendorCheckN + '</td>'
			SET @Body = @Body + '<td style="text-align:center;color:blue;vertical-align:top;">' + @CheckNumber + '</td>'
			SET @Body = @Body + '<td style="text-align:center;color:blue;vertical-align:top;text-align:right;">' + FORMAT(@DocumentAmount,'n2') + '</td>'

			SET @Counter = @Counter + 1

			FETCH FROM curTransactions INTO @PaymentNumber, @Review_Date, @DeclinedBy, @Regal_Status,
											@Comment, @Voided, @VoidDate, @VendorId, @VendorName, @VendorCheckN,
											@CheckNumber, @DocumentAmount
		END

		CLOSE curTransactions
		DEALLOCATE curTransactions

		SET @Body = @Body + '</td></tr></table></body></html>'
	END

	IF @@ERROR = 0 AND @Counter > 0
	BEGIN
		EXECUTE msdb.dbo.sp_send_dbmail @profile_name = 'GP_Notifications',  
										@recipients = @EmailTo,
										@copy_recipients = @EmailCC,
										@subject = @EmailSubject,
										@body_format = 'HTML',
										@body = @Body
	END

	FETCH FROM curCompanies INTO @Company, @Email
END

CLOSE curCompanies
DEALLOCATE curCompanies
