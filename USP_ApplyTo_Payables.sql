/*
EXECUTE USP_ApplyTo_Payables 'IGS-CHB','TIP0919181109C','97-105091',520.00, '09/19/2018'
EXECUTE USP_AP_MoveOpenToHistory 'TIP0919181052D', '1'
*/
ALTER PROCEDURE USP_ApplyTo_Payables
		@VendorId		Varchar(20),
		@ApplyFrom		Varchar(30),
		@ApplyTo		Varchar(30),
		@Amount			Numeric(10,2),
		@PostingDate	Date
AS
DECLARE @DocDate		Date = GETDATE(),
		@Balance		Numeric(10,2) = 0,
		@Body			Varchar(MAX) = '',
		@EmailTo		Varchar(250) = 'kreed@imcc.com',
		@EmailCC		Varchar(250) = 'cflores@imcc.com',
		@EmailSubject	Varchar(100) = DB_NAME() + ' - TIP AP: Apply from document ' + RTRIM(@ApplyFrom) + ' to the document ' + RTRIM(@ApplyTo) + ' found with a different balance'

SELECT	@Balance = CAST(CURTRXAM AS Numeric(10,2))
FROM	PM20000
WHERE	VENDORID = @VendorId
		AND DOCNUMBR = @ApplyTo

PRINT 'Balance: ' + CAST(@Balance AS Varchar)
PRINT 'Apply To: ' + CAST(@Amount AS Varchar)

IF @Balance >= @Amount
BEGIN
	BEGIN TRANSACTION

	INSERT INTO PM10200
			(VENDORID,
			DOCDATE,
			GLPOSTDT,
			APTVCHNM,
			APTODCTY,
			APTODCNM,
			APTODCDT,
			ApplyFromGLPostDate,
			CURNCYID,
			APPLDAMT,
			ORAPPAMT,
			VCHRNMBR,
			DOCTYPE,
			APFRDCNM,
			ApplyToGLPostDate,
			APFRMWROFAMT,
			ActualApplyToAmount,
			FROMCURR,
			TEN99AMNT)
	SELECT	PMTO.VENDORID,
			@DocDate AS DOCDATE,
			@PostingDate AS GLPOSTDT,
			PMTO.VCHRNMBR AS APTVCHNM,
			PMTO.DOCTYPE AS APTODCTY,
			PMTO.DOCNUMBR AS APTODCNM,
			PMTO.DOCDATE AS APTODCDT,
			PMTO.PSTGDATE AS ApplyFromGLPostDate,
			PMTO.CURNCYID,
			PMTO.DOCAMNT AS APPLDAMT,
			PMTO.DOCAMNT AS ORAPPAMT,
			PMFROM.VCHRNMBR,
			PMFROM.DOCTYPE,
			PMFROM.DOCNUMBR AS APFRDCNM,
			PMFROM.PSTGDATE AS ApplyFromGLPostDate,
			PMFROM.DOCAMNT AS APFRMAPLYAMT,
			CASE WHEN PMFROM.DOCAMNT > PMTO.DOCAMNT THEN PMTO.DOCAMNT ELSE PMFROM.DOCAMNT END  AS ActualApplyToAmount,
			PMFROM.CURNCYID,
			PMFROM.TEN99AMNT
	FROM	PM20000 PMTO
			LEFT JOIN PM20000 PMFROM ON PMTO.VENDORID = PMFROM.VENDORID AND PMFROM.DOCNUMBR = @ApplyFrom
	WHERE	PMTO.VENDORID = @VendorId
			AND PMTO.DOCNUMBR = @ApplyTo

	IF @@ERROR = 0
	BEGIN
		UPDATE	PM20000
		SET		CURTRXAM = CURTRXAM - @Amount
		WHERE	VENDORID = @VendorId
				AND DOCNUMBR = @ApplyFrom

		UPDATE	PM20000
		SET		CURTRXAM = CURTRXAM - @Amount
		WHERE	VENDORID = @VendorId
				AND DOCNUMBR = @ApplyTo

		IF @@ERROR = 0
			COMMIT TRANSACTION
		ELSE
			ROLLBACK TRANSACTION
	END
	ELSE
		ROLLBACK TRANSACTION
END
ELSE
BEGIN
	SET @Body = 'The AP document ' + RTRIM(@ApplyTo) + ' has a balance of ' + FORMAT(@Balance, 'C', 'en-us') + '. This is less than the expected Apply To amount of ' + FORMAT(@Amount, 'C', 'en-us') + '.'

	--EXECUTE msdb.dbo.sp_send_dbmail @profile_name = 'Great Plains Notifications',  
	--								@recipients = @EmailTo,
	--								@copy_recipients = @EmailCC,
	--								@subject = @EmailSubject,
	--								@body = @Body
END
GO