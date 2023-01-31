-- ********************************************************************************
-- *** SELECT THE CORRECT COMPANY AND VOUCHER NUMBER BEFORE EXECUTE THIS SCRIPT ***
-- ********************************************************************************
USE AIS

DECLARE	@VoucherNumber	Varchar(25),
		@TotalDocument	Money,
		@AppliedAmount	Money,
		@TotalApplyTo	Money

SET		@VoucherNumber	= 'APBAL_A0075_12216' --> Replace this value with the required Voucher Number

SELECT	@TotalDocument	= DOCAMNT,
		@AppliedAmount	= CURTRXAM
FROM	(-- Open AP Transactions
		SELECT	DOCAMNT, CURTRXAM
		FROM	PM20000 
		WHERE	VCHRNMBR = @VoucherNumber
		UNION
		-- Historical AP Transactions
		SELECT	DOCAMNT, CURTRXAM
		FROM	PM30200 
		WHERE	VCHRNMBR = @VoucherNumber) TOTALS

-- Summary Apply To Records Amount
SELECT	@TotalApplyTo = SUM(ActualApplyToAmount) 
FROM	(-- Open Apply To Records
		SELECT	ActualApplyToAmount
		FROM	PM10200 
		WHERE	APTVCHNM = @VoucherNumber
		UNION
		-- Historical Apply To Records Details
		SELECT	ActualApplyToAmount
		FROM	PM30300 
		WHERE	APTVCHNM = @VoucherNumber) TOTALS

PRINT 'Total Document:'
PRINT @TotalDocument

PRINT 'Total Applied:'
PRINT @TotalDocument - @AppliedAmount

PRINT 'Total ApplyTo Records:'
PRINT @TotalApplyTo

IF @TotalDocument - @AppliedAmount <> @TotalApplyTo
BEGIN
	PRINT '*** FIX REQUIERD ***'

	IF EXISTS(SELECT VCHRNMBR FROM PM20000 WHERE VCHRNMBR = @VoucherNumber)
	BEGIN
		UPDATE PM20000 SET CURTRXAM = @TotalDocument - @TotalApplyTo WHERE VCHRNMBR = @VoucherNumber
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT VCHRNMBR FROM PM30200 WHERE VCHRNMBR = @VoucherNumber)
		BEGIN
			UPDATE PM30200 SET CURTRXAM = @TotalDocument - @TotalApplyTo WHERE VCHRNMBR = @VoucherNumber
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

/*
-- Open AP Transactions
SELECT	VCHRNMBR
		,DOCDATE
		,VENDORID
		,DOCNUMBR
		,DOCAMNT
		,CURTRXAM
		,BACHNUMB
		,TRXDSCRN
		,PTDUSRID
FROM	PM20000 
WHERE	VCHRNMBR = @VoucherNumber
UNION
-- Historical AP Transactions
SELECT	VCHRNMBR
		,DOCDATE
		,VENDORID
		,DOCNUMBR
		,DOCAMNT
		,CURTRXAM
		,BACHNUMB
		,TRXDSCRN
		,PTDUSRID
FROM	PM30200 
WHERE	VCHRNMBR = @VoucherNumber

-- Open Apply To Records
SELECT	VENDORID
		,DOCDATE
		,VCHRNMBR
		,APFRDCNM
		,APPLYFROMGLPOSTDATE
		,APTODCNM
		,ActualApplyToAmount
FROM	PM10200 
WHERE	APTVCHNM = @VoucherNumber
UNION
-- Historical Apply To Records Details
SELECT	VENDORID
		,DOCDATE
		,VCHRNMBR
		,APFRDCNM
		,APPLYFROMGLPOSTDATE
		,APTODCNM
		,ActualApplyToAmount
FROM	PM30300 
WHERE	APTVCHNM = @VoucherNumber

-- Summary Apply To Records Amount
SELECT	SUM(ActualApplyToAmount) AS TotalApplyTo 
FROM	(-- Open Apply To Records
		SELECT	ActualApplyToAmount
		FROM	PM10200 
		WHERE	APTVCHNM = @VoucherNumber
		UNION
		-- Historical Apply To Records Details
		SELECT	ActualApplyToAmount
		FROM	PM30300 
		WHERE	APTVCHNM = @VoucherNumber) TOTALS
*/