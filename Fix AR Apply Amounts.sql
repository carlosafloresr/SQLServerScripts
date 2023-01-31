SELECT	*
FROM	(
		SELECT	Source
				,CustNmbr
				,DocNumbr
				,OrTrxAmt
				,CurTrxAm
				,ISNULL(AppliedOpen, 0) + ISNULL(AppliedHist, 0) AS Applied
				,AppliedOpen
				,AppliedHist
		FROM	(
				SELECT	*,
						ISNULL(AppliedOpen,0) + ISNULL(AppliedHist,0) AS CalculatedBalance
				FROM	(
						SELECT	'Open' AS Source
								,CustNmbr
								,DocNumbr
								,OrTrxAmt
								,CurTrxAm
								,AppliedOpen = (SELECT SUM(RM20201.AppToAmt) FROM RM20201 INNER JOIN RM20101 ON RM20201.CUSTNMBR = RM20101.CUSTNMBR AND RM20201.APFRDCNM = RM20101.DocNumbr WHERE RM20201.CustNmbr = RM20101.CustNmbr AND RM20201.ApToDcNm = RM20101.DocNumbr AND RM20101.VOIDSTTS = 0)
								,AppliedHist = (SELECT SUM(RM30201.AppToAmt) FROM RM30201 INNER JOIN RM30101 ON RM30201.CUSTNMBR = RM30101.CUSTNMBR AND RM30201.APFRDCNM = RM30101.DocNumbr WHERE RM30201.CustNmbr = RM20101.CustNmbr AND RM30201.ApToDcNm = RM20101.DocNumbr AND RM30101.VOIDSTTS = 0)
						FROM	RM20101
						WHERE	VOIDSTTS = 0
						UNION
						SELECT	'History' AS Source
								,CustNmbr
								,DocNumbr
								,OrTrxAmt
								,CurTrxAm
								,AppliedOpen = ISNULL((SELECT SUM(RM20201.AppToAmt) FROM RM20201 INNER JOIN RM20101 ON RM20201.CUSTNMBR = RM20101.CUSTNMBR AND RM20201.APFRDCNM = RM20101.DocNumbr WHERE RM20201.CustNmbr = RM30101.CustNmbr AND RM20201.ApToDcNm = RM30101.DocNumbr AND RM20101.VOIDSTTS = 0),0)
								,AppliedHist = (SELECT SUM(RM30201.AppToAmt) FROM RM30201 INNER JOIN RM30101 ON RM30201.CUSTNMBR = RM30101.CUSTNMBR AND RM30201.APFRDCNM = RM30101.DocNumbr WHERE RM30201.CustNmbr = RM30101.CustNmbr AND RM30201.ApToDcNm = RM30101.DocNumbr AND RM30101.VOIDSTTS = 0)
						FROM	RM30101
						WHERE	VOIDSTTS = 0
						) DATA
				--WHERE	OrTrxAmt - (ISNULL(AppliedOpen, 0) + ISNULL(AppliedHist, 0)) <> CurTrxAm
				--		AND (ISNULL(AppliedOpen, 0) + ISNULL(AppliedHist, 0)) <> 0
				) RECS
		WHERE	ORTRXAMT <> (AppliedOpen + AppliedHist)
		) RECS
--WHERE	DocNumbr IN ('21-133760')
--WHERE	Applied = 0

--SELECT * FROM RM20201