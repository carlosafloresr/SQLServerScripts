/*
EXECUTE USP_FRSBlankInvoices
*/
ALTER PROCEDURE USP_FRSBlankInvoices
AS
SELECT	RTRIM(DEX.Field8) + '_' + RTRIM(DEX.Field4) AS Value, 
		DEX.FullFileName AS AP_Document,
		DX2.FullFileName AS FRS_Document,
		CASE WHEN DX2.Field2 = 'c:\temp\INV' THEN 1
				WHEN DX2.Field2 = 'c:\temp\WKO' THEN 2
				ELSE 3 END AS SortValue,
		DX2.Field2,
		DX2.FileSize,
		DEX.DocumentID
INTO	#tmpData
FROM	View_DEXDocuments DEX
		INNER JOIN ILSINT02.Integrations.dbo.FRS_Integrations FRS ON DEX.Field8 = FRS.AccountNumber AND DEX.Field4 = FRS.InvoiceNumber
		INNER JOIN View_DEXDocuments DX2 ON DX2.ProjectID = 117 AND DEX.Field16 = DX2.Field1 AND DX2.Field2 IN ('c:\temp\INV', 'c:\temp\WKO', 'c:\temp\MEMO')
WHERE	DEX.ProjectId = 107
		AND DEX.FileSize < 2000

SELECT	T1.*,
		ROW_NUMBER() OVER (PARTITION BY T1.AP_Document ORDER BY T1.Value, T1.SortValue) AS RowNumber,
		Counter = (SELECT COUNT(*) FROM #tmpData T2 WHERE T2.Value = t1.Value)
FROM	#tmpData T1
ORDER BY 1, 4

DROP TABLE #tmpData