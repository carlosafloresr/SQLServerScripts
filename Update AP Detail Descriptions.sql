/*
SELECT * FROM PM30600 WHERE PATINDEX('%Purcha%', TrxDscrn) > 0

SELECT	TrxDscrn,  DistRef
FROM	PM30600 PD
		INNER JOIN PM30200 PH ON PD.VchrNmbr = PH.VchrNmbr AND PD.TrxSorce = PH.TrxSorce
WHERE	PD.DistRef = '' --PATINDEX('%Purcha%', DistRef) > 0
*/

UPDATE	PM30600
SET		PM30600.DistRef = PM30200.TrxDscrn
FROM	PM30200
WHERE	PM30600.VchrNmbr = PM30200.VchrNmbr 
		AND PM30600.TrxSorce = PM30200.TrxSorce
		AND PM30600.DistRef = ''
		AND PM30200.TrxDscrn <> ''

SELECT * FROM GL20000 order by Dscriptn WHERE JRNENTRY = 10829

UPDATE GL20000 SET Dscriptn = Refrence WHERE Dscriptn = 'Purchases'