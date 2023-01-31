-- select * from GPCustom.dbo.gccp
-- SELECT * FROM RM20101 WHERE CurTrxAm = 0 and DocNumbr IN (SELECT [Document Number] FROM GPCustom.dbo.GCCP)

INSERT INTO RM20201
		(CustNmbr
		,CPRCSTNM
		,Date1
		,GLPostDt
		,Posted
		,ApToDcNm
		,ApToDcDt
		,ApplyToGLPostDate
		,AppToAmt
		,OrApToAm
		,ApFrDcNm
		,ApFrDcTy
		,ApFrDcDt
		,ApplyFromGLPostDate
		,ApFrmAplyAmt
		,ActualApplyToAmount)
SELECT	RM1.CustNmbr
		,'' AS CPRCSTNM
		,RM1.DocDate AS Date1
		,RM1.GLPostDt AS GLPostDt
		,1 AS Posted
		,RM1.DocNumbr AS ApToDcNm
		,RM1.DocDate AS ApToDcDt
		,RM1.GLPostDt AS ApplyToGLPostDate
		,ABS(GCCP.Amount) AS AppToAmt
		,ABS(GCCP.Amount) AS OrApToAm
		,GCCP.ApplyTo AS ApFrDcNm
		,RM1.RmdTypal AS ApFrDcTy
		,RM2.DocDate AS ApFrDcDt
		,RM2.GLPostDt AS ApplyFromGLPostDate
		,ABS(GCCP.Amount) AS ApFrmAplyAmt
		,ABS(GCCP.Amount) AS ActualApplyToAmount
FROM	RM20101 RM1
		INNER JOIN GPCustom.dbo.GCCP ON RM1.DocNumbr = GCCP.[Document Number]
		INNER JOIN RM20101 RM2 ON GCCP.ApplyTo = RM2.DocNumbr
GO

UPDATE	RM20101
SET		RM20101.CurTrxAm = RECS.Balance
FROM	(
		SELECT	OrTrxAmt - Applied AS Balance,*
		FROM	(
		SELECT	CustNmbr
				,DocNumbr
				,OrTrxAmt
				,CurTrxAm
				,ISNULL(AppliedOpen, 0) + ISNULL(AppliedHist, 0) AS Applied
		FROM	(
		SELECT	CustNmbr
				,DocNumbr
				,OrTrxAmt
				,CurTrxAm
				,AppliedOpen = (SELECT SUM(AppToAmt) FROM RM20201 WHERE RM20201.CustNmbr = RM20101.CustNmbr AND RM20201.ApToDcNm = RM20101.DocNumbr)
				,AppliedHist = (SELECT SUM(AppToAmt) FROM RM30201 WHERE RM30201.CustNmbr = RM20101.CustNmbr AND RM30201.ApToDcNm = RM20101.DocNumbr)
		FROM	RM20101) RECS)RECS
		WHERE	DocNumbr IN (SELECT [Document Number] FROM GPCustom.dbo.GCCP)) RECS
WHERE	RM20101.DocNumbr = RECS.DocNumbr
GO

/*
SELECT	CustNmbr
		,CPRCSTNM
		,Date1
		,GLPostDt
		,Posted
		,ApToDcNm
		,ApToDcDt
		,ApplyToGLPostDate
		,AppToAmt
		,OrApToAm
		,ApFrDcNm
		,ApFrDcTy
		,ApFrDcDt
		,ApplyFromGLPostDate
		,ApFrmAplyAmt
		,ActualApplyToAmount
FROM	RM20201
WHERE	ApFrDcNm IN (SELECT ApplyTo FROM GPCustom.dbo.GCCP)

DELETE	RM20201
WHERE	ApFrDcNm IN (SELECT ApplyTo FROM GPCustom.dbo.GCCP)


SELECT	CustNmbr
		,CPRCSTNM
		,Date1
		,GLPostDt
		,Posted
		,ApToDcNm
		,ApToDcDt
		,ApplyToGLPostDate
		,AppToAmt
		,OrApToAm
		,ApFrDcNm
		,ApFrDcTy
		,ApFrDcDt
		,ApplyFromGLPostDate
		,ApFrmAplyAmt
		,ActualApplyToAmount
FROM	RM30201 --RM20201
WHERE	ApFrDcNm IN ('3363_002')

WHERE	ApFrDcNm IN ('3299')
*/