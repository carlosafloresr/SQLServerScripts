
SELECT	GL2.*
		,PVO.*
FROM	GL20000 GL2
		LEFT JOIN GPCustom..Purchasing_Vouchers PVO ON CAST(GL2.JrnEntry AS Varchar(12)) = PVO.VoucherNumber AND PVo.Source = 'GL'
WHERE	GL2.SourcDoc = 'GJ'
		AND GL2.LastUser = 'TIP_Integration'
		AND GL2.CrdtAmnt = 36.87
		--AND Refrence = 'STRN MUD FLAP BRACKET-NNOI'
ORDER BY GL2.TrxDate


SELECT	MSR.*
		,INB.PostingDate
		,GL2.JrnEntry
FROM	ILSINT01.Integrations.dbo.MSR_Intercompany MSR
		INNER JOIN ILSINT01.Integrations.dbo.MSR_IntercompanyBatch INB ON MSR.BatchId = INB.BatchId
		LEFT JOIN GL20000 GL2 ON MSR.Description1 = GL2.Refrence AND MSR.Amount1 = GL2.CrdtAmnt AND ISNULL(MSR.PostingDate,INB.PostingDate) = GL2.TrxDate AND GL2.SourcDoc = 'GJ' AND GL2.LastUser = 'TIP_Integration'
WHERE	JournalNum IS Null
		--AND MSR.Amount1 = 36.87
		--AND MSR.BatchId = 'AR_RCMR_100916'
		--AND MSR.Description1 = 'STRN MUD FLAP BRACKET-NNOI'
ORDER BY MSR.PostingDate
/*

-- SELECT * FROM ILSINT01.Integrations.dbo.MSR_Intercompany

UPDATE	ILSINT01.Integrations.dbo.MSR_Intercompany
SET		JournalNum = JrnEntry
FROM	(
		SELECT	MSR.MSR_IntercompanyId
				,GL2.JrnEntry
		FROM	ILSINT01.Integrations.dbo.MSR_Intercompany MSR
				INNER JOIN ILSINT01.Integrations.dbo.MSR_IntercompanyBatch INB ON MSR.BatchId = INB.BatchId -- GL2.LstDtEdt 
				LEFT JOIN GL20000 GL2 ON MSR.Description1 = GL2.Refrence AND MSR.Amount1 = GL2.CrdtAmnt AND ISNULL(MSR.PostingDate, INB.PostingDate) = GL2.TrxDate AND GL2.SourcDoc = 'GJ' AND GL2.LastUser = 'TIP_Integration'
		WHERE	JournalNum IS Null
				--AND MSR.BatchId = 'AR_RCMR_100916'
				) RECS
WHERE	MSR_Intercompany.MSR_IntercompanyId	= RECS.MSR_IntercompanyId
		AND MSR_Intercompany.JournalNum IS Null
*/