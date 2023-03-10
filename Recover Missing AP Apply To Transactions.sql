DECLARE	@VendorId		Varchar(20) = 'IGS-CHB',
		@ApplyFrom		Varchar(30) = 'TIP0918181434C',
		@ApplyTo		Varchar(30) = '95-126146',
		@Amount			Numeric(10,2) = 392.25,
		@PostingDate	Date = '09/18/2018',
		@DocDate		Date = GETDATE()

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
	FROM	PM30200 PMTO
			LEFT JOIN PM20000 PMFROM ON PMTO.VENDORID = PMFROM.VENDORID AND PMFROM.DOCNUMBR = @ApplyFrom
	WHERE	PMTO.VENDORID = @VendorId
			AND PMTO.DOCNUMBR = @ApplyTo