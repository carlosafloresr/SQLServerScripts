-- ********************************************************************************
-- *** SELECT THE CORRECT COMPANY AND DOCUMENT NUMBER BEFORE EXECUTE THIS SCRIPT ***
-- ********************************************************************************
USE IMC

DECLARE	@DocumentNumber	Varchar(25),
		@TotalDocument	Money,
		@AppliedAmount	Money,
		@TotalApplyTo	Money

SET		@DocumentNumber	= 'LOAN26DEC31' --> Replace this value with the required Document Number

-- Open AR Transactions
SELECT	@TotalDocument	= ORTRXAMT,
		@AppliedAmount	= CURTRXAM
FROM	(
		SELECT	ORTRXAMT, CURTRXAM
		FROM	RM20101
		WHERE	DOCNUMBR = @DocumentNumber
		UNION
		-- Historical AR Transactions
		SELECT	ORTRXAMT, CURTRXAM
		FROM	RM30101
		WHERE	DOCNUMBR = @DocumentNumber) TOTALS

SELECT	@TotalApplyTo = SUM(APPTOAMT)
FROM	(-- Open AR ApplyTo Transactions
		SELECT	APPTOAMT
		FROM	RM20201
		WHERE	APTODCNM = @DocumentNumber
		UNION
		-- Historical AR ApplyTo Transactions
		SELECT	APPTOAMT
		FROM	RM30201
		WHERE	APTODCNM = @DocumentNumber) TOTALS

PRINT 'Total AR Document:'
PRINT @TotalDocument

PRINT 'Total Applied:'
PRINT @TotalDocument - @AppliedAmount

PRINT 'Total ApplyTo Records:'
PRINT @TotalApplyTo

IF (@TotalDocument - @AppliedAmount <> @TotalApplyTo) OR (@TotalDocument <> @AppliedAmount AND @TotalApplyTo = 0)
BEGIN
	PRINT '*** FIX REQUIERD ***'

	IF EXISTS(SELECT DOCNUMBR FROM RM20101 WHERE DOCNUMBR = @DocumentNumber)
	BEGIN
		UPDATE RM20101 SET CURTRXAM = @TotalDocument - @TotalApplyTo WHERE DOCNUMBR = @DocumentNumber
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT DOCNUMBR FROM RM30101 WHERE DOCNUMBR = @DocumentNumber)
		BEGIN
			UPDATE RM30101 SET CURTRXAM = @TotalDocument - @TotalApplyTo WHERE DOCNUMBR = @DocumentNumber
		END
	END
	
	PRINT '**********************'
	PRINT '*** BALANCE FIXED! ***'
	PRINT '**********************'
END
ELSE
BEGIN
	PRINT '***********************'
	PRINT '*** NO FIX REQUIRED ***'
	PRINT '***********************'
END