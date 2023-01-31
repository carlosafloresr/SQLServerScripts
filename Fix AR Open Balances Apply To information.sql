DELETE	RM20201
FROM	(
		SELECT	R1.*,
				R2.ApFrDcNm
		FROM	(
				SELECT	R1.CustNmbr, 
						R1.DocNumbr,
						(ORTRXAMT - (Select ISNULL(SUM(AppToAmt), 0.0) FROM RM30201 R2 WHERE R2.CustNmbr = R1.CustNmbr And R2.ApToDcNm = R1.DocNumbr) - (Select ISNULL(SUM(AppToAmt), 0.0) As Balance FROM RM20201 R3 WHERE R3.CustNmbr = R1.CustNmbr And R3.ApToDcNm = R1.DocNumbr)) As Balance,
						ORTRXAMT,
						CurTrxAm,
						Applied_H = (Select ISNULL(SUM(AppToAmt), 0.0) FROM RM30201 R2 WHERE R2.CustNmbr = R1.CustNmbr And R2.ApToDcNm = R1.DocNumbr),
						Applied_O = (Select ISNULL(SUM(AppToAmt), 0.0) FROM RM20201 R3 WHERE R3.CustNmbr = R1.CustNmbr And R3.ApToDcNm = R1.DocNumbr)
				FROM	RM20101 R1
				) R1
				INNER JOIN RM20201 R2 ON R1.CustNmbr = R2.CustNmbr AND R1.DocNumbr = R2.ApToDcNm
				INNER JOIN RM30201 R3 ON R1.CustNmbr = R3.CustNmbr AND R1.DocNumbr = R3.ApToDcNm AND R2.ApFrDcNm = R3.ApFrDcNm
		WHERE	(Applied_H = Applied_O
				OR CurTrxAm - (Applied_H - Applied_O) <> CurTrxAm)
				AND Applied_H <> 0
		) DATA
WHERE	RM20201.CustNmbr = DATA.CustNmbr
		AND RM20201.ApToDcNm = DATA.DocNumbr
		AND RM20201.ApFrDcNm = DATA.ApFrDcNm
/*
SELECT	*
FROM	RM20101
WHERE	CustNmbr = '4182B' 
		And DocNumbr = '5-96984'

SELECT	*
FROM	RM30201
WHERE	CustNmbr = '4182B' 
		And ApToDcNm = '5-96984'

SELECT	*
FROM	RM20201
WHERE	CustNmbr = '4182B' 
		And ApToDcNm = '5-96984'
*/