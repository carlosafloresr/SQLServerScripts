CREATE PROCEDURE USP_APTransactions
	@BatchID	Varchar(20),
	@Company	Char(6),
	@VendorID	Varchar(20),
	@DriverID	Varchar(20) = Null,
	@DocumentNumber	Varchar(21),
	@Amount		Money,
	@PostDate	SmallDateTime
AS
DECLARE	@Query		Varchar(100)
SET	@Query = 'USE ' + @Company

EXECUTE(@Query)

IF EXISTS(SELECT VendorID FROM PM00200 WHERE VendorID = @VendorID)
BEGIN
	DECLARE	@LastVaucher	Char(25),
		@TypeEntry	Money,
		@Message	Varchar(50),
		@Terms		Varchar(30),
		@VendType	Varchar(20)

	SET	@LastVaucher = (SELECT Intranet.dbo.PADL(MAX(VchrNmbr) + 1, 17, '0') AS VchrNmbr FROM PM20000)

	IF @Amount < 0
	BEGIN
		SET @TypeEntry 	= 5
		SET @Message	= '6WHEELS Imported Credit'
		SET @Terms	= ''
		SET @VendType	= ''
	END
	ELSE
	BEGIN
		SET @TypeEntry 	= 1
		SET @Message	= '6WHEELS Imported Invoice'
		SET @Terms	= 'Net 30 days'
		SET @VendType	= 'PRIMARY'
	END

	BEGIN TRANSACTION

	INSERT INTO PM20000 (
		VCHRNMBR,
		VENDORID,
		DOCTYPE,
		DOCDATE,
		DOCNUMBR,
		DOCAMNT,
		CURTRXAM,
		BACHNUMB,
		TRXSORCE,
		BCHSOURC,
		DUEDATE,
		TRXDSCRN,
		POSTEDDT,
		PRCHAMNT,
		PYMTRMID,
		VADCDTRO)
	VALUES (@LastVaucher,
		@VendorID,
		@TypeEntry,
		GETDATE(),
		@DocumentNumber,
		ABS(@Amount),
		ABS(@Amount),
		@BatchID,
		'INTERFACE',
		'INTERFACE',
		GETDATE() + 30,
		@Message,
		@PostDate,
		ABS(@Amount),
		@Terms,
		@VendType)

	IF @@ERROR = 0
	BEGIN
		INSERT INTO PM10100 (
			VCHRNMBR,
			
	END
	ELSE
		ROLLBACK TRANSACTION
		RETURN @@ERROR * -1
	END
END	
ELSE
	RETURN -1
GO