DECLARE	@VendorId		Varchar(20) = 'A1483',
		@ApplyFrom		Varchar(30) = 'PEOPLENET UNIT2',
		@ApplyTo		Varchar(30) = 'DPYA1483_00221692',
		@Amount			Numeric(10,2) = 83.94,
		@PostingDate	Date = '03/30/2018',
		@DocDate		Date = GETDATE()

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
		ApplyFromGLPostDate,
		APFRMWROFAMT,
		ActualApplyToAmount,
		FROMCURR,
		TEN99AMNT)
SELECT	PMTO.VENDORID,
		
		@PostingDate AS DOCDATE,
		PMTO.VCHRNMBR AS APTVCHNM,
		PMTO.DOCTYPE AS APTODCTY,
		PMTO.DOCNUMBR AS APTODCNM,
		pmto.PSTGDATE,
		PMTO.DOCDATE AS APTODCDT,
		PMTO.DOCAMNT AS APPLDAMT,
		PMTO.DOCAMNT AS ORAPPAMT,
		CASE WHEN PMFROM.DOCAMNT > PMTO.DOCAMNT THEN PMTO.DOCAMNT ELSE PMFROM.DOCAMNT END AS Apply_To_Document_Amount,
		PMFROM.DUEDATE AS Apply_To_Due_Date,
		PMFROM.TRXDSCRN AS Apply_To_Description,
		PMFROM.PSTGDATE AS ApplyToGLPostDate,
		PMFROM.VCHRNMBR,
		PMFROM.DOCTYPE,
		PMFROM.DOCNUMBR,
		'USD2' AS FROMCURR,
		PMFROM.DOCAMNT AS Apply_From_Document_Amou,
		PMFROM.DOCAMNT AS APFRMAPLYAMT,
		CASE WHEN PMFROM.DOCAMNT > PMTO.DOCAMNT THEN PMTO.DOCAMNT ELSE PMFROM.DOCAMNT END  AS ActualApplyToAmount,
		CASE WHEN PMFROM.DOCAMNT > PMTO.DOCAMNT THEN PMTO.DOCAMNT ELSE PMFROM.DOCAMNT END  AS Apply_From_Description,
		PMFROM.MDFUSRID,
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

--DECLARE @tblApplyTo Table (
--	KEYSOURC					varchar(41) Null,
--	DOCDATE						datetime Null,
--	VENDORID					varchar(15) Null,
--	APTVCHNM					varchar(21) Null,
--	APTODCTY					smallint Null,
--	APTODCDT					datetime Null,
--	APTODCNM					varchar(21) Null,
--	APPLDAMT					numeric(19, 5) Null,
--	ORAPPAMT					numeric(19, 5) Null,
--	Apply_To_Document_Amount	numeric(19, 5) Null,
--	Apply_To_Due_Date			datetime Null,
--	Apply_To_Description		varchar(31) Null,
--	ApplyToGLPostDate			datetime Null,
--	VCHRNMBR					varchar(21) Null,
--	DOCTYPE						smallint Null,
--	APFRDCNM					varchar(21) Null,
--	FROMCURR					varchar(15) Null,
--	Apply_From_Document_Amou	numeric(19, 5) Null,
--	APFRMAPLYAMT				numeric(19, 5) Null,
--	ActualApplyToAmount			numeric(19, 5) Null,
--	Apply_From_Description		varchar(31) Null,
--	MDFUSRID					varchar(15) Null,
--	TEN99AMNT					numeric(19, 5) Null)