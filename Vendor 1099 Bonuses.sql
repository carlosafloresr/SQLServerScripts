-- FIX 1099 AMOUNT
DECLARE	@DateIni	Date = '1/1/2014',
		@DateEnd	Date = '12/31/2014',
		@FixOrClean	Char(1) = 'F',
		@VndClsId	Varchar(10) = 'TRD'

IF @FixOrClean = 'F' -- FIX 1099 AMOUNT
BEGIN
	UPDATE	PM30200
	SET		PM30200.Ten99Amnt = RECS.DocAmnt
	FROM	(
			SELECT	PM30200.Dex_Row_id,
					PM30200.DocAmnt
			FROM	PM30200
					INNER JOIN PM00200 ON PM30200.VendorId = PM00200.VendorId
			WHERE	DocDate BETWEEN @DateIni AND @DateEnd
					--AND (PATINDEX('%SRM BONUS%', DocNumbr) > 0
					--OR PATINDEX('%BONUS%', DocNumbr) > 0
					--OR PATINDEX('%BNS%', DocNumbr) > 0)
					AND VndClsId = @VndClsId
					AND PM00200.TEN99TYPE > 1) RECS
	WHERE	PM30200.Dex_Row_id = RECS.Dex_Row_id

	UPDATE	PM20000
	SET		PM20000.Ten99Amnt = RECS.DocAmnt
	FROM	(
			SELECT	PM20000.Dex_Row_id,
					PM20000.DocAmnt
			FROM	PM20000
					INNER JOIN PM00200 ON PM20000.VendorId = PM00200.VendorId
			WHERE	DocDate BETWEEN @DateIni AND @DateEnd
					--AND (PATINDEX('%SRM BONUS%', DocNumbr) > 0
					--OR PATINDEX('%BONUS%', DocNumbr) > 0
					--OR PATINDEX('%BNS%', DocNumbr) > 0)
					AND VndClsId = @VndClsId
					AND PM00200.TEN99TYPE > 1) RECS
	WHERE	PM20000.Dex_Row_id = RECS.Dex_Row_id
END
ELSE
BEGIN
	-- C = CLEAN 1099 AMOUNT
	UPDATE	PM20000
	SET		PM20000.Ten99Amnt = 0
	FROM	(
			SELECT	PM20000.Dex_Row_id,
					PM20000.DocAmnt
			FROM	PM20000
					INNER JOIN PM00200 ON PM20000.VendorId = PM00200.VendorId
			WHERE	(PATINDEX('%XFR%', DocNumbr) > 0
					OR PATINDEX('%XFER%', DocNumbr) > 0
					OR PATINDEX('%TSFR%', DocNumbr) > 0
					OR PATINDEX('%SAVINGS%', DocNumbr) > 0)
					AND DocDate BETWEEN @DateIni AND @DateEnd
					AND VndClsId = @VndClsId
					AND PM00200.TEN99TYPE > 1
			) RECS
	WHERE	PM20000.Dex_Row_id = RECS.Dex_Row_id

	UPDATE	PM30200
	SET		PM30200.Ten99Amnt = 0
	FROM	(	
			SELECT	PM30200.Dex_Row_id,
					PM30200.DocAmnt
			FROM	PM30200
					INNER JOIN PM00200 ON PM30200.VendorId = PM00200.VendorId
			WHERE	(PATINDEX('%XFR%', DocNumbr) > 0
					OR PATINDEX('%XFER%', DocNumbr) > 0
					OR PATINDEX('%TSFR%', DocNumbr) > 0
					OR PATINDEX('%SAVINGS%', DocNumbr) > 0)
					AND DocDate BETWEEN @DateIni AND @DateEnd
					AND VndClsId = @VndClsId
					AND PM30200.TEN99TYPE > 1
			) RECS
	WHERE	PM30200.Dex_Row_id = RECS.Dex_Row_id
END

/*
(PATINDEX('%SIGN%', DocNumbr) > 0
				OR PATINDEX('%REF%', DocNumbr) > 0
				OR PATINDEX('%SGN ON%', DocNumbr) > 0
				OR PATINDEX('%SRM BONUS%', DocNumbr) > 0
				OR PATINDEX('%BONUS%', DocNumbr) > 0
				OR PATINDEX('%BNS%', DocNumbr) > 0
				OR PATINDEX('%REFUN%', DocNumbr) > 0
				OR PATINDEX('%XFEREF%', DocNumbr) > 0
				OR PATINDEX('%PAYOFF%', DocNumbr) > 0
				OR PATINDEX('%OUTLOAD%', DocNumbr) > 0
				OR PATINDEX('%LFD%', DocNumbr) > 0
				OR PATINDEX('%YRD%', DocNumbr) > 0
				OR PATINDEX('%YARD%', DocNumbr) > 0
				OR PATINDEX('%DRAY%', DocNumbr) > 0
				OR PATINDEX('%DVER%', DocNumbr) > 0
				OR PATINDEX('%VIOL%', DocNumbr) > 0
				OR PATINDEX('%LVL%', DocNumbr) > 0
				OR PATINDEX('%INSP%', DocNumbr) > 0
				OR PATINDEX('%DET PAY%', DocNumbr) > 0)
*/