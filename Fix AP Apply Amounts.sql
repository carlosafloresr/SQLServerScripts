DELETE	PM10200
FROM	(
		SELECT	P1.VENDORID,
				P1.DOCNUMBR,
				P2.ApFrDcNm
		FROM	(
				SELECT	*,
						DOCAMNT - (ApplyTo_O + ApplyTo_H) AS Balance
				FROM	(
						SELECT	VendorId,
								DocNumbr,
								DOCAMNT, 
								CURTRXAM,
								ApplyTo_O = ISNULL((SELECT ActualApplyToAmount FROM PM10200 P2 WHERE P2.ApToDcnm = P1.DocNumbr AND P2.VENDORID = P1.VENDORID),0),
								ApplyTo_H = ISNULL((SELECT ActualApplyToAmount FROM PM30300 P2 WHERE P2.ApToDcnm = P1.DocNumbr AND P2.VENDORID = P1.VENDORID),0)
						FROM	PM20000 P1
						) DATA
				WHERE	DOCAMNT - (ApplyTo_O + ApplyTo_H) <> CURTRXAM 
						AND ApplyTo_O + ApplyTo_H > 0
				) P1
				INNER JOIN PM10200 P2 ON P1.VENDORID = P2.VENDORID AND P1.DocNumbr = P2.ApToDcnm
				INNER JOIN PM30300 P3 ON P1.VENDORID = P3.VENDORID AND P1.DocNumbr = P3.ApToDcnm AND P2.ApFrDcNm = P3.ApFrDcNm
		) DATA
WHERE	PM10200.VENDORID = DATA.VENDORID
		AND PM10200.ApToDcnm = DATA.DocNumbr
		AND PM10200.ApFrDcNm = DATA.ApFrDcNm

UPDATE	PM20000
SET		PM20000.CURTRXAM = DATA.Balance
FROM	(
		SELECT	*,
				DOCAMNT - (ApplyTo_O + ApplyTo_H) AS Balance
		FROM	(
				SELECT	VendorId,
						DocNumbr,
						DOCAMNT, 
						CURTRXAM,
						ApplyTo_O = ISNULL((SELECT ActualApplyToAmount FROM PM10200 P2 WHERE P2.ApToDcnm = P1.DocNumbr AND P2.VENDORID = P1.VENDORID),0),
						ApplyTo_H = ISNULL((SELECT ActualApplyToAmount FROM PM30300 P2 WHERE P2.ApToDcnm = P1.DocNumbr AND P2.VENDORID = P1.VENDORID),0)
				FROM	PM20000 P1
				) DATA
		WHERE	CURTRXAM <> DOCAMNT 
				AND ((ApplyTo_O + ApplyTo_H) = 0
				OR DOCAMNT - (ApplyTo_O + ApplyTo_H) <> CURTRXAM)
		) DATA
WHERE	PM20000.VendorId = DATA.VendorId
		AND PM20000.DocNumbr = DATA.DocNumbr

