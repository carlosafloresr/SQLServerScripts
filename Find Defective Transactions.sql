SELECT	*
FROM	(
		SELECT	'OPEN' AS 'SrcTable',
				HDR.VENDORID,
				HDR.BACHNUMB,
				CASE WHEN HDR.DOCTYPE = 1 THEN 'INV' ELSE 'CRD' END AS DOCTYPE,
				HDR.VCHRNMBR,
				HDR.DOCNUMBR,
				HDR.DOCAMNT,
				HDR.CURTRXAM,
				CAST(HDR.DOCDATE AS Date) AS DOCDATE,
				CAST(HDR.POSTEDDT AS Date) AS POSTEDDT,
				HDR.TRXDSCRN,
				DET.DISTTYPE,
				CASE DET.DISTTYPE WHEN 2 THEN 'Pay' WHEN 6 THEN 'Purch' ELSE '' END AS DIST_TYPE,
				DET.DSTINDX AS ACCTINDX,
				RTRIM(GLA.ACTNUMST) AS ACTNUMST,
				DET.CRDTAMNT AS AP_CRDTAMNT,
				DET.DEBITAMT AS AP_DEBITAMT,
				GLO.JRNENTRY,
				GLO.CRDTAMNT AS GL_CRDTAMNT,
				GLO.DEBITAMT AS GL_DEBITAMT,
				HDR.DEX_ROW_TS
		FROM	PM20000 HDR
				INNER JOIN PM10100 DET ON HDR.VCHRNMBR = DET.VCHRNMBR AND HDR.VENDORID = DET.VENDORID
				INNER JOIN GL00105 GLA ON DET.DSTINDX = GLA.ACTINDX
				LEFT JOIN GL20000 GLO ON HDR.VCHRNMBR = GLO.ORCTRNUM AND HDR.VENDORID = GLO.ORMSTRID AND DET.DSTINDX = GLO.ACTINDX
		WHERE	HDR.VCHRNMBR LIKE 'FSI%'
				AND HDR.VOIDED = 0
		UNION
		SELECT	'HISTORY' AS 'SrcTable',
				HDR.VENDORID,
				HDR.BACHNUMB,
				CASE WHEN HDR.DOCTYPE = 1 THEN 'INV' ELSE 'CRD' END AS DOCTYPE,
				HDR.VCHRNMBR,
				HDR.DOCNUMBR,
				HDR.DOCAMNT,
				HDR.CURTRXAM,
				CAST(HDR.DOCDATE AS Date) AS DOCDATE,
				CAST(HDR.POSTEDDT AS Date) AS POSTEDDT,
				HDR.TRXDSCRN,
				DET.DISTTYPE,
				CASE DET.DISTTYPE WHEN 2 THEN 'Pay' WHEN 6 THEN 'Purch' ELSE '' END AS DIST_TYPE,
				DET.DSTINDX AS ACCTINDX,
				RTRIM(GLA.ACTNUMST) AS ACTNUMST,
				DET.CRDTAMNT AS AP_CRDTAMNT,
				DET.DEBITAMT AS AP_DEBITAMT,
				GLO.JRNENTRY,
				GLO.CRDTAMNT AS GL_CRDTAMNT,
				GLO.DEBITAMT AS GL_DEBITAMT,
				HDR.DEX_ROW_TS
		FROM	PM30200 HDR
				INNER JOIN PM30600 DET ON HDR.VCHRNMBR = DET.VCHRNMBR AND HDR.VENDORID = DET.VENDORID
				INNER JOIN GL00105 GLA ON DET.DSTINDX = GLA.ACTINDX
				LEFT JOIN GL20000 GLO ON HDR.VCHRNMBR = GLO.ORCTRNUM AND HDR.VENDORID = GLO.ORMSTRID AND DET.DSTINDX = GLO.ACTINDX
		WHERE	HDR.VCHRNMBR LIKE 'FSI%'
				AND HDR.VOIDED = 0
		) DATA
WHERE	DEX_ROW_TS > '06/26/2017'
--WHERE	DISTTYPE = 6
--		AND DOCTYPE = 'INV'
--		AND AP_DEBITAMT <> 0
--		AND POSTEDDT > '06/20/2017'
		--AND ACCTINDX = 29 --NDS
		--AND ACTNUMST = '0-00-2000' --IMC
		--AND VENDORID = '50391N'
ORDER BY SRCTABLE, BACHNUMB, DOCNUMBR, VENDORID