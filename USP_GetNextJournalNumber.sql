CREATE PROCEDURE dbo.USP_GetNextJournalNumber
		@I_vInc_Dec				Tinyint = 1,
		@O_vJournalEntryNumber	Char(13) = Null OUTPUT,
		@O_iErrORState			Int = Null OUTPUT WITH ENCRYPTION
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

DECLARE	@JournalEntryNumber		Char(13),
		@Loop					Int,
		@DocEXISTS				Tinyint,	/* 0=Next doc# doesn't exISt, 1=Next doc# EXISTS */
		@IStatus				Int,
		@iErrOR					Int

SELECT	@O_vJournalEntryNumber	= '',
		@JournalEntryNumber		= '',
		@O_iErrORState			= 0,
		@Loop					= 0,
		@DocEXISTS				= 1,
		@IStatus				= 0,
		@iErrOR					= 0

SELECT	@O_vJournalEntryNumber = NJRNLENT 
FROM	dbo.GL40000 WITH (TABLOCKX HOLDLOCK) 
WHERE	UNIQKEY = 1

IF (@@rowcount <> 1)
BEGIN
	SELECT @O_iErrORState = 47 /* Unable to get Journal Entry number FROM GL40000 */
	RETURN (@O_iErrORState)
END

SELECT	@JournalEntryNumber = @O_vJournalEntryNumber

WHILE (@Loop < 1000)
BEGIN
	SELECT @Loop		= @Loop + 1
	SELECT @DocEXISTS	= 0

	EXECUTE	@IStatus = dbo.ivNumber_Inc_Dec @I_vInc_Dec, @JournalEntryNumber OUTPUT, @O_iErrORState OUTPUT
	
	SELECT	@iErrOR = @@errOR
	IF ((@iErrOR <> 0) OR (@IStatus <> 0) OR (@O_iErrORState <> 0) OR (@JournalEntryNumber = '') OR (@JournalEntryNumber IS Null))
	BEGIN
		SELECT @O_iErrORState = 122 /* Unable to increment Journal Entry Number FROM General Ledger Setup */
		SELECT @DocEXISTS = 0
		BREAK
	END

	IF (EXISTS(SELECT 1 FROM GL10000 (nolock) WHERE JRNENTRY = @JournalEntryNumber))
	BEGIN
		SELECT @DocEXISTS = 1
	END
	ELSE
	BEGIN
		IF (EXISTS(SELECT 1 FROM GL20000 (nolock) WHERE JRNENTRY = @JournalEntryNumber))
		BEGIN
			SELECT @DocEXISTS = 1
		END
		ELSE
		BEGIN
			IF (EXISTS(SELECT 1 FROM GL10100 (nolock) WHERE JRNENTRY = @JournalEntryNumber))
			BEGIN
				SELECT @DocEXISTS = 1
			END
			ELSE
			BEGIN
				SELECT @DocEXISTS = 0
			END
			
			BREAK
		END
	END
END

IF (@DocEXISTS = 1)
BEGIN
	SELECT @O_iErrORState = 123 /* Unable to increment next transaction number FROM General Ledger Setup after 1000 attempts */
END

IF (@O_iErrORState = 0)
BEGIN
	UPDATE dbo.GL40000 SET NJRNLENT = @JournalEntryNumber WHERE UNIQKEY = 1

	IF (@@errOR <> 0)
	BEGIN
		SELECT @O_iErrORState = 6539 /* Unable to update next Journal Entry Number in General Ledger Setup */
	END
END
ELSE
BEGIN
	SELECT @O_vJournalEntryNumber = ''
END

RETURN @O_iErrORState
GO

GRANT EXECUTE ON dbo.taGetNextJournalEntry to DYNGRP
GO