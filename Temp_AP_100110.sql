/*
SELECT * FROM PM10200 WHERE ApToDcnm = 'DPY10195100925153'
SELECT * FROM PM20000 WHERE DocNumbr = 'DPY10195100925153'



SELECT * FROM PM10201
*/
UPDATE	PM20000
SET		PM20000.CurTrxAm = REC.FixedAmount
FROM	(
		SELECT	*,
				DocAmnt - (AppliedOpen + AppliedHist) AS FixedAmount
		FROM	(
		SELECT	VendorId
				,DocNumbr
				,DocAmnt
				,CurTrxAm
				--,AppliedWork = isnull((SELECT SUM(AppldAmt) FROM PM10201 WHERE PM10201.VendorId = PM20000.VendorId AND PM10201.ApToDcNm = PM20000.DocNumbr), 0)
				,AppliedOpen = 0 --isnull((SELECT SUM(AppldAmt) FROM PM20100 WHERE PM20100.VendorId = PM20000.VendorId AND PM20100.ApToDcNm = PM20000.DocNumbr), 0)
				,AppliedHist = isnull((SELECT SUM(AppldAmt) FROM PM30300 WHERE PM30300.VendorId = PM20000.VendorId AND PM30300.ApToDcNm = PM20000.DocNumbr), 0)
		FROM	PM20000
		WHERE	DocAmnt <> CurTrxAm) RECS) REC
WHERE	PM20000.VendorId = REC.VendorId 
		AND PM20000.DocNumbr = REC.DocNumbr
		
/*
UPDATE	PM30200
SET		PM30200.CurTrxAm = REC.FixedAmount
FROM	(
		SELECT	*,
				DocAmnt - (AppliedOpen + AppliedHist) AS FixedAmount
		FROM	(
		SELECT	VendorId
				,DocNumbr
				,DocAmnt
				,CurTrxAm
				--,AppliedWork = isnull((SELECT SUM(AppldAmt) FROM PM10201 WHERE PM10201.VendorId = PM20000.VendorId AND PM10201.ApToDcNm = PM20000.DocNumbr), 0)
				,AppliedOpen = isnull((SELECT SUM(AppldAmt) FROM PM20100 WHERE PM20100.VendorId = PM20000.VendorId AND PM20100.ApToDcNm = PM20000.DocNumbr), 0)
				,AppliedHist = isnull((SELECT SUM(AppldAmt) FROM PM30300 WHERE PM30300.VendorId = PM20000.VendorId AND PM30300.ApToDcNm = PM20000.DocNumbr), 0)
		FROM	PM30200 PM20000
		WHERE	DocAmnt <> CurTrxAm) RECS
		WHERE	CurTrxAm <> (DocAmnt - (AppliedOpen + AppliedHist))
		) REC
WHERE	PM30200.VendorId = REC.VendorId 
		AND PM30200.DocNumbr = REC.DocNumbr
*/