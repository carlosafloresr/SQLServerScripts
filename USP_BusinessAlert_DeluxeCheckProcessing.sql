USE [GPCustom]
GO
/****** Object:  StoredProcedure [dbo].[USP_BusinessAlert_DeluxeCheckProcessing]    Script Date: 8/16/2022 10:35:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_BusinessAlert_DeluxeCheckProcessing]
AS
SET NOCOUNT ON

DECLARE	@Company		Varchar(5),
		@CpyAlias		Varchar(5),
		@Database		Varchar(50),
		@Email			Varchar(50),
		@Query			Varchar(Max),
		@Body			Varchar(MAX) = '',
		@EmailCC		Varchar(250) = 'cflores@imcc.com',
		@EmailSubject	Varchar(75) = '',
		@HTMLTable		Varchar(500) = '<table border="1" cellpadding="1" cellspacing="1" style="color:blue;font-family:Arial;font-size:10pt;border-collapse:collapse;">',
		@Counter		Int = 0,
		@BatchId		Varchar(30),
		@PaymentNumber	Varchar(30),
		@VendorId		Varchar(15),
		@CheckNumber	Varchar(30),
		@CheckDate		Date,
		@Amount			Numeric(10,2),
		@TransacStatus	Varchar(30),
		@PaymentType	Varchar(30),
		@SartDate		Date = DATEADD(DD, -30, GETDATE())

DECLARE	@tblRecords		Table (
		BatchId			Varchar(30),
		PaymentNumber	Varchar(30),
		VendorId		Varchar(15),
		CheckNumber		Varchar(30),
		CheckDate		Date,
		Amount			Numeric(10,2),
		TransacStatus	Varchar(30),
		PaymentType		Varchar(30))

DECLARE curCompanies CURSOR LOCAL KEYSET OPTIMISTIC FOR
SELECT	[CompanyId], 
		[parString],
		[Email] = (SELECT PAR2.ParString FROM [GPCustom].[dbo].[Companies_Parameters] PAR2 WHERE PAR2.CompanyId = PAR1.CompanyId AND PAR2.ParameterCode = 'DECLINEDTRANSACTIONS'),
		[Alias] = (SELECT CPY.CompanyAlias FROM View_CompaniesAndAgents CPY WHERE CPY.CompanyId = PAR1.CompanyId)
FROM	[GPCustom].[dbo].[Companies_Parameters] PAR1
WHERE	ParameterCode = 'REGALPAYDB'
		AND Inactive = 0

OPEN curCompanies 
FETCH FROM curCompanies INTO @Company, @Database, @Email, @CpyAlias

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @Counter = 0

	DELETE @tblRecords

	SET @Query = N'SELECT	ERPBatchID,
			PaymentNumber,
			VendorID,
			CheckNumber,
			CheckDate,
			SUM(NetAmount) AS Amount,
			TransactionStatusText,
			PaymentType
	FROM	(
			SELECT	[ERPBatchID]
					,[PaymentNumber]
					,[VendorID]
					,[CheckNumber]
					,CheckDate
					,[InvoiceNumber]
					,InvoiceDate
					,NetAmount
					,[TRXStatus]
					,s.TransactionStatusText
					,[InvoiceDescription]
					,[PaymentType]
					,[VoucherNumber]
			FROM	' + @Database + '.dbo.PaymentTransactions t 
					JOIN ' + @Database + '.dbo.TransactionStatus s ON s.TransactionStatusID = t.TRXStatus
			WHERE	TRXStatus = 1 
					AND PaymentType = ''DXPCHK'' 
					AND checkdate > ''' + CAST(@SartDate AS Varchar) + ''' 
					AND checkdate < DATEADD(day, DATEDIFF(day, IIF(DATEPART(dw, GETDATE()) < 4, 7, 5), GETDATE()), 0)
			) DATA
	GROUP BY ERPBatchID,
			PaymentNumber,
			VendorID,
			CheckNumber,
			CheckDate,
			TransactionStatusText,
			PaymentType
	ORDER BY checkdate, checknumber'

	INSERT INTO @tblRecords
	EXECUTE(@Query)

	IF (SELECT COUNT(*) FROM @tblRecords) > 0
	BEGIN
		SET @Body = ''
		SET @EmailSubject = 'RegalPay batches not yet acknowledged by Deluxe on ' + @CpyAlias

		DECLARE curTransactions CURSOR LOCAL KEYSET OPTIMISTIC FOR
		SELECT	*
		FROM	@tblRecords

		OPEN curTransactions 
		FETCH FROM curTransactions INTO @BatchId, @PaymentNumber, @VendorId, @CheckNumber,
										@CheckDate, @Amount, @TransacStatus, @PaymentType

		WHILE @@FETCH_STATUS = 0 
		BEGIN
			IF @Counter = 0
			BEGIN
				SET @Body = @HTMLTable
				SET @Body = @Body + '<td style="text-align:center;background-color:Yellow">ERP Batch</td>'
				SET @Body = @Body + '<td style="text-align:center;background-color:Yellow">PaymentNumber</td>'
				SET @Body = @Body + '<td style="text-align:center;background-color:Yellow">Vendor Id</td>'
				SET @Body = @Body + '<td style="text-align:center;background-color:Yellow">Check Number</td>'
				SET @Body = @Body + '<td style="text-align:center;background-color:Yellow">Check Date</td>'
				SET @Body = @Body + '<td style="text-align:center;background-color:Yellow">Amount</td>'
				SET @Body = @Body + '<td style="text-align:center;background-color:Yellow">Status</td>'
				SET @Body = @Body + '<td style="text-align:center;background-color:Yellow">PaymentType</td></tr>'
			END
			ELSE
				SET @Body = @Body + '</td></tr>'

			SET @Body = @Body + '<td style="text-align:center;color:blue;vertical-align:top;">' + @BatchId + '</td>'
			SET @Body = @Body + '<td style="text-align:center;color:blue;vertical-align:top;">' + @PaymentNumber + '</td>'
			SET @Body = @Body + '<td style="text-align:center;color:blue;vertical-align:top;">' + @VendorId + '</td>'
			SET @Body = @Body + '<td style="text-align:center;color:blue;vertical-align:top;">' + @CheckNumber + '</td>'
			SET @Body = @Body + '<td style="text-align:center;color:blue;vertical-align:top;">' + FORMAT(@CheckDate,'d', 'en-US') + '</td>'
			SET @Body = @Body + '<td style="text-align:center;color:blue;vertical-align:top;text-align:right;">' + FORMAT(@Amount,'n2') + '</td>'
			SET @Body = @Body + '<td style="text-align:center;color:blue;vertical-align:top;">' + @TransacStatus + '</td>'
			SET @Body = @Body + '<td style="text-align:center;color:blue;vertical-align:top;">' + @PaymentType + '</td>'

			SET @Counter = @Counter + 1

			FETCH FROM curTransactions INTO @BatchId, @PaymentNumber, @VendorId, @CheckNumber,
											@CheckDate, @Amount, @TransacStatus, @PaymentType
		END

		CLOSE curTransactions
		DEALLOCATE curTransactions

		SET @Body = @Body + '</td></tr></table></body></html>'
	END

	IF @@ERROR = 0 AND @Counter > 0
	BEGIN
		EXECUTE msdb.dbo.sp_send_dbmail @profile_name = 'GP_Notifications',  
										@recipients = @Email,
										@copy_recipients = @EmailCC,
										@subject = @EmailSubject,
										@body_format = 'HTML',
										@body = @Body
	END

	FETCH FROM curCompanies INTO @Company, @Database, @Email, @CpyAlias
END

CLOSE curCompanies
DEALLOCATE curCompanies