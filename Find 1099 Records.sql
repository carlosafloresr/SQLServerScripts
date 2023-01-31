
SELECT	PM.DocNumbr
		,PM.VendorId
		,PM.DocAmnt
		,PM.TEN99AMNT
		,PM.DocDate
		,PM.TrxDscrn
		,PM.VchrNmbr
FROM	PM20000 PM
		INNER JOIN PM00200 VN ON PM.VendorId = VN.VendorId
WHERE	YEAR(PM.DocDate) = 2009
		AND VN.VndClsId = 'DRV'
		--AND LEFT(PM.VchrNmbr, 3) NOT IN ('FPT', 'DPY', 'OOS')
		AND PATINDEX('%pay%', DocNumbr) > 0
UNION
SELECT	PM.DocNumbr
		,PM.VendorId
		,PM.DocAmnt
		,PM.TEN99AMNT
		,PM.DocDate
		,PM.TrxDscrn
		,PM.VchrNmbr
FROM	PM30200 PM
		INNER JOIN PM00200 VN ON PM.VendorId = VN.VendorId
WHERE	YEAR(PM.DocDate) = 2009
		AND VN.VndClsId = 'DRV'
		--AND LEFT(PM.VchrNmbr, 3) NOT IN ('FPT', 'DPY', 'OOS')
		AND PATINDEX('%pay%', DocNumbr) > 0
ORDER BY DocDate


/*
SELECT * FROM PM30200
UPDATE	PM20000
		SET TEN99AMNT = 0
WHERE	YEAR(PM.DocDate) = 2009
		AND VN.VndClsId = 'DRV'
		--AND LEFT(PM.VchrNmbr, 3) NOT IN ('FPT', 'DPY', 'OOS')
		AND PATINDEX('%ADJ%', DocNumbr) > 0
		
UPDATE	PM30200
		SET TEN99AMNT = 0
WHERE	YEAR(PM.DocDate) = 2009
		AND VN.VndClsId = 'DRV'
		--AND LEFT(PM.VchrNmbr, 3) NOT IN ('FPT', 'DPY', 'OOS')
		AND PATINDEX('%ADJ%', DocNumbr) > 0
*/

/*
UPDATE	PM20000
		SET TEN99AMNT = DocAmnt
WHERE	(PATINDEX('%DPY%', DocNumbr) > 0 OR PATINDEX('%EIN%', DocNumbr) > 0)
		AND DocAmnt <> TEN99AMNT
		
UPDATE	PM30200
		SET TEN99AMNT = DocAmnt
WHERE	(PATINDEX('%DPY%', DocNumbr) > 0 OR PATINDEX('%EIN%', DocNumbr) > 0)
		AND DocAmnt <> TEN99AMNT
*/