CREATE PROCEDURE USP_ApplyTo_Payables
		@VendorId		Varchar(20),
		@ApplyFrom		Varchar(30),
		@ApplyTo		Varchar(30),
		@Amount			Numeric(10,2),
		@PostingDate	Date
AS
DECLARE @DocDate		Date = GETDATE()

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
GO