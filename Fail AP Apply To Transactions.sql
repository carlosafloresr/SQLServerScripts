-- ********************************************************************************
-- *** SELECT THE CORRECT COMPANY AND VOUCHER NUMBER BEFORE EXECUTE THIS SCRIPT ***
-- ********************************************************************************

DECLARE	@DocNumbr		Varchar(25),
		@TotalDocument	Money,
		@AppliedAmount	Money,
		@TotalApplyTo	Money

SET		@DocNumbr	= 'LOAN26DEC31' --> Replace this value with the required Voucher Number

SELECT	@TotalDocument	= DOCAMNT,
		@AppliedAmount	= CURTRXAM
FROM	(-- Open AP Transactions
		SELECT	DOCAMNT, CURTRXAM
		FROM	PM20000 
		WHERE	DocNumbr = @DocNumbr
		UNION
		-- Historical AP Transactions
		SELECT	DOCAMNT, CURTRXAM
		FROM	PM30200 
		WHERE	DocNumbr = @DocNumbr) TOTALS

-- Summary Apply To Records Amount
SELECT	@TotalApplyTo = ISNULL(SUM(ActualApplyToAmount), 0)
FROM	(-- Work Apply To Records
		SELECT	ActualApplyToAmount
		FROM	PM10200 
		WHERE	APTODCNM = @DocNumbr
		UNION
		-- Historical Apply To Records Details
		SELECT	ActualApplyToAmount
		FROM	PM30300 
		WHERE	APTODCNM = @DocNumbr) TOTALS

PRINT 'Total AP Document:'
PRINT @TotalDocument

PRINT 'Total Applied:'
PRINT @TotalDocument - @AppliedAmount

PRINT 'Total ApplyTo Records:'
PRINT @TotalApplyTo

IF (@TotalDocument - @AppliedAmount <> @TotalApplyTo) OR (@TotalDocument <> @AppliedAmount AND @TotalApplyTo = 0)
BEGIN
	PRINT '*** FIX REQUIERD ***'

	IF EXISTS(SELECT VCHRNMBR FROM PM20000 WHERE DocNumbr = @DocNumbr)
	BEGIN
		UPDATE PM20000 SET CURTRXAM = @TotalDocument - @TotalApplyTo WHERE DocNumbr = @DocNumbr
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT VCHRNMBR FROM PM30200 WHERE DocNumbr = @DocNumbr)
		BEGIN
			UPDATE PM30200 SET CURTRXAM = @TotalDocument - @TotalApplyTo WHERE DocNumbr = @DocNumbr
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
SELECT * FROM PM20000 WHERE VendorId = '11630' AND DocNumbr = 'LOAN26DEC31'
SELECT * FROM PM00400 WHERE VendorId = '11630' AND DocNumbr = 'LOAN26DEC31'
SELECT * FROM PM10200 WHERE VendorId = '11630' AND APTODCNM = 'LOAN26DEC31'
SELECT * FROM PM00400 WHERE VendorId = '11630' AND DocNumbr IN (SELECT ApFrDcnm FROM PM10200 WHERE VendorId = '11630' AND APTODCNM = 'LOAN26DEC31')

UPDATE PM00400 SET DcStatus = 1 WHERE VendorId = '11630' AND DocNumbr IN (SELECT ApFrDcnm FROM PM10200 WHERE VendorId = '11630' AND APTODCNM = 'LOAN26DEC31')
DELETE PM10200 WHERE VendorId = '11630' AND APTODCNM = 'LOAN26DEC31'
*/

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