/*
UPDATE	PM30300 
SET		TEN99AMNT = APFRMAPLYAMT,
		Credit1099Amount = 0
WHERE	DOCDATE BETWEEN '12/30/2017' AND '12/31/2018'
		AND (APFRDCNM LIKE 'WE 12/30 FUEL%'
		or APFRDCNM LIKE 'WE 01/06 FUEL%')
		(((APFRDCNM LIKE 'WE 12/30 FUEL%' OR 
		APFRDCNM LIKE 'WE 01/06 FUEL%') 
		AND VCHRNMBR LIKE 'FUEL-%')
		OR APFRDCNM LIKE 'DPY%')

SELECT	VENDORID
		,VCHRNMBR
		,DOCDATE
		,DATE1 AS APPLYDATE
		,APTODCNM
		,APFRDCNM
		,APFRMAPLYAMT
		,TEN99AMNT
		,Credit1099Amount
		,DOCTYPE
FROM	PM30300 
WHERE	--DOCDATE BETWEEN '2018-01-01' AND '2018-12-31'
		DOCDATE = '12/22/2018'
		AND VENDORID IN (SELECT VENDORID FROM PM00200 WHERE VNDCLSID = 'DRV')
		AND (APTODCNM LIKE '%22%'
		OR APFRDCNM LIKE '%22%')
		--AND DOCTYPE = 5
		--and (((APFRDCNM LIKE 'WE 12/30 FUEL%' OR 
		--APFRDCNM LIKE 'WE 01/06 FUEL%') 
		--AND VCHRNMBR LIKE 'FUEL-%')
		--OR APFRDCNM LIKE 'DPY%')
*/

SELECT	APH.VCHRNMBR,
		APH.VENDORID,
		APH.BACHNUMB,
		APH.DOCTYPE,
		CAST(APH.DOCDATE AS Date) AS APPLYFROMDOCDATE,
		CAST(APL.DATE1 AS Date) AS APPLYDATE,
		CAST(APL.APTODCDT AS Date) AS APPLYTODATE,
		CAST(APH.DINVPDOF AS Date) AS DINVPDOF,
		CAST(APL.ApplyFromGLPostDate AS Date) AS ApplyFromGLPostDate,
		APH.DOCNUMBR,
		APH.DOCAMNT,
		APH.TEN99AMNT AS APH_TEN99AMNT,
		APL.APFRDCNM,
		APL.APTODCNM,
		APL.APFRMAPLYAMT,
		APL.TEN99AMNT AS APL_TEN99AMNT,
		APL.Credit1099Amount,
		APL.DEX_ROW_ID AS APL_DEX_ROW_ID,
		APH.DEX_ROW_ID AS APH_DEX_ROW_ID
INTO	##tmp1098Data
FROM	PM30200 APH
		INNER JOIN PM00200 VND ON APH.VENDORID = VND.VENDORID AND VND.TEN99TYPE > 1 AND VND.VNDCLSID <> 'DRV'
		INNER JOIN PM30300 APL ON APH.VENDORID = APL.VENDORID AND ((APH.DOCTYPE < 5 AND APH.DOCNUMBR = APL.APTODCNM) OR (APH.DOCTYPE >= 5 AND APH.DOCNUMBR = APL.APFRDCNM))
WHERE	APH.DOCDATE BETWEEN '01/01/2020' AND '12/31/2020'
		AND APH.DOCAMNT > 0
		AND APH.VOIDED = 0
		AND APH.DOCTYPE IN (1,5)
		--AND APH.DINVPDOF < '01/01/2021'
		AND APL.TEN99AMNT = 0
ORDER BY APH.DINVPDOF

UPDATE	PM30300
SET		PM30300.TEN99AMNT = DATA.APL_TEN99AMNT
FROM	##tmp1098Data DATA
WHERE	PM30300.DEX_ROW_ID = DATA.APL_DEX_ROW_ID

DROP TABLE ##tmp1098Data